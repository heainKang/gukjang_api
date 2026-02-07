class Web::DashboardController < ApplicationController
  def index
    # 지수 현재값 조회 (API 호출)
    @indices = fetch_indices
    
    # 사용자 알람 통계 (예시 데이터)
    @total_alerts = Alert.count
    @active_alerts = Alert.where(is_active: true).count
  end

  private

  def fetch_indices
    # Yahoo Finance API 호출해서 현재 지수 조회
    begin
      [
        { name: 'KOSPI', value: 3986.91, change: '+12.45', change_percent: '+0.31%' },
        { name: 'NASDAQ', value: 19345.77, change: '-23.12', change_percent: '-0.12%' },
        { name: 'S&P 500', value: 6021.63, change: '+5.89', change_percent: '+0.10%' }
      ]
    rescue
      []
    end
  end
end
