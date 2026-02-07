# 국장박살 API - 개발 가이드

## 프로젝트 개요
**국장박살**은 주요 주식 지수의 특정 값 도달 시 푸시 알림을 발송하는 서비스의 Rails API 백엔드입니다.

## 기능
- 주요 주식 지수 실시간 데이터 제공 (KOSPI, KOSDAQ, NASDAQ, SP500, DOW, VIX 등)
- 사용자 맞춤 알림 설정 (특정 값 이하/이상 도달 시 알림)
- Firebase Cloud Messaging을 통한 푸시 알림
- REST API 제공

## 기술 스택
- **Framework**: Ruby on Rails 8.0 (API 모드)
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq (Redis 기반)
- **External API**: Yahoo Finance
- **Push Notification**: Firebase Cloud Messaging (FCM)

## 설치 및 실행

### 1. 의존성 설치
```bash
cd /home/heain/gukjang_api
bundle install
```
npm install -g wscat 웹 소켓 설치

### 2. 데이터베이스 설정
```bash
# 데이터베이스 생성
rails db:create

# 마이그레이션 실행
rails db:migrate

# 기본 지수 데이터 생성
rails db:seed
```

### 3. 서버 실행
```bash
# 개발 서버 실행 (포트 3001)
rails server -p 3001 (sidekiq인데?)

bin/rails server 
또는 다른 포트를 사용하려면:
bin/rails server -p 3002
```
bin/rails server 재시작 - http://localhost:3000/sidekiq
bin/rails console 레일즈 콘솔
  - Rails 애플리케이션과 상호작용할 수 있는 대화형 Ruby 환경
  - 데이터베이스 조회, 모델 테스트, 백그라운드 작업 실행 등을 할 수 있어요

  bin/rails tailwindcss:build  
### 4. (선택사항) Sidekiq 실행
```bash
# 백그라운드 작업 처리용 (Redis 필요)
sidekiq
```

## API 엔드포인트
 - http://localhost:3000/ - 루트 (지수 최신값)
  - http://localhost:3000/up - 헬스체크(불필요한 HTML이나 복잡한 응답 없이 최소한의 리소스 사용)
  - http://localhost:3000/sidekiq - Sidekiq 웹 UI (백그라운드 작업 모니터링)
  - http://localhost:3000/api/v1/indices - 지수 목록
  - http://localhost:3000/api/v1/alerts - 알림 관리
### 지수 데이터 조회

#### 모든 지수 최신값 조회
```http
GET /api/v1/indices/latest
```

**응답 예시:**
```json
{
  "success": true,
  "data": {
    "indices": [
      {
        "name": "KOSPI",
        "symbol": "^KS11",
        "current_value": 3986.91,
        "formatted_value": "3986.91",
        "last_updated": "2025-11-27T12:11:30.096Z",
        "is_stale": false,
        "change_percentage": 0
      }
    ],
    "last_update_time": "2025-11-27 12:11:43",
    "market_status": "장 마감"
  },
  "message": "최신 지수 데이터 조회 성공"
}
```

### 알림 관리

#### 알림 생성
```http
POST /api/v1/alerts
Content-Type: application/json

{
  "alert": {
    "user_identifier": "user_123",
    "index_name": "KOSPI",
    "threshold_value": 2000.00,
    "comparison_type": "below",
    "fcm_token": "fcm_token_here"
  }
}
```

#### 사용자 알림 목록 조회
```http
GET /api/v1/alerts?user_identifier=user_123
```

#### 알림 수정
```http
PUT /api/v1/alerts/:id
Content-Type: application/json

{
  "alert": {
    "is_active": false
  }
}
```

#### 알림 삭제
```http
DELETE /api/v1/alerts/:id?user_identifier=user_123
```

## 지원 지수
| 지수명 | 심볼 | 설명 |
|--------|------|------|
| KOSPI | ^KS11 | 한국 코스피 |
| KOSDAQ | ^KQ11 | 한국 코스닥 |
| KOSPI200 | ^KS200 | 코스피 200 |
| NASDAQ | ^IXIC | 나스닥 종합지수 |
| SP500 | ^GSPC | S&P 500 |
| DOW | ^DJI | 다우존스 |
| VIX | ^VIX | 변동성 지수 |

