Rails.application.routes.draw do
  # Rails 7.2 built-in health check (used by hosting providers).
  get "up" => "rails/health#show", as: :rails_health_check

  # New /v1/* prefix (subdomain already carries "api", so no /api/ needed).
  # First endpoint on this pattern; future endpoints can migrate here as
  # they're touched.
  namespace :v1 do
    namespace :fintagic do
      post "contact", to: "contact#create"
    end
  end

  namespace :api do
    namespace :v1 do
      resources :assessments, only: %i[create show], param: :token

      scope "lead-magnets/:slug", as: :lead_magnet do
        post "requests", to: "lead_magnets#create_request"
        get  "access/:token", to: "lead_magnets#access", as: :access
        get  "download/:token", to: "lead_magnets#download", as: :download
      end

      # Public outreach video viewer — lumelogics.com/v/<slug> hits this.
      get "videos/by-slug/:slug", to: "videos#show_by_slug", as: :video_by_slug

      # Public client audit deliverable — lumelogics.com/audit/<slug> hits this.
      get "audits/by-slug/:slug", to: "audits#by_slug", as: :audit_by_slug

      namespace :admin do
        get   "dashboard", to: "dashboard#index"
        patch "password",  to: "passwords#update"
        resources :sessions,     only: %i[create]
        resources :lead_magnets, except: %i[new edit], path: "lead-magnets"
        resources :leads,        only: %i[index show], param: :email,
                                 constraints: { email: %r{[^/]+} }
        resources :assessments,  only: %i[index show]
        resources :audits,        except: %i[new edit]

        namespace :outreel do
          resources :prospects do
            resources :videos,     only: %i[create]
            resources :activities, only: %i[index]
          end
          resources :videos, only: %i[show]

          post "imports/prospects", to: "imports#prospects"

          get  "batches/current", to: "batches#current"
          post "batches/new",     to: "batches#new"

          resources :smartlead_campaigns, only: %i[index], path: "smartlead/campaigns" do
            collection { post :sync }
            member do
              post :preflight
              post :push
              get  :analytics
            end
          end
        end
      end
    end
  end
end
