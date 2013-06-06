require 'httparty'

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
      res = self.class.send(verb, method, :query => process_params(params))
      return process_response(res)
    end

    # Process the HTTParty response, checking for errors
    def process_response(res)
      if res['error']
        raise HTTParty::ResponseError.new(res.response)
      end

      return res
    end


    # The arguments processing and signing
    def process_params(params)
      params.merge!({:apikey => @api_key, :timestamp => Time.now.to_i})
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
