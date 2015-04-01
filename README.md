# Saferpay

[![Gem Version](https://badge.fury.io/rb/saferpay.svg)](http://badge.fury.io/rb/saferpay) [![Build Status](https://travis-ci.org/whitesmith/saferpay-gem.svg?branch=master)](https://travis-ci.org/whitesmith/saferpay-gem)

Interact with [Saferpay](http://saferpay.com)'s HTTPS Interface with a ruby API wrapper built with HTTParty.

This gem is based on version 4.5 of Saferpay's Payment Page documentation. You can [contact Saferpay](http://saferpay.com/contact/) to get ahold of your documentation PDF (it doesn't appear to be on their website). Ask for the Payment Page integration documentation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'saferpay'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install saferpay

## Quick Start

```ruby
PAYMENT_OPTS = {'AMOUNT': '1000', 'CURRENCY': 'EUR', 'DESCRIPTION': 'You are paying for XYZ.'}

# Get the payment URL and make the user go there (display as a link in the interface or something)
    client = Saferpay::API.new
    url = client.get_payment_url(PAYMENT_OPTS)

# Once the user finishes the payment process, Saferpay calls our callback URLs
# (defined by SUCCESSLINK and NOTIFYURL)

# On the callback actions:
    client = Saferpay::API.new
    data = client.handle_pay_confirm(params, PAYMENT_OPTS) # validate and parse the callback data
    # You could store some info into your DB here

    status = client.complete_payment('ID': data[:id]) # Settle Payment
    if status[:successful]
        # Ship the goods!
    end
```

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

The `get_payment_url` method queries Saferpay for the URL where the user may pay for whatever we're selling. It returns a String.

This method has 4 required parameters: `ACCOUNT_ID`, `AMOUNT` (in cents), `CURRENCY` ([three-letter currency code](http://www.xe.com/iso4217.php)) and `DESCRIPTION`. You may include any other parameters specified in the Saferpay documentation.

The example below fetches a payment URL for a 10 Euro purchase.

```ruby
client = Saferpay::API.new
url = client.get_payment_url('AMOUNT': '1000', 'CURRENCY': 'EUR', 'DESCRIPTION': 'You are paying for XYZ.')
```

If you're working on a web app, you'll probably want to get the payment URL on your controller and place it as a *Procceed to Payment* link on your views.

### Check the Authorization Response

Once the user finishes the payment process on the payment URL we got via `get_payment_url`, the merchant is notified by either the provided `SUCCESSLINK` or `NOTIFYURL`. These notifications contain a `DATA` parameter that is XML containing the authorization response. The next step in the payment process is to make sure this XML was not tempered with. We do this with the `handle_pay_confirm` method.

This method takes in the request parameters of `SUCCESSLINK` or `NOTIFYURL` and, optionally, some of the original parameters you used in `get_payment_url`. These original parameters are important because Saferpay strongly recommends that you check `ACCOUNTID`, `AMOUNT`, `CURRENCY` and `ORDERID` (if used) for changes. This gem always checks `ACCOUNTID` for you, but its up to you to provide the other values.

```ruby
client = Saferpay::API.new
original_values = {'AMOUNT': '1000', 'CURRENCY': 'EUR', 'DESCRIPTION': 'You are paying for XYZ.'}
data = client.handle_pay_confirm(params, original_values)
```

`handle_pay_confirm` returns an Hash with the parsed contents of the `DATA` XML. If tampering is detected, an Exception will be raised identifying the problematic parameters. Below is a typical response:

```ruby
{
    msgtype:      'PayConfirm',
    token:        '(unused)',
    vtverify:     '(obsolete)',
    keyid:        '1-0',
    id:           'A668MSAprOj4tAzv7G9lAQUfUr3A',
    accountid:    '99867-94913159',
    providerid:   '90',
    providername: 'Saferpay Test Card',
    amount:       '1000',
    currency:     'EUR',
    ip:           'X.X.X.X',
    ipcountry:    'CH',
    cccountry:    'XX',
    mpi_liabilityshift: 'yes',
    mpi_tx_cavv:  'AAABBIIFmAAAAAAAAAAAAAAAAAA=',
    mpi_xid:      'CxMTYwhoUXtCBAEndBULcRIQaAY=',
    eci:          '1',
    cavv:         'AAABBIIFmAAAAAAAAAAAAAAAAAA=',
    xid:          'CxMTYwhoUXtCBAEndBULcRIQaAY='
}
```

The response depends on the options you send to `get_payment_url` and the payment method selected by the user, so check yours and use/save whatever info you think is relevant.

### Complete the Payment

The final step in the payment process is to call the `complete_payment` method. This lets Saferpay know that everything is ok on our side and that we will "ship the goods".

This method requires the purchase identifier you can find in the `:id` key from `handle_pay_confirm` response. In the example below, we'll be finalizing the purchase we verified in the [Check the Authorization Response](#check-the-authorization-response) section:

```ruby
status = client.complete_payment('ID': data[:id])

if status[:successful]
    # Ship the goods!
end
```

You can also send other parameters, including `ACTION`, that allows you to perform other actions like cancelling the purchase. Check Saferpay's documentation for more info.

`complete_payment` also returns an Hash with a boolean in the `:successful` key, a textual response to the settlement (for both successful and error states) in `:message` and other info described in Saferpay's documentation.

## Contributing

1. Fork it ( http://github.com/whitesmith/saferpay-gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
