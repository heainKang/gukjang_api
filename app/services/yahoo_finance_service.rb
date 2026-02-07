# Yahoo Finance API를 통해 주식 지수 정보를 가져오는 서비스
require 'cgi'

class YahooFinanceService
  include HTTParty
  
  # Yahoo Finance API 기본 URL
  base_uri 'https://query1.finance.yahoo.com'

  # API 요청 시간 제한 설정 (10초)
  default_timeout 10

  # 에러 클래스 정의
  class ApiError < StandardError; end
  class RateLimitError < StandardError; end

  def initialize
    # 요청 헤더 설정 (User-Agent로 브라우저인 것처럼 위장)
    @headers = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
  end

  # 특정 심볼의 현재 지수값 조회
  def fetch_quote(symbol)
    # URL 인코딩을 위해 CGI.escape 사용 (^ 등 특수문자 처리)
    encoded_symbol = CGI.escape(symbol)
    url = "/v8/finance/chart/#{encoded_symbol}"
    
    begin
      response = self.class.get(url, headers: @headers, timeout: 10)
      
      # HTTP 상태 코드 확인
      case response.code
      when 200
        parse_quote_response(response.body, symbol)
      when 429
        raise RateLimitError, "API 호출 한도 초과"
      else
        raise ApiError, "API 요청 실패: #{response.code}"
      end
      
    rescue Timeout::Error, HTTParty::Error => e
      Rails.logger.error "Yahoo Finance API 요청 실패: #{e.message}"
      raise ApiError, "네트워크 오류: #{e.message}"
    end
  end

  # 여러 심볼의 지수값을 한 번에 조회 (효율성을 위해)
  def fetch_multiple_quotes(symbols)
    # 각 심볼을 URL 인코딩하고 쉼표로 연결
    encoded_symbols = symbols.map { |symbol| CGI.escape(symbol) }
    symbol_list = encoded_symbols.join(',')
    url = "/v7/finance/quote?symbols=#{symbol_list}"
    
    begin
      response = self.class.get(url, headers: @headers, timeout: 10)
      
      case response.code
      when 200
        parse_multiple_quotes_response(response.body)
      when 429
        raise RateLimitError, "API 호출 한도 초과"
      else
        raise ApiError, "API 요청 실패: #{response.code}"
      end
      
    rescue Timeout::Error, HTTParty::Error => e
      Rails.logger.error "Yahoo Finance API 요청 실패: #{e.message}"
      raise ApiError, "네트워크 오류: #{e.message}"
    end
  end

  private

  # 단일 지수 응답 파싱
  def parse_quote_response(body, symbol)
    data = JSON.parse(body)
    
    # Yahoo Finance 응답 구조에서 현재가 추출
    chart = data.dig('chart', 'result', 0)
    return nil unless chart

    # 메타데이터에서 현재가 가져오기
    current_price = chart.dig('meta', 'regularMarketPrice')
    
    if current_price
      {
        symbol: symbol,
        current_price: current_price.to_f,
        timestamp: Time.current
      }
    else
      Rails.logger.warn "#{symbol}의 가격 정보를 찾을 수 없습니다"
      nil
    end
    
  rescue JSON::ParserError => e
    Rails.logger.error "Yahoo Finance 응답 파싱 오류: #{e.message}"
    nil
  end

  # 복수 지수 응답 파싱
  def parse_multiple_quotes_response(body)
    data = JSON.parse(body)
    
    quotes = data.dig('quoteResponse', 'result')
    return [] unless quotes&.any?

    # 각 지수의 정보를 파싱하여 배열로 반환
    quotes.filter_map do |quote|
      symbol = quote['symbol']
      price = quote['regularMarketPrice']
      
      if price
        {
          symbol: symbol,
          current_price: price.to_f,
          timestamp: Time.current
        }
      else
        Rails.logger.warn "#{symbol}의 가격 정보를 찾을 수 없습니다"
        nil
      end
    end
    
  rescue JSON::ParserError => e
    Rails.logger.error "Yahoo Finance 응답 파싱 오류: #{e.message}"
    []
  end
end