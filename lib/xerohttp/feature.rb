require "xerohttp/feature/filtered_logging"

module XeroHTTP
  # Features container module
  module Feature
    HTTP::Options.register_feature(:filtered_logging, FilteredLogging)
  end
end