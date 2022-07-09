ENV['RACK_ENV'] ||= 'test'

require './dependencies'
require 'rspec'
require 'timecop'

Time.zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
Time.zone_default = ActiveSupport::TimeZone['Eastern Time (US & Canada)']

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random

  Kernel.srand config.seed
end

