require "dilicom_api/hub/client"
require 'active_support/time'

module DilicomApi
  module Hub
    class Client
      def get_notices(param=nil, since: nil)
        end_point = '/v1/hub-numerique-api/json/getNotices'
        params = { }
        case param
        when :initialization
          params["initialization"] = nil
        when :last_connection
          params["lastConnection"] = nil
        else
          since ||= param
          raise "at least a parameter is required in #get_notices" if since.nil?
          since = since.in_time_zone(DILICOM_TIMEZONE)
          params["sinceDate"]  = since.iso8601.gsub(/\+.*/,'')
        end
        data = json_request(end_point, params, timeout: 180)
        data.has_key?('noNotice') ? [ ] : data['onixFileUrls'].map { |e| e['httpLink'] }
      end

      def all_notices(init=:initialization)
        raise ":initialization expected as argument, `#{init}` given" if init != :initialization
        get_notices(:initialization)
      end

      def latest_notices(options=:last_connection)
        get_notices(options)
      end

    end
  end
end
