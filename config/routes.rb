Ape::Application.routes.draw do
  resources :projects do
    resources :wiki, :except => :show
    resources :tickets
  end

  match '/projects/:project_id/wiki/*id(.:format)' => 'wiki#show', :as => 'wiki_page'

  root :to => 'projects#index'
end

