require "dilicom_api/hub/client"

module DilicomApi
  module Hub
    class Client
      
      def get_notice(ean13, distributor)
        raise "ean13 should not be empty" if ean13.nil?
        raise "distributor should not be empty" if distributor.nil?
        end_point = '/v1/hub-numerique-api/onix/getNotice'
        params = { ean13: ean13, glnDistributor: distributor}
        basic_request(end_point, params, timeout: 180)
      end
    end
  end
end
