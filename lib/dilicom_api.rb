require "dilicom_api/version"
require "dilicom_api/errors"
require "dilicom_api/hub/client"
require "dilicom_api/hub/api"

module DilicomApi
  def load_autoload_constants
    require 'faraday'
    require 'net/http'
    require 'net/https'
    Faraday.load_autoloaded_constants
  end
end
