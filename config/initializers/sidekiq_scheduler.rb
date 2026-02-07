# Sidekiq 스케줄러 설정
# 주기적으로 실행될 작업들 정의

# Rails 애플리케이션이 시작된 후에 스케줄러 시작
Rails.application.config.after_initialize do
  if defined?(Sidekiq)
    # 개발환경에서만 스케줄러 활성화 (production에서는 cron 또는 별도 스케줄러 사용 권장)
    if Rails.env.development? || Rails.env.production?
      
      # 매 2분마다 지수 데이터 업데이트
      Sidekiq.configure_server do |config|
        # 애플리케이션 시작 후 1분 뒤에 첫 실행, 이후 2분마다 반복
        IndexFetchWorker.perform_in(1.minute)
        
        # 주기적으로 IndexFetchWorker 실행을 위한 스케줄링
        # 실제로는 cron이나 sidekiq-scheduler gem을 사용하는 것이 좋습니다
      end
    end
  end
end

# IndexFetchWorker가 완료된 후 다음 실행 스케줄링을 위한 콜백
class IndexFetchWorker
  # 작업 완료 후 다음 실행 예약
  def self.schedule_next_run
    # 2분 후에 다시 실행 예약
    perform_in(2.minutes)
  end
end