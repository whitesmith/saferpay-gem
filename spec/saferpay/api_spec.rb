require 'spec_helper'
require 'saferpay'

describe Saferpay::API do
  subject { Saferpay::API.new }
  
  describe 'configuration' do
    context 'by default' do
      Saferpay::Configuration::DEFAULTS.each do |key, val|
        its(key) { should eq(val) }
      end
    end

    context 'with a custom global configuration' do
      Saferpay::Configuration::VALID_CONFIG_KEYS.each do |key|
        before(:each) { Saferpay.configure { |config| config.send "#{key}=", key } }

        it "passes the user-defined global #{key} to the API instance" do
          expect(subject.send(key)).to eq(key)
        end
      end
    end
  end

  describe 'HTTParty configuration' do
    subject { Saferpay::API }
    
    it 'includes HTTParty' do
      expect(subject).to include(HTTParty)
    end

    context 'with default endpoint' do
      subject { Saferpay::API.new.class }
      its(:base_uri) { should eq Saferpay::Configuration::DEFAULTS[:endpoint] }
    end

    context 'with custom endpoint (via params)' do
      subject { Saferpay::API.new(:endpoint => 'http://example.com').class }
      its(:base_uri) { should_not eq 'http://example.com' }
    end
  end

  describe 'GET payment url' do

    context 'when amount is missing' do
      let (:options) { {} }
      it 'raises Missing AMOUNT error' do
        expect { subject.get_url(options) }.to raise_error(Saferpay::Error::BadRequest, 'ERROR: Missing AMOUNT attribute')
      end
    end

    context 'when currency is missing' do
      let (:options) { {'AMOUNT' => 1000} }
      it 'raises Missing CURRENCY error' do
        expect { subject.get_url(options) }.to raise_error(Saferpay::Error::BadRequest, 'ERROR: Missing CURRENCY attribute')
      end
    end

    context 'when description is missing' do
      let (:options) { {'AMOUNT' => 1000, 'CURRENCY' => 'EUR'} }
      it 'raises Missing DESCRIPTION error' do
        expect { subject.get_url(options) }.to raise_error(Saferpay::Error::BadRequest, 'ERROR: Missing DESCRIPTION attribute')
      end
    end

    context 'when amount, currency and description are defined' do
      let (:options) { {'AMOUNT' => 1000, 'CURRENCY' => 'EUR', 'DESCRIPTION' => 'Test description.'} }

      it 'does not raise an error' do
        expect { subject.get_url(options) }.not_to raise_error
      end

      describe 'the response' do
        let(:response) { subject.get_url(options) }

        it 'is an hash' do
          expect(response).to be_an Hash
        end

        it 'contains the payment url' do
          expect(response[:payment_url]).to match /^https:\/\/www.saferpay.com\/.+/
        end
      end
    end

  end

  context 'when directly accessing a non-existent URL' do

    %w(GET POST HEAD).each do |method|
      context "via #{method}" do
        it 'raises 404 NotFound error' do
          expect { subject.class.send(method.downcase, '/foobar') }.to raise_error(Saferpay::Error::NotFound, 'Not Found')
        end
      end
    end

    %w(PUT DELETE MOVE COPY).each do |method|
      context "via #{method}" do
        it 'raises 405 MethodNotAllowed error' do
          expect { subject.class.send(method.downcase, '/foobar') }.to raise_error(Saferpay::Error, 'Method Not Allowed')
        end
      end
    end
  end

end
