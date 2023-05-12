require "xerohttp/feature/filtered_logging"
require "xerohttp/feature/raise_for_status"

module XeroHTTP
  # Features container module
  module Feature
    HTTP::Options.register_feature(:filtered_logging, FilteredLogging)
    HTTP::Options.register_feature(:raise_for_status, RaiseForStatus)
  end
end