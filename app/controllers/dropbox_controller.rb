require 'dropbox_sdk'
require 'csv'

class DropboxController < ApplicationController
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
    # Check if user has no dropbox session...re-direct them to authorize
    return redirect_to(action: 'authorize') unless session[:dropbox_session]

    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    client = DropboxClient.new(dbsession, Dropbox::ACCESS_TYPE) #raise an exception if session not authorized
    info = client.account_info # look up account information

    found = false
    results = client.search('', 'data')
    for i in 0..results.size-1
      if results[i]["path"] == '/data'
        found = true
        break
      end
    end
    if found
      @file = client.get_file('data')
    else
      # upload new
      client.put_file('data', File.open('lib/data'))
    end
    #if request.method != "POST"
    #  # show a file upload page
    #  render :inline => "#{info['email']} <br/><%= form_tag({:action => :upload}, :multipart => true) do %><%= file_field_tag 'file' %><%= submit_tag %><% end %>"
    #  return
    #else
    #  # upload the posted file to dropbox keeping the same name
    #  resp = client.put_file(params[:file].original_filename, params[:file].read)
    #  render :text => "Upload successful! File now at #{resp['path']}"
    #end
  end
end
