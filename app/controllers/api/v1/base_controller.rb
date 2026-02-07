# API v1의 기본 컨트롤러
# 모든 API 컨트롤러가 상속받을 공통 기능들 정의
class Api::V1::BaseController < ApplicationController
  # API 전용이므로 CSRF 토큰 검증 생략 (Rails 8 API mode에서는 기본적으로 불필요)
  
  # JSON 응답만 처리
  before_action :set_json_response_format
  
  # 에러 핸들링
  rescue_from StandardError, with: :handle_internal_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  
  private
  
  # JSON 응답 형식 설정
  def set_json_response_format
    request.format = :json
  end
  
  # 성공 응답 형식
  def success_response(data = {}, message = nil, status = :ok)
    response = {
      success: true,
      data: data
    }
    
    response[:message] = message if message.present?
    
    render json: response, status: status
  end
  
  # 에러 응답 형식  
  def error_response(message, status = :unprocessable_entity, errors = nil)
    response = {
      success: false,
      message: message
    }
    
    response[:errors] = errors if errors.present?
    
    render json: response, status: status
  end
  
  # 404 에러 처리
  def handle_not_found(exception)
    Rails.logger.error "Not Found: #{exception.message}"
    error_response("요청한 리소스를 찾을 수 없습니다", :not_found)
  end
  
  # 유효성 검증 에러 처리
  def handle_validation_error(exception)
    Rails.logger.error "Validation Error: #{exception.message}"
    error_response("입력 데이터가 올바르지 않습니다", :unprocessable_entity, 
                   exception.record.errors.full_messages)
  end
  
  # 내부 서버 에러 처리
  def handle_internal_error(exception)
    Rails.logger.error "Internal Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    if Rails.env.development?
      error_response("내부 서버 오류: #{exception.message}", :internal_server_error)
    else
      error_response("내부 서버 오류가 발생했습니다", :internal_server_error)
    end
  end
end