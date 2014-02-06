Dir[File.dirname(__FILE__) + '/saferpay/*.rb'].each do |file|
  require file
end

module Saferpay
  extend Configuration

  class API
    include HTTParty

    base_uri Saferpay.options[:endpoint]

    class << self

      # Check every response for errors and raise
      def perform_request(http_method, path, options, &block)
        response = super(http_method, path, options, &block)
        check_response(response)
        response
      end

      def check_response(response)
        raise Saferpay::Error.from_response(response) if response_errors?(response)
      end

      def response_errors?(response)
        response.body =~ /^ERROR: .+/ || !response.response.is_a?(Net::HTTPSuccess)
      end

    end

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

    # Returns an hash with the payment url (:payment_url key)
    # Raises an error if missing parameters
    def get_url(params = {})
      params.merge!(default_params)
      parse_get_url_response self.class.get('/CreatePayInit.asp', :query => params)
    end

    private

    def parse_get_url_response(resp)
      { :payment_url => resp.body }
    end

    def default_params
      {
        'ACCOUNTID' => @options[:account_id],
      }
    end

  end
end
