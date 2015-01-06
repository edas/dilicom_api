require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'dilicom_api'
require 'active_support/all'
require 'json'

Dir[File.join(File.dirname(__FILE__),"support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # some (optional) config here
  config.formatter     = 'documentation'
end
