# Saferpay

[![Gem Version](https://badge.fury.io/rb/saferpay.svg)](http://badge.fury.io/rb/saferpay)

A Ruby Saferpay API wrapper.

Interact with Saferpay's HTTPS Interface with an object-oriented API wrapper built with HTTParty.

## Installation

Add this line to your application's Gemfile:

    gem 'saferpay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install saferpay

## Usage

### Configuration

You can change the global configuration using the method bellow. If you're on Rails you can place this code in an initializer like `config/initializers/saferpay.rb`.

```ruby
Saferpay.configure do |config|
    config.account_id   = 'YOUR_ACCOUNT_ID'
    config.success_link = 'YOUR_SUCCESS_LINK'
end
```

Changes to the global configuration are passed down to every Saferpay client.

As of now, the available global configurations are: `endpoint`, `user_agent`, `account_id`, `success_link`, `fail_link`, `back_link` and `notify_url`. You can find the default values on [configuration.rb](lib/saferpay/configuration.rb).

You can also change configurations (except `endpoint`) on a per-client basis, on initialization:

```ruby
client = Saferpay::API.new(:success_link => 'http://example.com')
```

### Generate Payment URL

Work in progress.

### Check the Authorization Response

Work in progress.

### Finalize the Payment

Work in progress.

## Contributing

1. Fork it ( http://github.com/whitesmith/saferpay-gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
