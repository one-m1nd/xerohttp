require 'http'

module XeroHTTP
  module Feature
    # Raises exception on request/server error
    class RaiseForStatus < HTTP::Feature
      # @param response [::HTTP::Response]
      # @return [::HTTP::Response]
      def wrap_response(response)
        raise HTTP::RequestError, response.status if response.status.client_error?
        raise HTTP::ResponseError, response.status if response.status.server_error?

        response
      end
    end
  end
end