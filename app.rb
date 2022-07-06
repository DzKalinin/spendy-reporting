ENV["RACK_ENV"] ||= 'development'
require './dependencies'

Time.zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
Time.zone_default = ActiveSupport::TimeZone['Eastern Time (US & Canada)']

Firestore = Google::Cloud::Firestore.new(
  project_id: Settings.app[:google_project_id],
  credentials: "./config/google_key.json"
)
