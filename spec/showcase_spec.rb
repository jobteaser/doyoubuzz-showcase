require 'spec_helper'

require 'doyoubuzz/showcase'

describe Doyoubuzz::Showcase do

  let(:api_key){ 'an_api_key' }
  let(:api_secret){ 'an_api_secret' }
  let(:showcase){ Doyoubuzz::Showcase.new(api_key, api_secret) }

  describe '#new' do
    it 'should require an api key and secret key' do
      expect{ Doyoubuzz::Showcase.new }.to raise_error ArgumentError

      expect{ Doyoubuzz::Showcase.new(api_key, api_secret) }.to_not raise_error
    end
  end

  describe '#call' do
    let(:arguments){ {:foo => 'bar', :zab => 'baz'} }
    let(:timestamp){ 1370534334 }

    # The timestamp is important in the request generation and the VCR handling. Here it is set at a fixed date
    before(:each) do
      time = Time.at(timestamp)
      allow(Time).to receive(:now).and_return time
    end

    it "should compute a valid signature" do
      Doyoubuzz::Showcase.new('IuQSDLKQLSDK344590Li987', 'IuJyt42BnUiOlPM8FvB67tG').send(:compute_signature, {:apikey => 'IuQSDLKQLSDK344590Li987', :timestamp => timestamp}, 'IuJyt42BnUiOlPM8FvB67tG').should == '1dd33466d71275d06c9e17e18235c9f0'
    end

    it "should generate a valid signed api call" do
      allow(showcase).to receive(:process_response) # We only want to check the sent parameters here
      showcase.class.should_receive(:get).with("/path", {:query => {:foo => "bar", :zab => "baz", :apikey => "an_api_key", :timestamp => timestamp, :hash => "757b04a866f1d02f077471589341ff7a"}})

      showcase.get('/path', arguments)
    end

    it "should put the parameters in the body for PUT requests" do
      allow(showcase).to receive(:process_response) # We only want to check the sent parameters here
      showcase.class.should_receive(:put).with("/path", {:query => {:apikey => "an_api_key", :timestamp => timestamp, :hash => "11a68a1bb9e23c681438efb714c9ad4d"}, :body => {:foo => "bar", :zab => "baz"}})

      showcase.put('/path', arguments)
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


    it "should handle array responses" do
      VCR.use_cassette("good_call") do
        res = showcase.get('/tags')

        res.should be_a Array
        res.first.should be_a Hashie::Mash
      end
    end


    it "should raise an exception on a failed call" do
      VCR.use_cassette("failed_call") do
        expect{ res = showcase.get('/users') }.to raise_error do |error|
          error.should be_a(Doyoubuzz::Showcase::Error)
          error.status.should == 403
          error.message.should == "Forbidden"
          error.inspect.should == "#<Doyoubuzz::Showcase::Error 403: Forbidden>"
        end
      end
    end

  end


  describe '#sso_redirect_url' do

    let(:company_name){ 'my_company' }
    let(:timestamp){ 1370534334 }
    let(:user_attributes){ 
      {
        email: 'email@host.tld',
        firstname: 'John',
        lastname: 'Doe',
        external_id: 12345
      }
    }
    let(:sso_key){ 'vpsdihgfdso' }

    it "should verify all the mandatory user attributes are given" do

      user_attributes.keys.each do |mandatory_key|

        incomplete_attributes = user_attributes.dup.tap{|attrs|attrs.delete mandatory_key}
        expect { showcase.sso_redirect_url(company_name, timestamp, sso_key, incomplete_attributes) }.to raise_error ArgumentError, "Missing mandatory attributes for SSO : #{mandatory_key}"

      end

    end

    it "should compute the right url" do
      showcase.sso_redirect_url(company_name, timestamp, sso_key, user_attributes).should == 'http://showcase.doyoubuzz.com/p/fr/my_company/sso?email=email%40host.tld&firstname=John&lastname=Doe&external_id=12345&timestamp=1370534334&hash=d6bbfc7ead803a3578887d6429d60047'
    end

  end

end