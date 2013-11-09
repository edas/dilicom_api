require 'spec_helper'
require 'json'
describe DilicomApi::Hub::Client do
  
  include_context "faraday connection"

  describe "#json_request" do
    let(:example_end_point) { "/example" }
    let(:params) { { 'a' => "1", 'b' => "2"} }
    context "http request" do
      let(:gln) { 1234 }
      let(:password) { "abcd" }
      let(:autorization_header) { ["Authorization","Basic MTIzNDphYmNk"] }
      let(:json_header) { ["Accept", "application/json"] }
      it "should send http basic auth" do
        subject.gln = gln
        subject.password = password
        headers = {}
        set_connection do |stub|
          stub.get(example_end_point) do |env|   
            headers = env[:request_headers]
            [200, {}, "{}"]
          end
        end
        json = subject.send(:json_request, "/example", {})
        expect(headers[autorization_header[0]]).to eq(autorization_header[1])
      end
      it "should send a json header" do
        headers = {}
        set_connection do |stub|
          stub.get(example_end_point) do |env|   
            headers = env[:request_headers]
            [200, {}, "{}"]
          end
        end
        json = subject.send(:json_request, "/example", {})
        expect(headers[json_header[0]]).to eq(json_header[1])
      end
      it "should send URI parameters" do
        received = {}
        set_connection do |stub|
          stub.get(example_end_point) do |env|   
            received = env[:params]
            [200, {}, "{}"]
          end
        end
        json = subject.send(:json_request, "/example", params)
        expect(received).to eq(params)
      end
    end
    context "with an HTTP error" do
      it "should raise an exception" do
        set_connection do |stub|
          stub.get(example_end_point) do |env|   
            received = env[:params]
            [400, {}, "{}"]
          end
        end
        expect{subject.send(:json_request, "/example", {})}.to raise_error
      end
    end
    context "with a non-json response" do
      it "should raise an exception" do
        set_connection do |stub|
          stub.get(example_end_point) do |env|   
            received = env[:params]
            [200, {}, "non json"]
          end
        end
        expect{subject.send(:json_request, "/example", {})}.to raise_error
      end
    end
    context "with a dilicom return status error" do
      it "should raise an exception" do
        set_connection do |stub|
          stub.get(example_end_point) do |env|   
            received = env[:params]
            [200, {}, "{\"returnStatus\":\"ERROR\"}"]
          end
        end
        expect{subject.send(:json_request, "/example", {})}.to raise_error
      end
    end
    context "for a successfull response" do
      it "should answer json" do
        set_connection do |stub|
          stub.get(example_end_point) do |env|   
            received = env[:params]
            [200, {}, JSON.dump(params)]
          end
        end
        res = subject.send(:json_request, "/example", {})
        expect(res).to eq(params)
      end
    end
  end
end
