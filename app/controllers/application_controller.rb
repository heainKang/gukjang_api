class ApplicationController < ActionController::Base
  # CSRF 보호 비활성화 (개발용)
  protect_from_forgery with: :null_session
end
