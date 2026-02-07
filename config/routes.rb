Rails.application.routes.draw do
  # 웹 UI 라우트
  namespace :web do
    root "dashboard#index"
    get "dashboard", to: "dashboard#index"
    get "alerts/new", to: "alerts#new"
    resources :alerts, except: [:new]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq 웹 UI - 백그라운드 작업 모니터링용
  # http://localhost:3001/sidekiq 에서 접근 가능
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  # API 라우트들 (v1 버전)
  namespace :api do
    namespace :v1 do
      # 알림 관리 API
      resources :alerts, only: [:create, :index, :update, :destroy]
      
      # 지수 현재값 조회 API
      resources :indices, only: [:index, :show]

      # FCM 토큰 등록 API
      post :register_token, to: "fcm_tokens#create"
      delete :register_token, to: "fcm_tokens#destroy"
    end
  end

  # Defines the root path route ("/")
  root "web/dashboard#index" # 웹 대시보드를 기본 페이지로 설정
end
