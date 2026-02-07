class Alert < ApplicationRecord
  # 데이터 유효성 검증
  validates :user_identifier, presence: true
  validates :index_name, presence: true, inclusion: { 
    in: %w[KOSPI KOSDAQ KOSPI200 NASDAQ SP500 DOW VIX],
    message: "지원되지 않는 지수입니다"
  }
  validates :threshold_value, presence: true, numericality: { greater_than: 0 }
  validates :comparison_type, presence: true, inclusion: { 
    in: %w[below above],
    message: "below 또는 above만 가능합니다"
  }

  # 비즈니스 로직 메소드들
  
  # 활성화된 알림만 조회하는 스코프
  scope :active, -> { where(is_active: true) }
  
  # 특정 지수의 활성화된 알림들 조회
  scope :for_index, ->(index_name) { active.where(index_name: index_name) }

  # 알림 조건을 만족하는지 확인
  def triggered?(current_value)
    case comparison_type
    when 'below'
      current_value <= threshold_value
    when 'above'
      current_value >= threshold_value
    else
      false
    end
  end

  # 사용자별 지수별로 중복 알림 방지 (같은 조건의 알림이 이미 있는지 확인)
  validates :index_name, uniqueness: { 
    scope: [:user_identifier, :comparison_type, :threshold_value],
    message: "동일한 조건의 알림이 이미 존재합니다"
  }

  # 알림 메시지 생성
  def notification_message(current_value)
    direction = comparison_type == 'below' ? '붕괴' : '급등'
    "[#{index_name}] #{threshold_value} #{direction}! 현재 #{current_value}입니다."
  end

  # 알림 비활성화 (발송 후 중복 방지용)
  def deactivate!
    update!(is_active: false)
  end
end
