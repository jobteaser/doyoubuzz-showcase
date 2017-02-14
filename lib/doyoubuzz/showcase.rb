require 'httparty'
require 'hashie/mash'

require 'doyoubuzz/showcase/error'

module Doyoubuzz
  class Showcase

    include HTTParty
    base_uri 'http://showcase.doyoubuzz.com/api/v1'

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

    private

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

  end
end
