require 'logger'
require 'httparty'
require 'hashie/mash'

require 'doyoubuzz/showcase/error'

module Doyoubuzz
  class Showcase
    include HTTParty
    base_uri 'http://showcase.doyoubuzz.com/api/v1'

    Hashie.logger = ::Logger.new(STDOUT)

    # Construction with mandatory api key and api secret
    def initialize(api_key, api_secret)
      @api_key = api_key
      @api_secret = api_secret
    end

    # HTTP calls => forwarded to #call_api with the verb as the first argument
    %i(get post put delete).each do |verb|
      define_method(verb) do |method, params={}|
        call_api(verb, method, params)
      end
    end

    # SSO redirection
    def sso_redirect_url(application, timestamp, sso_key, user_attributes)
      enforce_sso_attributes(user_attributes)

      params = sign_sso_params(
        user_attributes.merge(timestamp: timestamp),
        sso_key
      )
      encoded_params = URI.encode_www_form(params)

      "http://showcase.doyoubuzz.com/p/fr/#{application}/sso?#{encoded_params}"
    end

    private

    def enforce_sso_attributes(attributes)
      required = %i(email external_id firstname lastname)
      missing = required.reject { |key| attributes[key] }

      raise(
        ArgumentError,
        "Missing mandatory attributes for SSO : #{missing.join(', ')}"
      ) if missing.any?
    end

    # The actual api call
    def call_api(verb, method, params)
      res = self.class.send(
        verb,
        method,
        build_request_parameters(params, verb)
      )

      process_response(res)
    end

    # Process the HTTParty response, checking for errors
    def process_response(res)
      raise Error.new(res.code, res.body) unless res.success?

      object = res.parsed_response

      case object
      when Hash then mash(object)
      when Array then object.map(&method(:mash))
      else object
      end
    end

    def mash(object)
      Hashie::Mash.new(object)
    end

    # Build the request parameters
    def build_request_parameters(params, verb)
      additional_parameters = { apikey: @api_key, timestamp: Time.now.to_i }

      # GET, DELETE requests : the parameters are in the request query
      if %i(get delete).include?(verb)
        return { query: sign_api_params(params.merge(additional_parameters)) }
      end

      # Otherwise, they are in the body
      { body: params, query: sign_api_params(additional_parameters) }
    end

    # The arguments processing and signing
    def sign_api_params(params)
      ordered_params_values = params.sort.map { |_, v| v }
      concatenated_params_string = ordered_params_values.join
      concatenated_params_string << @api_secret

      hash = Digest::MD5.hexdigest(concatenated_params_string)
      params.merge(hash: hash)
    end

    # Different ordering
    def sign_sso_params(params, sso_key)
      # Custom ordering
      tosign = params.values_at(
        :email,
        :firstname,
        :lastname,
        :external_id,
        :"group[]",
        :user_type,
        :timestamp
      ).compact.join + sso_key

      params.merge(hash: Digest::MD5.hexdigest(tosign))
    end
  end
end
