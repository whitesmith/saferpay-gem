# Saferpay

[![Gem Version](https://badge.fury.io/rb/saferpay.svg)](http://badge.fury.io/rb/saferpay)

A Ruby Saferpay API wrapper.

Interact with Saferpay's HTTPS Interface with an object-oriented API wrapper built with HTTParty.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'saferpay'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install saferpay

## Usage

### Configuration

You can change the global configuration using the method below. If you're on Rails you can place this code in an initializer like `config/initializers/saferpay.rb`.

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
client = Saferpay::API.new(success_link: 'http://example.com')
```

### Generate Payment URL

The `get_url` method queries Saferpay for the URL where the user may pay for whatever we're selling. This method has 4 required parameters: `ACCOUNT_ID`, `AMOUNT` (in cents), `CURRENCY` ([three-letter currency code](http://www.xe.com/iso4217.php)) and `DESCRIPTION`.

The example below fetches a payment URL for a 10 Euro purchase.

```ruby
client = Saferpay::API.new
url = client.get_url('AMOUNT': '1000', 'CURRENCY': 'EUR', 'DESCRIPTION': 'You are paying for the Foo Bar product.')
```

If you're working on a web app, you'll probably want to get the payment URL on your controller and place it as a *Procceed to Payment* link on your views.

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
