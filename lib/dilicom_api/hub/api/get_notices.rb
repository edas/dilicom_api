require "dilicom_api/hub/client"
require 'active_support/time'

module DilicomApi
  module Hub
    class Client
      def notices(options)
        end_point = '/v1/hub-numerique-api/json/getNotices'
        params = { }
        case options
        when :initialization
          params["initialization"] = nil
        when :last_connection
          params["lastConnection"] = nil
        else
          if options.has_key? :since
            since = options[:since].in_time_zone(DILICOM_TIMEZONE)
            params["sinceDate"]  = since.iso8601.gsub(/\+.*/,'')
          end
        end
        data = json_request(end_point, params, timeout: 180)
        data.has_key?('noNotice') ? [ ] : data['onixFileUrls'].map { |e| e['httpLink'] }
      end
    end
  end
end
