require "http"
require "logger"

module XeroHTTP
  module Feature
    # Filtered logging feature for sensitive values and response bodies that don't make too much
    # sense in logging.
    #
    # @!attribute [r] filters
    #   @return [Array<Regexp>] filters
    #
    class FilteredLogging < HTTP::Features::Logging
      # @return [Integer] omit body from logs when body is longer than this(via Content-Length)
      BODY_TOO_LONG = 2000

      # @return [Array<String>] response body types to omit
      OMIT_TYPES = %w[application/octet-stream].freeze

      # @return [String] replacement value for when body is omittted
      BODY_OMITTED = 'BODY OMITTED'.freeze

      # @param logger [#debug, #info, #warn, #error, #fatal, #add]
      # @param filters [Array<Regexp>] filters
      def initialize(logger: NullLogger.new, filters: [])
        super(logger: logger)

        @filters = filters
      end
      attr_reader :filters

      # @param request [::HTTP::Request]
      # @return [::HTTP::Request]
      def wrap_request(request)
        logger.info { "> #{request.verb.to_s.upcase} #{request.uri}" }
        logger.debug { "#{stringify_headers(request.headers)}\n\n#{request_body_to_log(request)}" }

        request
      end

      # @param response [::HTTP::Response]
      # @return [::HTTP::Response]
      def wrap_response(response)
        logger.info { "< #{response.status}" }
        logger.debug { "#{stringify_headers(response.headers)}\n\n#{response_body_to_log(response)}" }

        response
      end

      private

      # @param headers [Array<String>]
      # @return [String]
      def stringify_headers(headers)
        headers.map do |name, value|
          next("#{name}: REDACTED") if filters.any? { |filter| filter.match?(name) }

          "#{name}: #{value}"
        end.join("\n")
      end

      # @param request [::HTTP::Request]
      # @return [#to_s]
      def request_body_to_log(request)
        return BODY_OMITTED if request.headers['Content-Length'].to_i >= BODY_TOO_LONG
        return BODY_OMITTED if OMIT_TYPES.include?(request.headers['Content-Type'])

        request.body.source
      end

      # @param response [::HTTP::Response]
      # @return [#to_s]
      def response_body_to_log(response)
        return BODY_OMITTED if response.headers['Content-Length'].to_i >= BODY_TOO_LONG
        return BODY_OMITTED if OMIT_TYPES.include?(response.headers['Content-Type'])

        response.body
      end
    end
  end
end