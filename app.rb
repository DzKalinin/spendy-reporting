ENV['RACK_ENV'] ||= 'development'
require './dependencies'

Time.zone = ActiveSupport::TimeZone['UTC']
Time.zone_default = ActiveSupport::TimeZone['UTC']

Firestore = Google::Cloud::Firestore.new(
  project_id: Settings.app[:google_project_id],
  credentials: './config/google_key.json'
)