## 개발 테스트

### Yahoo Finance 서비스 테스트
```ruby
# Rails 콘솔에서
service = YahooFinanceService.new
quote = service.fetch_quote('^GSPC')  # S&P 500 조회
puts quote.inspect
```

### 지수 데이터 수동 업데이트
```ruby
# Rails 콘솔에서 모든 지수 업데이트
service = YahooFinanceService.new
Index.all.each do |index|
  quote = service.fetch_quote(index.symbol)
  index.update_value(quote[:current_price]) if quote
end
```

## 프로젝트 구조

```
app/
├── controllers/api/v1/     # API 컨트롤러
├── models/                 # 데이터 모델
├── services/              # 비즈니스 로직 서비스
└── workers/               # 백그라운드 작업

config/
├── initializers/          # 설정 파일들
└── routes.rb             # API 라우팅

db/
├── migrate/              # 데이터베이스 마이그레이션
└── seeds.rb             # 기본 데이터
```

## 다음 단계
1. Redis 설치 및 Sidekiq 설정으로 자동 지수 업데이트
2. FCM 서버 키 설정으로 실제 푸시 알림 기능 활성화
3. Next.js 프론트엔드 개발
4. PWA 설정 및 모바일 최적화

## 참고사항
- 현재는 개발 환경용 설정입니다
- 프로덕션 배포 시 환경변수 설정 필요
- API 호출 제한 고려하여 Yahoo Finance 호출 간격 조절 필요


==========================================================================================================


● 🧨 gukjang_api (국장박살 API) - 프로젝트 분석

  📋 프로젝트 개요

  gukjang_api는 주식 시장 지수 모니터링 및 실시간 알림 서비스를 제공하는 Rails 8.0 API 서버입니다.사용자가 설정한 임계값에 따라 주식 지수가      
  급등/급락할 때 FCM 푸시 알림을 발송하는 시스템입니다.

  ---
  🏗 아키텍처 구조

  기술 스택

  - Backend: Ruby on Rails 8.0 (API 모드)
  - Database: PostgreSQL
  - Background Jobs: Sidekiq + Redis
  - External API: Yahoo Finance API
  - Push Notifications: Firebase Cloud Messaging (FCM)
  - Deployment: Docker + Kamal

  핵심 컴포넌트

  1. 모델 (Models)

  - Alert (app/models/alert.rb:1): 사용자 알림 설정 관리
  - Index (app/models/index.rb:1): 주식 지수 정보 저장

  2. API 컨트롤러 (Controllers)

  - AlertsController (app/controllers/api/v1/alerts_controller.rb:2): 알림 CRUD API
  - IndicesController (app/controllers/api/v1/indices_controller.rb:2): 지수 조회 API
  - FcmTokensController (app/controllers/api/v1/fcm_tokens_controller.rb:2): FCM 토큰 관리

  3. 서비스 & 워커

  - YahooFinanceService (app/services/yahoo_finance_service.rb:4): Yahoo Finance API 연동
  - FcmNotificationWorker (app/workers/fcm_notification_worker.rb:2): FCM 푸시 알림 발송
  - IndexFetchWorker: 주기적 지수 데이터 수집 (예상)

  ---
  🔄 시스템 흐름도

  graph TB
      A[모바일 앱] --> B[gukjang_api]
      B --> C{API 요청 분류}

      C -->|알림 설정| D[AlertsController]
      C -->|지수 조회| E[IndicesController]
      C -->|FCM 토큰| F[FcmTokensController]

      D --> G[Alert Model]
      E --> H[Index Model]
      F --> G

      I[Sidekiq Scheduler] -->|주기적 실행| J[IndexFetchWorker]
      J --> K[YahooFinanceService]
      K -->|Yahoo Finance API| L[외부 API]
      L --> K
      K --> H

      H -->|임계값 체크| M{알림 조건 만족?}
      M -->|Yes| N[FcmNotificationWorker]
      M -->|No| O[대기]

      N --> P[FCM Service]
      P --> Q[푸시 알림 발송]
      Q --> A

  ---
  📊 데이터베이스 스키마

  alerts 테이블 (db/schema.rb:17)

  | 필드              | 타입      | 설명                       |
  |-----------------|---------|--------------------------|
  | user_identifier | string  | 사용자 식별자                  |
  | index_name      | string  | 지수명 (KOSPI, NASDAQ 등)    |
  | threshold_value | decimal | 임계값                      |
  | comparison_type | string  | 비교 유형 ('below', 'above') |
  | is_active       | boolean | 활성화 상태                   |
  | fcm_token       | text    | FCM 토큰                   |

  indices 테이블 (db/schema.rb:30)

  | 필드            | 타입       | 설명               |
  |---------------|----------|------------------|
  | name          | string   | 지수명              |
  | symbol        | string   | Yahoo Finance 심볼 |
  | current_value | decimal  | 현재값              |
  | last_updated  | datetime | 마지막 업데이트 시간      |
  | source        | string   | 데이터 소스           |

  ---
  🚀 주요 API 엔드포인트

  알림 관리

  - GET /api/v1/alerts - 알림 목록 조회
  - POST /api/v1/alerts - 새 알림 생성
  - PUT /api/v1/alerts/:id - 알림 수정
  - DELETE /api/v1/alerts/:id - 알림 삭제

  지수 조회

  - GET /api/v1/indices - 모든 지수 목록 최신 지수 데이터 (메인 API)
  - GET /api/v1/indices/:id - 특정 지수 상세

  FCM 토큰 관리

  - POST /api/v1/register_token - FCM 토큰 등록
  - DELETE /api/v1/register_token - FCM 토큰 삭제

  ---
  🎯 지원 지수 목록 (app/models/index.rb:8)

  - KOSPI (^KS11)
  - KOSDAQ (^KQ11)
  - KOSPI200 (^KS200)
  - NASDAQ (^IXIC)
  - S&P 500 (^GSPC)
  - DOW (^DJI)
  - VIX (^VIX)

  ---
  ⚙️ 백그라운드 작업 시스템

  Sidekiq + Redis 기반

  1. 지수 데이터 수집: 주기적으로 Yahoo Finance API 호출
  2. 알림 조건 체크: 임계값 비교 후 FCM 발송
  3. 푸시 알림 처리: 비동기 FCM 알림 발송

  에러 핸들링

  - API 호출 실패 시 재시도 로직
  - 무효한 FCM 토큰 자동 비활성화
  - Rate Limit 초과 시 대기 처리

  ---

