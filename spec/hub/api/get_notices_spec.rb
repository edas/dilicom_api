require 'spec_helper'

describe DilicomApi::Hub::Client do
 
  # Generic get_notices tests 
  shared_examples "get_notices" do
    include_context "faraday connection" 
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
      expect(called).to be true
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
        params = method_parameters
        params << { since: date }
        subject.send(method, *params)
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
        params = method_parameters
        params << { since: date }
        subject.send(method, *params)
        received = options["sinceDate"]
        zone = ActiveSupport::TimeZone.new("Europe/Paris")
        expect(date.to_i).to eq(zone.parse(received).to_i)
      end
      context "when since is during a daylight saving change" do
        it "should call with a sinceDate before the change " do
          options = { }
          set_connection do |stub|
            stub.get(end_point) do |env|  
              options = env[:params]
              [200, {}, message]
            end
          end
          date = Time.new(2013,10,27,12,30,0).in_time_zone("Europe/Paris").change(hour:2, min:30)
          params = method_parameters
          params << { since: date }
          subject.send(method, *params)
          expect(options).to have_key("sinceDate")
          expect(options["sinceDate"]).to match(/^2013-10-27T01:59/)
        end
      end
      context "when since is after a daylight saving change" do
        it "should call with a sinceDate without change " do
          options = { }
          set_connection do |stub|
            stub.get(end_point) do |env|  
              options = env[:params]
              [200, {}, message]
            end
          end
          date = Time.new(2013,10,27,12,30,0).in_time_zone("Europe/Paris").change(hour:12, min:30)
          params = method_parameters
          params << { since: date }
          subject.send(method, *params)
          expect(options).to have_key("sinceDate")
          expect(options["sinceDate"]).to match(/^2013-10-27T12:30/)
        end
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
        params = method_parameters
        params << :last_connection
        subject.send(method, *params)
        expect(options).to have_key("lastConnection")
      end
    end
  end

  shared_examples "with_distributor" do
    it "should send the distributor" do
      options = { }
      set_connection do |stub|
        stub.get(end_point) do |env|  
          options = env[:params]
          [200, {}, message]
        end
      end
      subject.send(method, *method_parameters)
      expect(options).to have_key("glnDistributor")
      expect(options["glnDistributor"]).to eq(gln_distributor)
    end
  end

  # Actual tests
  context "when no distributor targeted" do
    let(:end_point) { "/v1/hub-numerique-api/json/getNotices" }
    
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
      context "latest_notices" do
        include_examples "latest_notices" do
          let(:method_parameters) { [ ] }
        end
      end
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
      include_examples "latest_notices" do
        let(:method_parameters) { [ ]  }
      end
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

    context "when a distributor is targeted" do
      let(:end_point) { "/v1/hub-numerique-api/json/getNoticesForDistributor" }
      let(:gln_distributor) { "321" }

      describe "#get_notices_for_distributor" do
        let(:method) { :get_notices_for_distributor }  
        include_examples "get_notices" do
          let(:method_parameters) { [ gln_distributor, since: DateTime.now ]  }
        end
        context "when called with :initialization" do
          include_examples "all_notices (initialization)" do
            let(:method_parameters) { [ gln_distributor, :initialization ] }
          end
        end
        context "latest_notices" do
          include_examples "latest_notices" do
            let(:method_parameters) { [ gln_distributor ] }
          end
        end
        include_examples "with_distributor" do
          let(:method_parameters) { [ gln_distributor, since: DateTime.now ] }
        end
      end

      describe "#all_notices_for_distributor" do
        let(:method) { :all_notices_for_distributor }
        let(:method_parameters) { [ gln_distributor ] }
        include_examples "get_notices"
        include_examples "all_notices (initialization)"
        include_examples "with_distributor"
      end

      describe "#latest_notices_for_distributor" do
        let(:method) { :latest_notices_for_distributor }
        include_examples "get_notices" do
          let(:method_parameters) { [ gln_distributor, since: DateTime.now ]  }
        end
        include_examples "with_distributor" do
          let(:method_parameters) { [ gln_distributor, since: DateTime.now ]  }
        end
        include_examples "latest_notices" do
          let(:method_parameters) { [ gln_distributor ]  }
        end
        context "when called with no parameters" do
          it "should call lastConnection" do
            options = { }
            set_connection do |stub|
              stub.get(end_point) do |env|  
                options = env[:params]
                [200, {}, message]
              end
            end
            subject.send(method, gln_distributor)
            expect(options).to have_key("lastConnection")
          end
        end
      end

    end

  end
end

