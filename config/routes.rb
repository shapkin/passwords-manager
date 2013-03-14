PasswordsManager::Application.routes.draw do

  root :to => 'dropbox#home', as: :home

  get "dropbox/authorize"
  post "dropbox/create"

end
