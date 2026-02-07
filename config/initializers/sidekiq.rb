# Sidekiq 설정파일
# 백그라운드 작업(Yahoo Finance API 호출, 알림 발송 등)을 처리하는 Sidekiq의 설정

# Redis 연결 설정
# 개발환경에서는 로컬 Redis, 프로덕션에서는 Upstash Redis URL 사용
redis_config = {
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"), # 환경변수가 없으면 로컬 Redis 사용
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } # SSL 인증서 검증 비활성화 (Upstash용)
}

# Sidekiq 서버(백그라운드 작업 실행) 설정
Sidekiq.configure_server do |config|
  config.redis = redis_config
  
  # 스케줄링된 작업의 폴링 간격을 15초로 설정 (기본 15초보다 빠르게)
  config.average_scheduled_poll_interval = 15
  
  # 최대 동시 처리 작업 수 제한 (API 호출 제한을 고려)
  config.concurrency = 5
end

# Sidekiq 클라이언트(작업 큐잉) 설정
Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# Sidekiq 웹 UI를 위한 설정
require "sidekiq/web"

# 프로덕션에서는 Sidekiq 웹 UI에 인증을 추가하는 것을 권장
# 지금은 개발용이므로 인증 없이 사용