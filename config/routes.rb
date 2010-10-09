Ape::Application.routes.draw do
  resources :projects

  # Comments
  match '/projects/:project_id/:type/comments/:id/edit(.:format)' => 'comments#edit', :as => 'edit_index_comment', :via => 'get'
  match '/projects/:project_id/:type/comments(.:format)' => 'comments#create', :as => 'index_comments', :via => 'post'
  match '/projects/:project_id/:type/comments/:id(.:format)' => 'comments#update', :as => 'index_comment', :via => 'put'
  match '/projects/:project_id/:type/comments/:id(.:format)' => 'comments#destroy', :as => 'index_comment', :via => 'delete'

  match '/projects/:project_id/:type/*type_id/comments/:id/edit(.:format)' => 'comments#edit', :as => 'edit_comment', :via => 'get'
  match '/projects/:project_id/:type/*type_id/comments(.:format)' => 'comments#create', :as => 'comments', :via => 'post'
  match '/projects/:project_id/:type/*type_id/comments/:id(.:format)' => 'comments#update', :as => 'comment', :via => 'put'
  match '/projects/:project_id/:type/*type_id/comments/:id(.:format)' => 'comments#destroy', :as => 'comment', :via => 'delete'

  # Wiki index
  match '/projects/:project_id/wiki/structure(.:format)' => 'wiki#structure', :as => 'wiki_structure', :via => 'get'
  match '/projects/:project_id/wiki(.:format)' => 'wiki#index', :as => 'wiki_index', :via => 'get'
  match '/projects/:project_id/wiki/edit(.:format)' => 'wiki#edit', :as => 'edit_wiki_index', :via => 'get'
  match '/projects/:project_id/wiki(.:format)' => 'wiki#update', :as => 'wiki_index', :via => 'put'
  match '/projects/:project_id/wiki/new(.:format)' => 'wiki#new', :as => 'new_wiki_index_page', :via => 'get'
  match '/projects/:project_id/wiki(.:format)' => 'wiki#create', :as => 'wiki_index_page', :via => 'post'
  match '/projects/:project_id/wiki/pages(.:format)' => 'wiki#pages', :as => 'wiki_index_pages', :via => 'get'
  match '/projects/:project_id/wiki/revisions(.:format)' => 'wiki#revisions', :as => 'wiki_index_revisions', :via => 'get'

  # Wiki pages
  match '/projects/:project_id/wiki/*id/pages(.:format)' => 'wiki#pages', :as => 'wiki_pages', :via => 'get'
  match '/projects/:project_id/wiki/*id/revisions(.:format)' => 'wiki#revisions', :as => 'wiki_page_revisions', :via => 'get'
  match '/projects/:project_id/wiki/*id/new(.:format)' => 'wiki#new', :as => 'new_wiki_page', :via => 'get'
  match '/projects/:project_id/wiki/*id/edit(.:format)' => 'wiki#edit', :as => 'edit_wiki_page', :via => 'get'
  match '/projects/:project_id/wiki/*id(.:format)' => 'wiki#show', :as => 'wiki_page', :via => 'get'
  match '/projects/:project_id/wiki/*id(.:format)' => 'wiki#create', :as => 'wiki_page', :via => 'post'
  match '/projects/:project_id/wiki/*id(.:format)' => 'wiki#update', :as => 'wiki_page', :via => 'put'
  match '/projects/:project_id/wiki/*id(.:format)' => 'wiki#destroy', :as => 'wiki_page', :via => 'delete'

  # Tickets
  match '/projects/:project_id/tickets(.:format)' => 'tickets#index', :as => 'tickets', :via => 'get'
  match '/projects/:project_id/tickets(.:format)' => 'tickets#create', :as => 'tickets', :via => 'post'
  match '/projects/:project_id/tickets/new(.:format)' => 'tickets#new', :as => 'new_ticket', :via => 'get'
  match '/projects/:project_id/tickets/*id/edit(.:format)' => 'tickets#edit', :as => 'edit_ticket', :via => 'get'
  match '/projects/:project_id/tickets/*id(.:format)' => 'tickets#show', :as => 'ticket', :via => 'get'
  match '/projects/:project_id/tickets/*id(.:format)' => 'tickets#update', :as => 'ticket', :via => 'put'
  match '/projects/:project_id/tickets/*id(.:format)' => 'tickets#destroy', :as => 'ticket', :via => 'delete'

  root :to => 'projects#index'
end

