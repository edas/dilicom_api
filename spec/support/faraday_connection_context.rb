require 'spec_helper'

shared_context "faraday connection" do
  
  def set_connection(&block)
    subject.connection = Faraday.new do |builder|
      subject.send(:faraday_builder, builder)
      builder.adapter :test do |stub|
        block.call(stub) if block
      end
    end
  end
 
end
