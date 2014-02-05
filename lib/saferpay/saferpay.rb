Dir[File.dirname(__FILE__) + '/saferpay/*.rb'].each do |file|
  require file
end

module Saferpay
  extend Configuration

  class API
    include HTTParty

    base_uri Saferpay.options[:endpoint]

    # Define the same set of accessors as the Saferpay module
    attr_accessor *Configuration::VALID_CONFIG_KEYS
 
    def initialize(options = {})
      # Merge the config values from the module and those passed to the class.
      options.delete(:endpoint)
      options.delete_if { |k, v| v.nil? }
      @options = Saferpay.options.merge(options)
 
      # Copy the merged values to this client and ignore those
      # not part of our configuration
      @options.each_pair do |key, val|
        send "#{key}=", val
      end
    end

  end
end
