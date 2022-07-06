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
    spends = user_spend_aggregator.agg_spend_by('category')
    puts spends.inspect
    status 200
    { user_name: params[:user_name], spends: spends }.to_json
  end

  get '/spend_by_day' do
    param :user_name, String, required: true
    spends =user_spend_aggregator.agg_spend_by('created_at')
    puts spends.inspect
    status 200
    { user_name: params[:user_name], spends: spends }.to_json
  end

  error do
    puts env['sinatra.error'].inspect
    { message: env['sinatra.error'].message }.to_json
  end

  private

  def user_spend_aggregator
    @UserStatsAggregator ||= UserStatsAggregator.new(params[:user_name])
  end
end
