module Doyoubuzz
  class Showcase
    class Error < ::StandardError
      attr_reader :status

      def initialize(status, response_body)
        # Try to extract a meaningful message from the error
        message = begin
          parsed_body = JSON.parse(response_body)
          parsed_body['error']['message']
        rescue  => e
          response_body
        end

        super(message)
        @status = status
      end

      def inspect
        "#<Doyoubuzz::Showcase::Error #{status}: #{message}>"
      end

    end
  end
end