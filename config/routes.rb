Spree::Core::Engine.add_routes do
  namespace :admin do
    resources :reviews do
      member do
        get :approve
      end
      resources :feedback_reviews, only: [:index, :destroy]
    end
    delete 'review_image/:id' => 'product_reviews#delete_image', as: :review_image
    resource :review_settings, only: [:edit, :update]
    resources :products, only: [] do
      get :reviews, on: :member
      resources :reviews, :controller => "product_reviews" do
        member do
          get :approve
        end
      end
    end
  end
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :reviews, only: [:index, :create]
    end
  end
  resources :products, only: [] do
    resources :reviews, only: [:index, :new, :create, :show], shallow: true
  end
  post '/reviews/:review_id/feedback(.:format)' => 'feedback_reviews#create', as: :feedback_reviews


end
