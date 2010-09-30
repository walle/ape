Ape::Application.routes.draw do
  resources :projects do
    resources :wiki, :tickets
  end

  root :to => 'projects#index'
end

