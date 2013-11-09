require 'spec_helper'
require 'active_support/all'
require 'json'

describe DilicomApi::Hub::Client do
  describe "#notices" do
    include_context "faraday connection"
    let(:onix_urls) {
      [
        "https://hub-dilicom.centprod.com/notices_onyx/diffusion_3025594195700_201008272128_1110247456419854240546744705832927698715.xml", 
        "https://hub-dilicom.centprod.com/notices_onyx/diffusion_3025594164342_201008272330_1256851354542405467447058329276987145685.xml"
      ]
    }
    let(:end_point) { "/v1/hub-numerique-api/json/getNotices" }
    let(:message) { 
      JSON.generate({
        onixFileUrls: [
          { "httpLink" => onix_urls[0] }, 
          { "httpLink" => onix_urls[1] }
        ],
        "returnStatus" => "OK"
      }) 
    }
    let(:nonotices) { 
      JSON.generate({
        "noNotice" => "", 
        "returnStatus" => "OK"
      })
    }
    let(:links) { }
    let(:date) { }

    it "end point should be called" do
      called = false
      set_connection do |stub|
        stub.get(end_point) do |env|   
          called = true
          [200, {}, message]
        end
      end
      links = subject.notices(since: DateTime.now)
      expect(called).to be_true
    end
    it "should return array of links" do
      set_connection do |stub|
        stub.get(end_point) do |env|   
          [200, {}, message]
        end
      end
      links = subject.notices(since: DateTime.now)
      expect(links).to be_a(Array)
      expect(links).to eq(onix_urls)
    end
    context "initialization" do
      it "should call initialization" do
        options = { }
        set_connection do |stub|
          stub.get(end_point) do |env|  
            options = env[:params]
            [200, {}, message]
          end
        end
        subject.notices(:initialization)
        expect(options).to have_key("initialization")
      end
    end
    context "since" do
      it "should call sinceDate" do
        options = { }
        set_connection do |stub|
          stub.get(end_point) do |env|  
            options = env[:params]
            [200, {}, message]
          end
        end
        date = DateTime.now
        subject.notices(since: date)
        expect(options).to have_key("sinceDate")
      end
      it "should use french timezone" do
        options = { }
        set_connection do |stub|
          stub.get(end_point) do |env|  
            options = env[:params]
            [200, {}, message]
          end
        end
        date = DateTime.now
        subject.notices(since: date)
        received = options["sinceDate"]
        zone = ActiveSupport::TimeZone.new("Europe/Paris")
        expect(date.to_i).to eq(zone.parse(received).to_i)
      end
    end
    context "last connection" do
      it "should call lastConnection" do
        options = { }
        set_connection do |stub|
          stub.get(end_point) do |env|  
            options = env[:params]
            [200, {}, message]
          end
        end
        subject.notices(:last_connection)
        expect(options).to have_key("lastConnection")
      end
    end
    context "no notices" do
      it "should return empty array" do
        set_connection do |stub|
        stub.get(end_point) do |env|   
          [200, {}, nonotices]
        end
      end
      links = subject.notices(since: DateTime.now)
      expect(links).to be_a(Array)
      expect(links).to be_empty
      end
    end
  end
end
