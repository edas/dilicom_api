require "dilicom_api/hub/client"
require 'active_support/time'

module DilicomApi
  module Hub
    class Client
      
      def get_notices(param=nil, since: nil, distributor: nil)
        if distributor
          end_point = '/v1/hub-numerique-api/json/getNoticesForDistributor'
        else
          end_point = '/v1/hub-numerique-api/json/getNotices'
        end
        params = { }
        params["glnDistributor"] = distributor if distributor
        case param
        when :initialization
          params["initialization"] = nil
        when :last_connection
          params["lastConnection"] = nil
        else
          since ||= param
          raise "at least a parameter is required in #get_notices" if since.nil?
          since = work_around_timezone_issues(since, :before)
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

      def get_notices_for_distributor(distributor, param=nil, since:nil)
        opt = { distributor: distributor }
        opt[:since] = since if since
        get_notices(param, opt)
      end

      def all_notices_for_distributor(distributor, init=:initialization)
        raise ":initialization expected as argument, `#{init}` given" if init != :initialization
        get_notices_for_distributor(distributor, :initialization)
      end

      def latest_notices_for_distributor(distributor, options=:last_connection)
        get_notices_for_distributor(distributor, options)
      end

    end
  end
end
