class CreateIndices < ActiveRecord::Migration[8.0]
  def change
    create_table :indices do |t|
      # 지수명 (KOSPI, KOSDAQ, NASDAQ 등)
      t.string :name, null: false
      
      # 지수 심볼 (Yahoo Finance에서 사용하는 심볼, 예: ^KS11, ^IXIC)
      t.string :symbol, null: false
      
      # 현재 지수값
      t.decimal :current_value, precision: 15, scale: 2
      
      # 최종 업데이트 시간
      t.datetime :last_updated
      
      # 데이터 소스 (yahoo_finance, alpha_vantage 등)
      t.string :source, default: 'yahoo_finance'

      t.timestamps
    end

    # 인덱스 추가 - 빠른 조회를 위해
    add_index :indices, :name, unique: true # 지수명으로 빠른 조회
    add_index :indices, :symbol, unique: true # 심볼로 빠른 조회
    add_index :indices, :last_updated # 최신 업데이트 시간으로 정렬
  end
end
