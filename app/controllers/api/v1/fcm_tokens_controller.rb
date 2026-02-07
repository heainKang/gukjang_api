# Firebase Cloud Messaging 토큰 관리 API 컨트롤러
class Api::V1::FcmTokensController < Api::V1::BaseController
  
  # POST /api/v1/register_token
  # FCM 토큰 등록/업데이트
  def create
    user_identifier = params[:user_identifier]
    fcm_token = params[:fcm_token]
    
    # 필수 파라미터 검증
    if user_identifier.blank? || fcm_token.blank?
      return error_response("user_identifier와 fcm_token이 모두 필요합니다", :bad_request)
    end
    
    begin
      # 해당 사용자의 모든 활성화된 알림에 FCM 토큰 업데이트
      alerts = Alert.where(user_identifier: user_identifier, is_active: true)
      
      if alerts.any?
        # 기존 알림들에 FCM 토큰 업데이트
        updated_count = alerts.update_all(fcm_token: fcm_token)
        
        success_response({
          updated_alerts_count: updated_count,
          message: "#{updated_count}개의 알림에 FCM 토큰이 업데이트되었습니다"
        }, "FCM 토큰 등록 성공")
      else
        # 알림이 없는 경우에도 성공으로 처리 (나중에 알림 생성 시 사용됨)
        success_response({
          updated_alerts_count: 0,
          message: "등록된 알림이 없습니다. 알림 생성 시 자동으로 적용됩니다."
        }, "FCM 토큰 등록 성공")
      end
      
    rescue StandardError => e
      Rails.logger.error "FCM 토큰 등록 중 오류: #{e.message}"
      error_response("FCM 토큰 등록 중 오류가 발생했습니다", :internal_server_error)
    end
  end
  
  # DELETE /api/v1/register_token
  # FCM 토큰 삭제 (알림 끄기)
  def destroy
    user_identifier = params[:user_identifier]
    
    if user_identifier.blank?
      return error_response("user_identifier가 필요합니다", :bad_request)
    end
    
    begin
      # 해당 사용자의 모든 알림에서 FCM 토큰 제거
      alerts = Alert.where(user_identifier: user_identifier)
      updated_count = alerts.update_all(fcm_token: nil)
      
      success_response({
        updated_alerts_count: updated_count,
        message: "#{updated_count}개의 알림에서 FCM 토큰이 제거되었습니다"
      }, "FCM 토큰 삭제 성공")
      
    rescue StandardError => e
      Rails.logger.error "FCM 토큰 삭제 중 오류: #{e.message}"
      error_response("FCM 토큰 삭제 중 오류가 발생했습니다", :internal_server_error)
    end
  end
end