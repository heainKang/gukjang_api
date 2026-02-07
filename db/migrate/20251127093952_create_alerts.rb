class CreateAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :alerts do |t|
      # 사용자 식별자 (로그인 시스템 없이 브라우저 세션/디바이스 ID로 구분)
      t.string :user_identifier, null: false
      
      # 모니터링할 지수명 (KOSPI, KOSDAQ, NASDAQ, SP500, DOW, VIX)
      t.string :index_name, null: false
      
      # 알림 기준값 (예: 2000 이하일 때 알림)
      t.decimal :threshold_value, precision: 10, scale: 2, null: false
      
      # 비교 타입 ('below' = 이하, 'above' = 이상)
      t.string :comparison_type, null: false, default: 'below'
      
      # 알림 활성화 여부
      t.boolean :is_active, null: false, default: true
      
      # Firebase Cloud Messaging 토큰 (푸시 알림용)
      t.text :fcm_token

      t.timestamps
    end

    # 인덱스 추가 - 빠른 조회를 위해
    add_index :alerts, [:user_identifier, :index_name] # 사용자별 지수별 알림 조회
    add_index :alerts, [:is_active, :index_name] # 활성화된 알림들만 조회
  end
end
