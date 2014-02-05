require 'spec_helper'
require 'saferpay'

describe Saferpay do
  subject { Saferpay }

  after(:each) { subject.reset }
  
  describe 'configuration' do
    context 'by default' do
      Saferpay::Configuration::VALID_CONFIG_KEYS.each do |key|
        its(key) { should eq subject::Configuration.const_get("DEFAULT_#{key.upcase}") }
      end
    end

    describe '.configure' do
      Saferpay::Configuration::VALID_CONFIG_KEYS.each do |key|
        it "should set the #{key} config" do
          Saferpay.configure do |config|
            config.send("#{key}=", key)
            expect(Saferpay.send(key)).to eq(key)
          end
        end
      end
    end
  end

end
