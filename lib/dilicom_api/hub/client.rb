require 'faraday'
require 'active_support/time'
require 'json'

module DilicomApi
  module Hub
    class Client
      DILICOM_TIMEZONE = "Europe/Paris"
      @@servers = {
        production: 'https://hub-dilicom.centprod.com',
        test: 'https://hub-test.centprod.com'
      }
      
      attr_accessor :connection
      attr_writer :gln
      attr_writer :password

      def initialize(gln=nil, password=nil, env: :test)
        @env = env
        @gln = gln
        @password = password
        server = @@servers[env]
        connect(server) if gln and password
      end

      

    protected

      def json_request(end_point, params={}, timeout: nil)
        res = connection.get(end_point) do |req|
          req.headers['Accept'] = 'application/json'
          req.params = params
          req.options[:timeout] = timeout unless timeout.nil?
        end
        raise DilicomHttpError, "Dilicom returned status #{res.status} in #{end_point} with #{params.to_s}" if res.status != 200
        body = JSON.load(res.body)
        raise UnreadableMessageError, "Dilicom a returned a unreadable json for #{end_point} with #{params.to_s} : #{res.body}" if body.nil?
        raise DilicomStatusError, "Dilicom returned an error status #{body['returnStatus']} in #{end_point} with #{params.to_s} : #{body['returnMessage']}" if body.has_key?('returnStatus') and not ['OK','WARNING'].include?(body['returnStatus']) 
        body
      end

      def connect(server)
        @connection ||= ::Faraday::Connection.new(server) do |faraday|
          faraday_builder(faraday)
          # Adapter should always be last line of Faraday builder
          # otherwise at least HTTP Auth doesn't work)
          faraday.adapter  Faraday.default_adapter
        end
      end

      def faraday_builder(faraday)
        faraday.use Faraday::Request::BasicAuthentication, @gln, @password if @gln and @password
      end

    end
  end
end
