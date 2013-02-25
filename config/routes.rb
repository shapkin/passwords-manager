PasswordsManager::Application.routes.draw do

  root :to => 'dropbox#authorize'

  get "dropbox/authorize"
  match 'dropbox/upload', :controller => 'dropbox', :action => 'upload'

end
