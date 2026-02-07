# 알림 관리 API 컨트롤러
class Api::V1::AlertsController < Api::V1::BaseController
  
  # GET /api/v1/alerts?user_identifier=xxx
  # 사용자의 알림 목록 조회
  def index
    user_identifier = params[:user_identifier]
    
    if user_identifier.blank?
      return error_response("user_identifier가 필요합니다", :bad_request)
    end
    
    alerts = Alert.where(user_identifier: user_identifier)
                  .order(created_at: :desc)
    
    alerts_data = alerts.map do |alert|
      {
        id: alert.id,
        index_name: alert.index_name,
        threshold_value: alert.threshold_value.to_f,
        comparison_type: alert.comparison_type,
        is_active: alert.is_active,
        created_at: alert.created_at.strftime('%Y-%m-%d %H:%M:%S')
      }
    end
    
    success_response(alerts_data, "알림 목록 조회 성공")
  end
  
  # POST /api/v1/alerts
  # 새 알림 생성
  def create
    alert_params = params.require(:alert).permit(
      :user_identifier, :index_name, :threshold_value, 
      :comparison_type, :fcm_token
    )
    
    # 필수 파라미터 검증
    if alert_params[:user_identifier].blank?
      return error_response("user_identifier가 필요합니다", :bad_request)
    end
    
    alert = Alert.new(alert_params)
    
    if alert.save
      # 생성된 알림 정보 반환
      alert_data = {
        id: alert.id,
        index_name: alert.index_name,
        threshold_value: alert.threshold_value.to_f,
        comparison_type: alert.comparison_type,
        is_active: alert.is_active,
        created_at: alert.created_at.strftime('%Y-%m-%d %H:%M:%S')
      }
      
      success_response(alert_data, "알림이 성공적으로 생성되었습니다", :created)
    else
      error_response("알림 생성에 실패했습니다", :unprocessable_entity, alert.errors.full_messages)
    end
  end
  
  # PUT /api/v1/alerts/:id
  # 알림 수정 (활성화/비활성화 주로)
  def update
    alert = Alert.find(params[:id])
    
    # 사용자 권한 확인 (같은 user_identifier만 수정 가능)
    if params[:user_identifier].present? && alert.user_identifier != params[:user_identifier]
      return error_response("권한이 없습니다", :forbidden)
    end
    
    update_params = params.require(:alert).permit(:threshold_value, :comparison_type, :is_active, :fcm_token)
    
    if alert.update(update_params)
      alert_data = {
        id: alert.id,
        index_name: alert.index_name,
        threshold_value: alert.threshold_value.to_f,
        comparison_type: alert.comparison_type,
        is_active: alert.is_active,
        updated_at: alert.updated_at.strftime('%Y-%m-%d %H:%M:%S')
      }
      
      success_response(alert_data, "알림이 성공적으로 수정되었습니다")
    else
      error_response("알림 수정에 실패했습니다", :unprocessable_entity, alert.errors.full_messages)
    end
  end
  
  # DELETE /api/v1/alerts/:id
  # 알림 삭제
  def destroy
    alert = Alert.find(params[:id])
    
    # 사용자 권한 확인
    if params[:user_identifier].present? && alert.user_identifier != params[:user_identifier]
      return error_response("권한이 없습니다", :forbidden)
    end
    
    alert.destroy!
    
    success_response({}, "알림이 성공적으로 삭제되었습니다")
  end
end