require 'spec_helper'

require 'doyoubuzz/showcase/sso'

RSpec.describe Doyoubuzz::Showcase::SSO, type: :type do
  let(:application) { 'example_application' }
  let(:key) { 'vpsdihgfdso' }

  subject { described_class.new(application, key) }

  describe '#new' do
    it 'requires an application name and an sso key' do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new(application, key) }.not_to raise_error
    end
  end

  describe '#redirect_url' do
    let(:timestamp) { 1370534334 }
    let(:user_attributes) do
      {
        email: 'email@host.tld',
        firstname: 'John',
        lastname: 'Doe',
        external_id: 12345
      }
    end

    it 'verifies all the mandatory user attributes are given' do
      user_attributes.keys.each do |mandatory_key|
        incomplete_attributes = user_attributes.reject { |k, _| k == mandatory_key }

        expect do
          subject.redirect_url(
            timestamp: timestamp,
            user_attributes: incomplete_attributes
          )
        end.to raise_error(
          ArgumentError,
          "Missing mandatory attributes for SSO : #{mandatory_key}"
        )
      end
    end

    it 'computes the right url' do
      expect(
        subject.redirect_url(
          timestamp: timestamp,
          user_attributes: user_attributes
        )
      ).to eq('http://showcase.doyoubuzz.com/p/fr/example_application/sso?email=email%40host.tld&firstname=John&lastname=Doe&external_id=12345&timestamp=1370534334&hash=94a0adad0a9bafdf511326cae3bf7626')
    end
  end
end
