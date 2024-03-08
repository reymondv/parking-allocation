Rails.application.routes.draw do
  # get 'parking_allocation_system/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "parking_slot#index"
  # get '/parking-system' => 'parking_allocation_system#parking_system'
  resource :parking_slot, path: 'parking-slot', except: [:show, :new, :create, :edit, :update, :destroy] do
    get '/parking-spaces', to: 'parking_slot#parking_spaces', defaults: { format: 'json' }
    get '/free-slots', to: 'parking_slot#free_slots', defaults: { format: 'json' }
    get '/occupied-slots', to: 'parking_slot#occupied_slots', defaults: { format: 'json' }
  end

  resource :vehicle, except: [:show, :new, :create, :edit, :update, :destroy] do
    post 'park', to: 'vehicle#park', defaults: { format: 'json' }
    post 'unpark', to: 'vehicle#unpark', defaults: { format: 'json' }
  end

  resource :entry_point, path: 'entry-point', except: [:show, :new, :create, :edit, :update, :destroy] do
    get '/', to: 'entry_point#entry_points', defaults: { format: 'json' }
  end
  # resource :parking_allocation_system, path: 'parking-system', except: [:index, :show, :new, :create, :edit, :update, :destroy] do
  #   get '/' => 'parking_allocation_system#parking_system'
  #   post '/park' => 'parking_allocation_system#park_vehicle'
  #   post '/unpark' => 'parking_allocation_system#unpark_vehicle'
  # end
end
