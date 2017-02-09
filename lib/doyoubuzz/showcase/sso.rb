module Doyoubuzz
  class Showcase
    class SSO

      BASE_URL = 'http://showcase.doyoubuzz.com'.freeze

      def initialize(application, key)
        @application = application
        @key = key
      end

      def redirect_url(locale: 'fr', timestamp:, user_attributes:)
        enforce_sso_attributes(user_attributes)

        params = sign_params(user_attributes.merge(timestamp: timestamp))
        encoded_params = URI.encode_www_form(params)

        "#{BASE_URL}/p/#{locale}/#{application}/sso?#{encoded_params}"
      end

      private

      attr_reader :application, :key

      def enforce_sso_attributes(attributes)
        required = %i(email external_id firstname lastname)
        missing = required.reject { |key| attributes[key] }

        raise(
          ArgumentError,
          "Missing mandatory attributes for SSO : #{missing.join(', ')}"
        ) if missing.any?
      end

      def sign_params(params)
        # Custom ordering
        tosign = params.values_at(
          :email,
          :firstname,
          :lastname,
          :external_id,
          :"group[]",
          :user_type,
          :timestamp
        ).compact.join + key

        params.merge(hash: Digest::MD5.hexdigest(tosign))
      end

    end
  end
end
