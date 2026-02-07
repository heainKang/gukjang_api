# 국장박살 앱 기본 데이터 시드
# 지원하는 모든 지수들을 데이터베이스에 초기화

puts "국장박살 앱 기본 데이터를 생성중..."

# 지원하는 지수들 생성 (Index 모델에서 정의된 SUPPORTED_INDICES 사용)
Index::SUPPORTED_INDICES.each do |name, symbol|
  index = Index.find_or_create_by!(name: name) do |i|
    i.symbol = symbol
    i.source = 'yahoo_finance'
  end
  
  puts "✅ #{name} (#{symbol}) 지수 생성 완료"
end

puts ""
puts "🎉 총 #{Index.count}개의 지수가 등록되었습니다:"
Index.all.each do |index|
  puts "   - #{index.name}: #{index.symbol}"
end

puts ""
puts "📱 이제 다음 명령어로 서버를 시작할 수 있습니다:"
puts "   rails server -p 3001"
puts ""
puts "🔧 Sidekiq 웹 UI는 다음에서 확인 가능합니다:"
puts "   http://localhost:3001/sidekiq"
puts ""
puts "💻 API 엔드포인트 예시:"
puts "   GET  http://localhost:3001/api/v1/indices/latest"
puts "   POST http://localhost:3001/api/v1/alerts"
