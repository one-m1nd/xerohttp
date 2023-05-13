require 'http'

module XeroHTTP
  module Feature
    # Raises exception on request/server error
    #
    # @!attribute [r] except
    #   @return [Array<Integer>]
    #
    class RaiseForStatus < HTTP::Feature
      # @param except [Array<Integer>] status codes to not raise on
      def initialize(except: [])
        @except = except
        super()
      end
      attr_reader :except

      # @param response [::HTTP::Response]
      # @return [::HTTP::Response]
      def wrap_response(response)
        return response if except.include?(response.status.code)

        raise HTTP::RequestError, response.status if response.status.client_error?
        raise HTTP::ResponseError, response.status if response.status.server_error?

        response
      end
    end
  end
end