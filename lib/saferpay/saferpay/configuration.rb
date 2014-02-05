module Saferpay
  module Configuration
    VALID_CONNECTION_KEYS = [:endpoint, :user_agent].freeze
    VALID_OPTIONS_KEYS    = [:account_id].freeze
    VALID_CONFIG_KEYS     = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

    DEFAULT_ENDPOINT    = 'https://www.saferpay.com/hosting'
    DEFAULT_USER_AGENT  = 'Saferpay API Ruby Wrapper'

    DEFAULT_ACCOUNT_ID  = '99867-94913159' # Saferpay test account

    # Build accessor methods for every config options so we can do this, for example:
    #   Saferpay.account_id = 'xxxxx'
    attr_accessor *VALID_CONFIG_KEYS

    # Make sure we have the default values set when we get 'extended'
    def self.extended(base)
      base.reset
    end

    def reset
      self.endpoint   = DEFAULT_ENDPOINT
      self.user_agent = DEFAULT_USER_AGENT

      self.account_id = DEFAULT_ACCOUNT_ID
    end

    def configure
      yield self
    end
  end
end
