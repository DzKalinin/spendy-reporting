require 'json'
require 'yaml'
require 'sinatra'
require 'sinatra/param'
require 'google/cloud/firestore'
require 'active_support'
require 'active_support/all'

Time.zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
Time.zone_default = ActiveSupport::TimeZone['Eastern Time (US & Canada)']

class Settings
  def self.app
    @app ||= ::YAML.load_file('config/application.yml', aliases: true, symbolize_names: true)[env]
  end

  def self.env
    @env ||= (ENV['RACK_ENV'] || 'development').to_sym
  end

  def self.development?
    self.env == :development
  end
end
require 'sinatra/reloader' if Settings.development?

Firestore = Google::Cloud::Firestore.new(
  project_id: Settings.app[:google_project_id],
  credentials: "./config/google_key.json"
)

class AppServer < Sinatra::Base
  helpers Sinatra::Param

  set :show_exceptions, :after_handler

  configure :development do
    register Sinatra::Reloader
  end

  before do
    content_type :json
  end

  get '/' do
    { status: :ok }.to_json
  end

  get '/spend_by_category' do
    param :user_name, String, required: true
    spends = spends_arr(params[:user_name], 'category')
    status 200
    { user_name: params[:user_name], spends: spends }.to_json
  end

  get '/spend_by_day' do
    param :user_name, String, required: true
    spends = spends_arr(params[:user_name], 'created_at')
    status 200
    { user_name: params[:user_name], spends: spends.map{ |h| h.merge({ agg_field_value: h[:agg_field_value].strftime("%d %b %Y") }) } }.to_json
  end

  private

  def spends_arr(user_name, field)
    agg_field_value = ->(fields_hash, field) do
      field == 'created_at' ? Time.at(fields_hash.dig(field, :integer_value)).to_date : fields_hash.dig(field, :string_value)
    end

    Firestore.col(Settings.app[:firestore_table_name]).where("user_name", "=", user_name).get.each_with_object({}) do |doc, h|
      fields_hash = doc.fields
      field_value = agg_field_value.call(fields_hash, field)
      currency = fields_hash.dig('currency', :string_value)
      key = "#{field_value}-#{currency}"
      h[key] ||= { agg_field_value: field_value, currency: currency, amount: 0 }
      h[key][:amount] += fields_hash.dig('amount', :double_value)
    end.map { |_, v| v.merge({ amount: v[:amount].round(2) }) }&.sort_by { |h| h[:agg_field_value] } || []
  end
end
