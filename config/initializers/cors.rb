# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# CORS 설정 - Next.js 프론트엔드와 통신을 위해 필요
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 개발 환경에서는 localhost:3000 (Next.js 기본 포트)를 허용
    # 실제 배포시에는 실제 도메인으로 변경 필요
    origins "localhost:3000", "127.0.0.1:3000", "국장박살.com"

    # 모든 API 엔드포인트에 대해 HTTP 메소드 허용
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
