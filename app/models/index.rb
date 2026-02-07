class Index < ApplicationRecord
  # 데이터 유효성 검증
  validates :name, presence: true, uniqueness: true
  validates :symbol, presence: true, uniqueness: true
  validates :current_value, numericality: { greater_than: 0 }, allow_nil: true

  # 지원하는 지수들의 상수 정의
  SUPPORTED_INDICES = {
    'KOSPI' => '^KS11',      # 한국 코스피
    'KOSDAQ' => '^KQ11',     # 한국 코스닥
    'KOSPI200' => '^KS200',  # 코스피 200
    'NASDAQ' => '^IXIC',     # 나스닥 종합지수
    'SP500' => '^GSPC',      # S&P 500
    'DOW' => '^DJI',         # 다우존스
    'VIX' => '^VIX'          # 변동성 지수
  }.freeze

  # 최신 업데이트 순으로 정렬
  scope :recent, -> { order(last_updated: :desc) }
  
  # 특정 시간 이후에 업데이트된 지수들
  scope :updated_after, ->(time) { where('last_updated > ?', time) }

  # 클래스 메소드: 지원하는 모든 지수 초기화
  def self.initialize_supported_indices
    SUPPORTED_INDICES.each do |name, symbol|
      find_or_create_by(name: name) do |index|
        index.symbol = symbol
        index.source = 'yahoo_finance'
      end
    end
  end

  # 지수값 업데이트
  def update_value(new_value)
    update!(
      current_value: new_value,
      last_updated: Time.current
    )
  end

  # 지수값이 오래되었는지 확인 (5분 이상 된 경우)
  def stale?
    last_updated.nil? || last_updated < 5.minutes.ago
  end

  # 변동률 계산 (이전값과 현재값 비교, 일단 기본 구현)
  def change_percentage(previous_value = nil)
    return 0 if previous_value.nil? || current_value.nil? || previous_value.zero?
    
    ((current_value - previous_value) / previous_value * 100).round(2)
  end

  # 디스플레이용 포맷팅된 값
  def formatted_value
    return 'N/A' if current_value.nil?
    
    current_value.to_f.round(2).to_s
  end

  # Yahoo Finance에서 사용할 심볼 가져오기
  def yahoo_symbol
    symbol
  end
end
