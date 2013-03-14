require 'csv'

class DataContainer

  def self.load_data(session)
    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    return [] unless dbsession

    client = DropboxClient.new(dbsession, Dropbox::ACCESS_TYPE) #raise an exception if session not authorized

    found = false
    results = client.search('', 'data')
    for i in 0..results.size-1
      if results[i]["path"] == '/data'
        found = true
        break
      end
    end
    csv = []
    if found
      file = client.get_file('data')
      #csv = CSV.parse(file, headers: true)
      csv = CSV.parse(file)
    end
  end

  def self.save_data(session, site, login, password)
    origin_csv = self.load_data(session)
    csv_string = CSV.generate do |csv|
      # save previous data
      origin_csv.each do |row|
        csv << [row[0], row[1], row[2]]
      end
      # new row
      csv << [site, login, password]
    end
    File.open('tmp/data', 'w') { |f| f.write(csv_string) }

    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    client = DropboxClient.new(dbsession, Dropbox::ACCESS_TYPE)
    client.file_delete('data') # delete old file
    client.put_file('data', File.open('tmp/data'))
    File.delete('tmp/data')
  end

end
