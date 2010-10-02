Ape::Application.routes.draw do
  resources :projects do
    resources :tickets
  end

  match '/projects/:project_id/wiki(.:format)' => 'wiki#index', :as => 'wiki_index', :via => 'get'
  match '/projects/:project_id/wiki/edit(.:format)' => 'wiki#edit', :as => 'edit_wiki_index', :via => 'get'
  match '/projects/:project_id/wiki(.:format)' => 'wiki#update', :as => 'wiki_index', :via => 'put'
  match '/projects/:project_id/wiki/new(.:format)' => 'wiki#new', :as => 'new_wiki_index_page', :via => 'get'
  match '/projects/:project_id/wiki(.:format)' => 'wiki#create', :as => 'wiki_index_page', :via => 'post'
  match '/projects/:project_id/wiki/pages(.:format)' => 'wiki#pages', :as => 'wiki_index_pages', :via => 'get'

  match '/projects/:project_id/wiki/*id/pages(.:format)' => 'wiki#pages', :as => 'wiki_pages', :via => 'get'
  match '/projects/:project_id/wiki/*id/new(.:format)' => 'wiki#new', :as => 'new_wiki_page', :via => 'get'
  match '/projects/:project_id/wiki/*id/edit(.:format)' => 'wiki#edit', :as => 'edit_wiki_page', :via => 'get'
  match '/projects/:project_id/wiki/*id(.:format)' => 'wiki#show', :as => 'wiki_page', :via => 'get'
  match '/projects/:project_id/wiki/*id(.:format)' => 'wiki#create', :as => 'wiki_page', :via => 'post'
  match '/projects/:project_id/wiki/*id(.:format)' => 'wiki#update', :as => 'wiki_page', :via => 'put'
  match '/projects/:project_id/wiki/*id(.:format)' => 'wiki#destroy', :as => 'wiki_page', :via => 'delete'

  root :to => 'projects#index'
end

