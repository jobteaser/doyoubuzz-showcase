require 'spec_helper'

require 'doyoubuzz/showcase'

describe Doyoubuzz::Showcase do

  let(:api_key){ 'an_api_key' }
  let(:api_secret){ 'an_api_secret' }

  describe '#new' do
    it 'should require an api key and secret key' do
      expect{ Doyoubuzz::Showcase.new }.to raise_error ArgumentError

      expect{ Doyoubuzz::Showcase.new(api_key, api_secret) }.to_not raise_error
    end
  end

  describe '#call' do
    let(:showcase){ Doyoubuzz::Showcase.new(api_key, api_secret) }
    let(:method){ '/a_method' }
    let(:arguments){ {:foo => 'bar', :zab => 'baz'} }
    let(:timestamp){ 1370534334 }

    # The timestamp is important in the request generation and the VCR handling. Here it is set at a fixed date
    before(:each) do
      time = Time.at(timestamp)
      Time.stub!(:now).and_return time
    end

    it "should compute a valid signature" do
      Doyoubuzz::Showcase.new('IuQSDLKQLSDK344590Li987', 'IuJyt42BnUiOlPM8FvB67tG').send(:compute_signature, {:apikey => 'IuQSDLKQLSDK344590Li987', :timestamp => timestamp}).should == '1dd33466d71275d06c9e17e18235c9f0'
    end

    it "should generate a valid signed api call" do
      showcase.stub!(:process_response) # We only want to check the sent parameters here
      showcase.class.should_receive(:get).with("/path", {:query => {:foo => "bar", :zab => "baz", :apikey => "an_api_key", :timestamp => timestamp, :hash => "757b04a866f1d02f077471589341ff7a"}})

      showcase.get('/path', arguments)
    end

    it "should handle HTTP verbs" do
      expect(showcase).to respond_to :get
      expect(showcase).to respond_to :post
      expect(showcase).to respond_to :put
      expect(showcase).to respond_to :delete
    end

    it "should return an explorable hash" do
      VCR.use_cassette("good_call") do
        res = showcase.get('/users')

        res.keys.should == ["users", "total", "next"]
        res["users"]["items"].first.keys.should == ["username", "email", "firstname", "lastname", "id"]
        res.users.items.first.username.should == "lvrmterjwea"
      end
    end

    it "should raise an exception on a failed call" do
      VCR.use_cassette("failed_call") do
        expect{ res = showcase.get('/users') }.to raise_error do |error|
          error.should be_a(HTTParty::ResponseError)
          error.response.should == Net::HTTPForbidden
        end
      end
    end

  end

end