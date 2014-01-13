require "dilicom_api/hub/client"

module DilicomApi
  module Hub
    class Client
      
      def get_notice(ean13, distributor=nil)
        raise "ean13 should not be empty" if ean13.nil?
        end_point = '/v1/hub-numerique-api/onix/getNotice'
        params = { ean13: ean13 }
        params['glnDistributor'] = distributor unless distributor.nil?
        basic_request(end_point, params, timeout: 180)
      end
    end
  end
end
