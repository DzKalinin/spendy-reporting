require './app.rb'

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
    param :start_date, String, required: true
    param :end_date, String, required: true

    spends = user_spend_aggregator.agg_spend_by('category', start_timestamp(params[:start_date]), end_timestamp(params[:end_date]))
    puts "spend_by_category: #{spends.inspect}"
    status 200
    { user_name: params[:user_name], spends: spends }.to_json
  end

  get '/spend_by_day' do
    param :user_name, String, required: true
    param :start_date, String, required: true
    param :end_date, String, required: true

    spends = user_spend_aggregator.agg_spend_by('created_at', start_timestamp(params[:start_date]), end_timestamp(params[:end_date]))
    puts "spend_by_day: #{spends.inspect}"
    status 200
    { user_name: params[:user_name], spends: spends }.to_json
  end

  error do
    puts env['sinatra.error'].inspect
    { message: env['sinatra.error'].message }.to_json
  end

  private

  def user_spend_aggregator
    @UserStatsAggregator ||= UserSpendAggregator.new(params[:user_name])
  end

  def start_timestamp(start_time_str)
    Time.zone.parse(start_time_str).beginning_of_day.to_i
  end

  def end_timestamp(end_time_str)
    end_time = Time.zone.parse(end_time_str).end_of_day
    today_time = Time.zone.now.end_of_day
    (end_time > today_time ? today_time : end_time).to_i
  end
end
