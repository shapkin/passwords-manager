CONFIG = YAML.load_file(Rails.root.join("config/dropbox.yml"))[Rails.env]

module Dropbox
  APP_KEY = CONFIG["app_key"]
  APP_SECRET = CONFIG["app_secret"]
  ACCESS_TYPE = CONFIG["access_type"]
end