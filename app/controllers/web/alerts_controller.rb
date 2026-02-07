class Web::AlertsController < ApplicationController
  before_action :set_user_identifier
  before_action :set_alert, only: [:show, :edit, :update, :destroy]

  def index
    # 실제 API 호출해서 알람 목록 조회
    @alerts = fetch_user_alerts
  end

  def show
  end

  def new
    @alert = {}
    @supported_indices = ['KOSPI', 'NASDAQ', 'S&P 500']
  end

  def create
    # API로 알람 생성
    response = create_alert_via_api(alert_params)
    
    if response[:success]
      redirect_to web_alerts_path, notice: '알람이 성공적으로 생성되었습니다.'
    else
      @supported_indices = ['KOSPI', 'NASDAQ', 'S&P 500']
      @alert = alert_params
      @errors = response[:errors]
      render :new
    end
  end

  def edit
  end

  def update
    # API로 알람 수정
    response = update_alert_via_api(@alert[:id], alert_params)
    
    if response[:success]
      redirect_to web_alerts_path, notice: '알람이 수정되었습니다.'
    else
      @errors = response[:errors]
      render :edit
    end
  end

  def destroy
    # API로 알람 삭제
    response = delete_alert_via_api(@alert[:id])
    
    if response[:success]
      redirect_to web_alerts_path, notice: '알람이 삭제되었습니다.'
    else
      redirect_to web_alerts_path, alert: '삭제에 실패했습니다.'
    end
  end

  private

  def set_user_identifier
    # 실제로는 로그인 시스템을 구현해야 하지만, 지금은 임시로 고정값 사용
    @user_identifier = params[:user_identifier] || session[:user_identifier] || 'user123'
    session[:user_identifier] = @user_identifier
  end

  def set_alert
    @alerts = fetch_user_alerts
    @alert = @alerts.find { |a| a[:id].to_s == params[:id] } if @alerts
    redirect_to web_alerts_path, alert: '알람을 찾을 수 없습니다.' unless @alert
  end

  def alert_params
    params.require(:alert).permit(:name, :index_name, :threshold_value, :condition, :is_active) if params[:alert]
    params.permit(:name, :index_name, :threshold_value, :condition, :is_active)
  end

  def fetch_user_alerts
    # 실제 API 호출
    begin
      uri = URI("http://localhost:3000/api/v1/alerts?user_identifier=#{@user_identifier}")
      response = Net::HTTP.get_response(uri)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        data['success'] ? data['data'] : []
      else
        []
      end
    rescue => e
      Rails.logger.error "알람 조회 실패: #{e.message}"
      []
    end
  end

  def create_alert_via_api(params)
    begin
      uri = URI("http://localhost:3000/api/v1/alerts")
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = params.merge(user_identifier: @user_identifier).to_json
      
      response = http.request(request)
      JSON.parse(response.body).symbolize_keys
    rescue => e
      { success: false, errors: [e.message] }
    end
  end

  def update_alert_via_api(alert_id, params)
    begin
      uri = URI("http://localhost:3000/api/v1/alerts/#{alert_id}")
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Put.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = params.to_json
      
      response = http.request(request)
      JSON.parse(response.body).symbolize_keys
    rescue => e
      { success: false, errors: [e.message] }
    end
  end

  def delete_alert_via_api(alert_id)
    begin
      uri = URI("http://localhost:3000/api/v1/alerts/#{alert_id}")
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Delete.new(uri)
      response = http.request(request)
      
      { success: response.code == '200' }
    rescue => e
      { success: false }
    end
  end
end
