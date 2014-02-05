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
      its(:base_uri) { should not_eq 'http://example.com' }
    end
  end

end
