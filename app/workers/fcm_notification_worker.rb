# Firebase Cloud Messaging을 통한 푸시 알림 발송 Worker
class FcmNotificationWorker
  include Sidekiq::Worker
  
  # FCM 전용 큐 사용 (알림은 빠르게 처리되어야 함)
  sidekiq_options retry: 2, queue: :notifications

  def perform(fcm_token, message, data = {})
    Rails.logger.info "FCM 푸시 알림 발송 시작: #{fcm_token[0..20]}..."
    
    begin
      # FCM 서비스 인스턴스 생성 (환경변수 또는 파일에서 credentials 로드)
      credentials = if ENV['FIREBASE_CREDENTIALS_JSON']
        JSON.parse(Base64.decode64(ENV['FIREBASE_CREDENTIALS_JSON']))
      else
        Rails.root.join('config', 'gukjang-api-firebase-adminsdk-fbsvc-5bb331fd55.json').to_s
      end
      fcm_client = FCM.new(credentials)
      
      # 푸시 알림 옵션 설정
      notification_options = {
        notification: {
          title: "🧨 국장박살 알림",
          body: message,
          icon: "/icon.png", # 앱 아이콘 (public 폴더에 위치)
          badge: "/icon.png"
        },
        data: data.merge({
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          sound: "default"
        })
      }
      
      # FCM 푸시 알림 발송
      response = fcm_client.send(fcm_token, notification_options)
      
      # 응답 처리
      if response[:status_code] == 200 && response[:response]['success'] == 1
        Rails.logger.info "FCM 푸시 알림 발송 성공"
      else
        error_msg = response[:response]['results']&.first&.dig('error') || 'Unknown error'
        Rails.logger.error "FCM 푸시 알림 발송 실패: #{error_msg}"
        
        # 토큰 에러인 경우 해당 Alert 비활성화
        if invalid_token_error?(error_msg)
          deactivate_alert_with_token(fcm_token)
        end
      end
      
    rescue StandardError => e
      Rails.logger.error "FCM 푸시 알림 발송 중 오류: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end

  private

  # 유효하지 않은 토큰 에러인지 확인
  def invalid_token_error?(error_msg)
    invalid_errors = [
      'InvalidRegistration',
      'NotRegistered', 
      'MismatchSenderId'
    ]
    
    invalid_errors.any? { |error| error_msg.include?(error) }
  end

  # 유효하지 않은 FCM 토큰을 가진 Alert 비활성화
  def deactivate_alert_with_token(fcm_token)
    alerts = Alert.where(fcm_token: fcm_token, is_active: true)
    
    alerts.each do |alert|
      alert.update!(is_active: false)
      Rails.logger.info "유효하지 않은 FCM 토큰으로 Alert #{alert.id} 비활성화"
    end
  end
end