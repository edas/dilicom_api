require 'faraday'
require 'json'
require 'active_support/time'

module DilicomApi
  module Hub
    class Client
      DILICOM_TIMEZONE = 'Europe/Paris'
      @@servers = {
        production: 'https://hub-dilicom.centprod.com',
        test: 'https://hub-test.centprod.com'
      }

      attr_accessor :connection
      attr_writer :gln
      attr_writer :password
      attr_accessor :work_around_timezone_issues

      def initialize(gln = nil, password = nil, env: :test)
        @env = env
        @gln = gln
        @password = password
        @work_around_timezone_issues = true
        server = @@servers[env]
        fail "no server for env #{env}" if server.nil?
        connect(server) if gln && password
      end

      protected

      def work_around_timezone_issues(time, fix = :before)
        if @work_around_timezone_issues
          time = time.in_time_zone(DILICOM_TIMEZONE)
          if time.hour == 2 || (time.hour == 3 && time.min == 0 && time.sec == 0)
            if time.to_time.beginning_of_day.zone != time.to_time.end_of_day.zone
              if fix == :before
                return time.to_time.change(hour: 1, min: 59, sec: 59)
              elsif fix == :after
                return time.to_time.change(hour: 3, min: 0, sec: 1)
              end
            end
          end
        end
        time
      end

      def json_request(end_point, params = {}, timeout: nil)
        res = connection.get(end_point) do |req|
          req.headers['Accept'] = 'application/json'
          req.params = params
          req.options[:timeout] = timeout unless timeout.nil?
        end
        fail DilicomHttpError, "Dilicom returned status #{res.status} in #{end_point} with #{params}" if res.status != 200
        body = JSON.load(res.body)
        fail UnreadableMessageError, "Dilicom a returned a unreadable json for #{end_point} with #{params} : #{res.body}" if body.nil?
        fail DilicomStatusError, "Dilicom returned an error status #{body['returnStatus']} in #{end_point} with #{params} : #{body['returnMessage']}" if body.key?('returnStatus') && !%w(OK WARNING).include?(body['returnStatus'])
        body
      end

      def connect(server)
        @connection ||= ::Faraday::Connection.new(server) do |faraday|
          faraday_builder(faraday)
          # Adapter should always be last line of Faraday builder
          # otherwise at least HTTP Auth doesn't work)
          faraday.adapter Faraday.default_adapter
        end
      end

      def faraday_builder(faraday)
        faraday.use(Faraday::Request::BasicAuthentication,
                    @gln,
                    @password) if @gln && @password
      end
    end
  end
end
