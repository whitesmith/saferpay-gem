module Saferpay
  module Configuration

    DEFAULTS = {
      endpoint: 'https://www.saferpay.com/hosting',
      user_agent: 'Saferpay API Ruby Wrapper',
      account_id: '99867-94913159', # Saferpay test account
    }.freeze

    VALID_CONFIG_KEYS = DEFAULTS.keys.freeze

    # Build accessor methods for every config options so we can do this, for example: Saferpay.account_id = 'xxxxx'
    attr_accessor *VALID_CONFIG_KEYS

    def options
      @options = Hash[ * DEFAULTS.map { |key, val| [key, send(key)] }.flatten ].freeze
    end

    # Make sure we have the default values set when we get 'extended'
    def self.extended(base)
      base.reset
    end

    def reset
      options.each_pair do |key, val|
        send "#{key}=", DEFAULTS[key]
      end
    end

    def configure
      yield self
    end
  end
end
