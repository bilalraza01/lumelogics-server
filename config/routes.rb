Rails.application.routes.draw do
  # Rails 7.2 built-in health check (used by hosting providers).
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :assessments, only: %i[create show], param: :token

      namespace :admin do
        resources :assessments, only: %i[index]
      end
    end
  end
end
