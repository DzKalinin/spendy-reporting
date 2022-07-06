require 'json'
require 'yaml'
require 'sinatra'
require 'sinatra/param'
require 'google/cloud/firestore'
require 'active_support'
require 'active_support/all'

Dir["#{Dir.pwd}/lib/*.rb"].each { |f| require f }

require 'sinatra/reloader' if Settings.development?

