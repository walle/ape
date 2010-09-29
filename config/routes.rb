Ape::Application.routes.draw do
  resources :projects do
    resources :wiki
  end

  root :to => 'projects#index'
end

