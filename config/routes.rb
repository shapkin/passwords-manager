PasswordsManager::Application.routes.draw do

  devise_for :users

  root :to => 'dropbox#home', as: :home

  get "dropbox/authorize"
  post "dropbox/create"

end
