PasswordsManager::Application.routes.draw do

  root :to => 'dropbox#home'

  get "dropbox/authorize"
  post "dropbox/create"

end