● Update Todos
  ⎿  ☒ gukjang_api 프로젝트 구조 파악
     ☒ 주요 파일들 분석 (package.json, README 등)
     ☒ API 엔드포인트 구조 파악
     ☒ 데이터베이스 스키마 분석
     ☒ 아키텍처 및 흐름도 정리

● 💡 핵심 비즈니스 로직

  알림 트리거 조건 (app/models/alert.rb:23)

  def triggered?(current_value)
    case comparison_type
    when 'below'
      current_value <= threshold_value  # 하락 알림
    when 'above'
      current_value >= threshold_value  # 상승 알림
    end
  end

  데이터 신선도 체크 (app/models/index.rb:43)

  def stale?
    last_updated.nil? || last_updated < 5.minutes.ago
  end

  ---
  이 시스템은 실시간 주식 지수 모니터링과 조건부 푸시 알림을 통해 투자자들에게 시장 변동 정보를 즉시 전달하는 고성능 알림 서비스입니다!


 ==========================================================================================================

  백엔드 API의 알람 기능 테스트 방법들:

  1. 실시간 알람 (WebSocket/SSE)

  # WebSocket 연결 테스트
  wscat -c ws://localhost:3000/cable

  # Server-Sent Events 테스트
  curl -N http://localhost:3000/api/v1/notifications/stream

  2. 푸시 알람 (FCM/APNS)

  - Postman: FCM 토큰으로 푸시 발송 API 테스트
  - Firebase Console: 직접 테스트 메시지 발송
  - 개발자 도구: 브라우저에서 푸시 권한 확인

  3. 이메일/SMS 알람

  # 이메일 발송 API 테스트
  POST /api/v1/notifications/email

  # 개발환경: letter_opener로 브라우저에서 확인
  # 또는 MailCatcher 사용

  4. 알람 설정 API

  - CRUD 테스트: 알람 on/off, 타입별 설정
  - 스케줄링: Sidekiq Web UI에서 예약된 작업 확인