require 'spec_helper'
require 'active_support/all'
require 'json'



describe DilicomApi::Hub::Client do
 
  # Generic get_notices tests 
  shared_examples "get_notices" do
    include_context "faraday connection" 
    let(:end_point) { "/v1/hub-numerique-api/json/getNotices" }
    let(:onix_urls) {
      [
        "https://hub-dilicom.centprod.com/notices_onyx/diffusion_3025594195700_201008272128_1110247456419854240546744705832927698715.xml", 
        "https://hub-dilicom.centprod.com/notices_onyx/diffusion_3025594164342_201008272330_1256851354542405467447058329276987145685.xml"
      ]
    }
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
    it "end point should be called" do
      called = false
      set_connection do |stub|
        stub.get(end_point) do |env|   
          called = true
          [200, {}, message]
        end
      end
      links = subject.send(method, *method_parameters)
      expect(called).to be_true
    end
    it "should return array of links" do
      set_connection do |stub|
        stub.get(end_point) do |env|   
          [200, {}, message]
        end
      end
      links = subject.send(method, *method_parameters)
      expect(links).to be_a(Array)
      expect(links).to eq(onix_urls)
    end
    context "when no notices available" do
      it "should return empty array" do
        set_connection do |stub|
          stub.get(end_point) do |env|   
            [200, {}, nonotices]
          end
        end
        links = subject.send(method, *method_parameters)
        expect(links).to be_a(Array)
        expect(links).to be_empty
      end
    end 
  end

  # Tests when call for initialization
  shared_examples "all_notices (initialization)" do
    it "should call initialization" do
      options = { }
      set_connection do |stub|
        stub.get(end_point) do |env|  
          options = env[:params]
          [200, {}, message]
        end
      end
      subject.send(method, *method_parameters)
      expect(options).to have_key("initialization")
    end
  end

  # Tests when call for latest notices
  shared_examples "latest_notices" do
    context "when ask for all notices since a date" do
      it "should call sinceDate" do
        options = { }
        set_connection do |stub|
          stub.get(end_point) do |env|  
            options = env[:params]
            [200, {}, message]
          end
        end
        date = DateTime.now
        subject.send(method, since: date)
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
        subject.send(method, since: date)
        received = options["sinceDate"]
        zone = ActiveSupport::TimeZone.new("Europe/Paris")
        expect(date.to_i).to eq(zone.parse(received).to_i)
      end
    end
    context "when ask for all notices from last connection" do
      it "should call lastConnection" do
        options = { }
        set_connection do |stub|
          stub.get(end_point) do |env|  
            options = env[:params]
            [200, {}, message]
          end
        end
        subject.send(method, :last_connection)
        expect(options).to have_key("lastConnection")
      end
    end
  end

  # Actual tests
  
  describe "#get_notices" do
    let(:method) { :get_notices }
    include_examples "get_notices" do
      let(:method_parameters) { [ since: DateTime.now ]  }
    end
    context "when called with :initialization" do
      include_examples "all_notices (initialization)" do
        let(:method_parameters) { [ :initialization ] }
      end
    end
    include_examples "latest_notices"
  end

  describe "#all_notices" do
    let(:method) { :all_notices }
    include_examples "get_notices" do
      let(:method_parameters) { [ ] }
    end
    include_examples "all_notices (initialization)" do
      let(:method_parameters) { [ ] }
    end
  end

  describe "#latest_notices" do
    let(:method) { :latest_notices }
    include_examples "get_notices" do
      let(:method_parameters) { [ since: DateTime.now ]  }
    end
    include_examples "latest_notices"
    context "when called with no parameters" do
      it "should call lastConnection" do
        options = { }
        set_connection do |stub|
          stub.get(end_point) do |env|  
            options = env[:params]
            [200, {}, message]
          end
        end
        subject.send(method)
        expect(options).to have_key("lastConnection")
      end
    end
  end
end

