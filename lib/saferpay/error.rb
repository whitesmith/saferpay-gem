module Saferpay
  
  class Error < StandardError
    attr_reader :code

    class << self
      # Create a new error from an HTTP response
      def from_response(response)
        message, code = parse_error(response)
        klass = errors[code] || self
        klass.new(message, code)
      end

      def errors
        @errors ||= {
          400 => Saferpay::Error::BadRequest,
          401 => Saferpay::Error::Unauthorized,
          403 => Saferpay::Error::Forbidden,
          404 => Saferpay::Error::NotFound,
          406 => Saferpay::Error::NotAcceptable,
          408 => Saferpay::Error::RequestTimeout,
          422 => Saferpay::Error::UnprocessableEntity,
          500 => Saferpay::Error::InternalServerError,
          502 => Saferpay::Error::BadGateway,
          503 => Saferpay::Error::ServiceUnavailable,
          504 => Saferpay::Error::GatewayTimeout,
        }
      end

      private

      def parse_error(response)
        if response.body =~ /^ERROR: (.+)/
          [$1.gsub(/[.?;]?$/, '').gsub('PayComplete: ', '').sub(/^[a-z]/) {|c| c.upcase}, 400]
        else
          msg = response.response.message
          msg = response.response.class.name.split('::').last.gsub('HTTP','').gsub(/[A-Z]/, ' \0').strip if msg.empty? # Net::HTTPNotFound -> Not Found
          [msg, response.code]
        end
      end

    end

    # Initializes a new Error object
    def initialize(message = '', code = nil)
      super(message)
      @code = code
    end

    # Raised if Saferpay returns a 4xx HTTP status code
    class ClientError < self; end

    # Raised if Saferpay returns the HTTP status code 400
    class BadRequest < ClientError; end

    # Raised if Saferpay returns the HTTP status code 401
    class Unauthorized < ClientError; end

    # Raised if Saferpay returns the HTTP status code 403
    class Forbidden < ClientError; end

    # Raised if Saferpay returns the HTTP status code 404
    class NotFound < ClientError; end

    # Raised if Saferpay returns the HTTP status code 406
    class NotAcceptable < ClientError; end

    # Raised if Saferpay returns the HTTP status code 408
    class RequestTimeout < ClientError; end

    # Raised if Saferpay returns the HTTP status code 422
    class UnprocessableEntity < ClientError; end

    # Raised if Saferpay returns a 5xx HTTP status code
    class ServerError < self; end

    # Raised if Saferpay returns the HTTP status code 500
    class InternalServerError < ServerError; end

    # Raised if Saferpay returns the HTTP status code 502
    class BadGateway < ServerError; end

    # Raised if Saferpay returns the HTTP status code 503
    class ServiceUnavailable < ServerError; end

    # Raised if Saferpay returns the HTTP status code 504
    class GatewayTimeout < ServerError; end
  end
end
