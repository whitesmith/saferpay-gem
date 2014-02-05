require 'spec_helper'
require 'saferpay'

describe Saferpay do
  subject { Saferpay }

  after(:each) { subject.reset }
  
  describe 'configuration' do
    context 'by default' do
      Saferpay::Configuration::VALID_CONFIG_KEYS.each do |key|
        its(key) { should eq subject.options[key] }
      end
    end

    describe '.configure' do
      Saferpay::Configuration::VALID_CONFIG_KEYS.each do |key|
        it "sets #{key}" do
          Saferpay.configure do |config|
            config.send("#{key}=", key)
            expect(Saferpay.send(key)).to eq(key)
          end
        end
      end
    end

    describe '.reset' do

      Saferpay::Configuration::VALID_CONFIG_KEYS.each do |key|

        it "resets #{key} to default value" do
          subject.configure { |config| config.send "#{key}=", key }
          subject.reset

          expect(subject.send(key)).to eq subject.options[key]
        end
      end
    end

    describe 'DEFAULTS hash' do

      Saferpay::Configuration::VALID_CONFIG_KEYS.each do |key|
        it "does not allow direct manipulation of #{key}" do
          expect { subject.options[key] = 'someothervalue' }.to raise_error
        end
      end
    end
  end

end
