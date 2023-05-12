require "http"

require "xerohttp/feature"

# Root wrapper around httprb
module XeroHTTP
  extend HTTP::Chainable
  class << self
    # @param value [String] user agent
    # @return [::HTTP::Client] configured with user agent
    def user_agent(value)
      headers({ 'User-Agent' => value })
    end

    # @param logger [Logger] new logger instance
    # @param filters [Array<Regexp>] filters to use
    # @return [::HTTP::Client] configured with filtered logging
    def filtered_logging(logger = Logger.new(STDOUT), filters: [])
      use(filtered_logging: { logger: logger, filters: filters })
    end

    # @return [::HTTP::Client] configured with raise for status feature
    def raise_for_status
      use(:raise_for_status)
    end

    # @param url [String] url to download
    # @param destination [String] relative filepath to download to
    # @param write_mode [String] defaults to 'wb'
    # @yieldparam [String] chunks if block passed
    # @return [void]
    def download(url, destination, write_mode = 'wb', &per_chunk)
      terminus = File.open(destination, write_mode)

      stream(url, terminus, &per_chunk)
    end

    # @param url [String] URL to download
    # @param io [#write, #close] IO to write to, must already be open
    # @yieldparam [String] chunks if block passed
    # @return [void]
    def stream(url, io, &per_chunk)
      get(url).body.each do |chunk|
        io.write(chunk)
        per_chunk.call(chunk) if block_given?
        chunk.clear
      end
    ensure
      io.close
    end
  end
end
