require 'dropbox_sdk'

class DropboxController < ApplicationController
  before_filter :check_session, exept: :authorize

  def authorize
    if not params[:oauth_token] then
      dbsession = DropboxSession.new(Dropbox::APP_KEY, Dropbox::APP_SECRET)

      session[:dropbox_session] = dbsession.serialize #serialize and save this DropboxSession

      #pass to get_authorize_url a callback url that will return the user here
      redirect_to dbsession.get_authorize_url url_for(action: 'authorize')
    else
      # the user has returned from Dropbox
      dbsession = DropboxSession.deserialize(session[:dropbox_session])
      dbsession.get_access_token  #we've been authorized, so now request an access_token
      session[:dropbox_session] = dbsession.serialize

      redirect_to action: 'home'
    end
  end

  def home
    @csv = DataContainer.load_data(session)
  end

  def create
    errors = ''
    errors += '<div>Site is required.</div>' if params[:site].empty?
    errors += '<div>Login is required.</div>' if params[:login].empty?
    errors += '<div>Password is required.</div>' if params[:password].empty?
    redirect_to :home, flash: { error: errors } unless errors.empty?

    DataContainer.save_data(session, params[:site], params[:login], params[:password])
    redirect_to :home, flash: { success: 'Site added.' }
  end

  private

    def check_session
      # Check if user has no dropbox session...re-direct them to authorize
      return redirect_to(action: 'authorize') unless session[:dropbox_session]
    end

end
