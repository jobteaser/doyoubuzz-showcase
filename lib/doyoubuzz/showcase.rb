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
    [:get, :post, :put, :delete].each do |verb|
      define_method(verb) do |method, params = {}|
        call_api(verb, method, params)
      end
    end



    private

    # The actual api call
    def call_api(verb, method, params)
      res = self.class.send(verb, method, build_request_parameters(params, verb))
      return process_response(res)
    end

    # Process the HTTParty response, checking for errors
    def process_response(res)
      if !res.success?
        raise Error.new(res.code, res.body)
      end

      if res.is_a? Hash
        return Hashie::Mash.new(res)
      elsif res.is_a? Array
        return res.map{|item| Hashie::Mash.new(item)}
      else
        return res
      end
    end

    # Build the request parameters
    def build_request_parameters(params, verb)
      additional_parameters = {:apikey => @api_key, :timestamp => Time.now.to_i}

      # GET, DELETE requests : the parameters are in the request query
      if [:get, :delete].include? verb
        return {:query => sign_params(params.merge additional_parameters)}

      # Otherwise, they are in the body
      else
        return {:body => params, :query => sign_params(additional_parameters)}
      end
    end


    # The arguments processing and signing
    def sign_params(params)
      params[:hash] = compute_signature(params)
      params
    end

    # Computing the parameters signature hash
    # Algorithm :
    # - Order parameters by key
    # - Concatenate their values
    # - Append the current timestamp
    # - Append the api secret
    # - MD5 the resulting string
    def compute_signature(params)
      ordered_params_values = params.sort.map{|k,v|v}
      concatenated_params_string = ordered_params_values.join
      concatenated_params_string << @api_secret

      return Digest::MD5.hexdigest(concatenated_params_string)
    end

  end
end
