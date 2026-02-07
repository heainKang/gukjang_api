# 주식 지수 데이터를 주기적으로 가져오는 Sidekiq Worker
class IndexFetchWorker
  include Sidekiq::Worker
  
  # Sidekiq 옵션 설정
  sidekiq_options retry: 3, queue: :default

  def perform
    Rails.logger.info "지수 데이터 업데이트 시작..."
    
    # 중복 실행 방지를 위한 Redis 락 설정
    lock_key = 'index_fetch_lock'
    
    # Redis에서 락 확인 (30초 동안 유지)
    if Redis.current.get(lock_key)
      Rails.logger.info "이미 지수 업데이트가 실행 중입니다. 건너뜁니다."
      return
    end
    
    # 락 설정 (30초 후 자동 만료)
    Redis.current.setex(lock_key, 30, true)
    
    begin
      # Yahoo Finance 서비스 인스턴스 생성
      yahoo_service = YahooFinanceService.new
      
      # 모든 지수의 심볼 가져오기
      indices = Index.all
      symbols = indices.map(&:symbol)
      
      # 여러 지수를 한 번에 조회 (API 호출 최소화)
      quotes = yahoo_service.fetch_multiple_quotes(symbols)
      
      updated_count = 0
      
      # 각 지수 데이터 업데이트
      quotes.each do |quote|
        index = indices.find { |i| i.symbol == quote[:symbol] }
        
        if index
          # 지수값 업데이트
          index.update_value(quote[:current_price])
          updated_count += 1
          
          Rails.logger.info "#{index.name}: #{quote[:current_price]} 업데이트 완료"
          
          # 해당 지수의 알림 조건 확인
          check_alerts_for_index(index, quote[:current_price])
        end
      end
      
      Rails.logger.info "총 #{updated_count}개 지수 업데이트 완료"
      
      # 다음 실행 예약 (2분 후)
      IndexFetchWorker.perform_in(2.minutes) if Rails.env.development? || Rails.env.production?
      
    rescue YahooFinanceService::RateLimitError => e
      Rails.logger.error "Yahoo Finance API 호출 제한: #{e.message}"
      # 1분 후 재시도
      IndexFetchWorker.perform_in(1.minute)
      
    rescue YahooFinanceService::ApiError => e
      Rails.logger.error "Yahoo Finance API 오류: #{e.message}"
      # 실패해도 다음 정기 실행까지 기다림
      
    rescue StandardError => e
      Rails.logger.error "지수 데이터 업데이트 중 오류: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
    ensure
      # 락 해제
      Redis.current.del(lock_key)
    end
  end

  private

  # 특정 지수의 알림 조건들을 확인하고 필요시 알림 발송
  def check_alerts_for_index(index, current_value)
    # 해당 지수의 활성화된 알림들 조회
    alerts = Alert.for_index(index.name)
    
    alerts.each do |alert|
      # 알림 조건 확인
      if alert.triggered?(current_value)
        # 알림 발송
        send_notification(alert, current_value)
        
        # 알림을 비활성화하여 중복 발송 방지
        alert.deactivate!
        
        Rails.logger.info "알림 발송: #{alert.user_identifier} - #{index.name} #{current_value}"
      end
    end
  end

  # 실제 푸시 알림 발송
  def send_notification(alert, current_value)
    # FCM 토큰이 있는 경우에만 푸시 알림 발송
    return unless alert.fcm_token.present?
    
    # 알림 메시지 생성
    message = alert.notification_message(current_value)
    
    # FCM 푸시 알림 발송을 별도 Worker로 처리
    FcmNotificationWorker.perform_async(alert.fcm_token, message, {
      index_name: alert.index_name,
      current_value: current_value.to_s,
      threshold_value: alert.threshold_value.to_s
    })
  end
end