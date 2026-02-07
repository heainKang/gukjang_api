# 주식 지수 조회 API 컨트롤러
class Api::V1::IndicesController < Api::V1::BaseController
  
  # GET /api/v1/indices
  # 모든 지수 목록 조회
  def index
    indices = Index.all.order(:name)
    
    indices_data = indices.map do |index|
      {
        id: index.id,
        name: index.name,
        symbol: index.symbol,
        current_value: index.formatted_value,
        last_updated: index.last_updated&.strftime('%Y-%m-%d %H:%M:%S'),
        is_stale: index.stale? # 데이터가 오래되었는지 여부
      }
    end
    
    success_response(indices_data, "지수 목록 조회 성공")
  end
  
  
  # GET /api/v1/indices/:id
  # 특정 지수 상세 조회
  def show
    index = Index.find(params[:id])
    
    index_data = {
      id: index.id,
      name: index.name,
      symbol: index.symbol,
      current_value: index.current_value&.to_f,
      formatted_value: index.formatted_value,
      last_updated: index.last_updated,
      is_stale: index.stale?,
      source: index.source,
      created_at: index.created_at,
      updated_at: index.updated_at
    }
    
    success_response(index_data, "지수 상세 정보 조회 성공")
  end
  
  private
  
  # 장 상태 메시지 생성 (간단한 버전)
  def market_status_message
    current_time = Time.current
    
    # 한국 시간 기준 (UTC+9)
    korea_time = current_time.in_time_zone('Asia/Seoul')
    hour = korea_time.hour
    
    # 간단한 장 시간 체크
    if korea_time.saturday? || korea_time.sunday?
      "주말 - 장 마감"
    elsif hour >= 9 && hour < 15
      "장 시간"
    else
      "장 마감"
    end
  end
end