require 'spec_helper'
require 'saferpay'

describe Saferpay::API do
  subject { Saferpay::API.new }

  before do
    VCR.insert_cassette 'saferpay_api', :record => :new_episodes
  end
 
  after do
    VCR.eject_cassette
  end
  
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
        expect { subject.get_url(options) }.to raise_error(Saferpay::Error::BadRequest, 'Missing AMOUNT attribute')
      end
    end

    context 'when currency is missing' do
      let (:options) { {'AMOUNT' => 1000} }
      it 'raises Missing CURRENCY error' do
        expect { subject.get_url(options) }.to raise_error(Saferpay::Error::BadRequest, 'Missing CURRENCY attribute')
      end
    end

    context 'when description is missing' do
      let (:options) { {'AMOUNT' => 1000, 'CURRENCY' => 'EUR'} }
      it 'raises Missing DESCRIPTION error' do
        expect { subject.get_url(options) }.to raise_error(Saferpay::Error::BadRequest, 'Missing DESCRIPTION attribute')
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

  describe 'GET verify pay confirm' do

    context 'when data is missing' do
      let (:options) { {} }
      it 'raises Missing DATA error' do
        expect { subject.handle_pay_confirm(options) }.to raise_error(Saferpay::Error::BadRequest, 'Missing DATA attribute')
      end
    end

    context 'when signature is missing' do
      let (:options) { {'DATA' => 'test-data'} }
      it 'raises Missing SIGNATURE error' do
        expect { subject.handle_pay_confirm(options) }.to raise_error(Saferpay::Error::BadRequest, 'Missing SIGNATURE attribute')
      end
    end

    context 'when data and signature are defined' do

      context 'when data is not valid XML' do
        let (:options) { {'DATA' => 'test-data', 'SIGNATURE' => 'test-signature'} }
        it 'raises could not load DATA XML error' do
          expect { subject.handle_pay_confirm(options) }.to raise_error(Saferpay::Error::BadRequest, 'Could not load DATA XML')
        end
      end

      context 'when data and signature don\'t match' do
        let (:options) { {'DATA' => URI.encode('<IDP MSGTYPE="PayConfirm" TOKEN="(unused)" VTVERIFY="(obsolete)" KEYID="1-0" ID="A668MSAprOj4tAzv7G9lAQUfUr3A" ACCOUNTID="99867-94913159" PROVIDERID="90" PROVIDERNAME="Saferpay Test Card" ORDERID="123456789-001" AMOUNT="1000" CURRENCY="EUR" IP="193.247.180.193" IPCOUNTRY="CH" CCCOUNTRY="XX" MPI_LIABILITYSHIFT="yes" MPI_TX_CAVV="AAABBIIFmAAAAAAAAAAAAAAAAAA=" MPI_XID="CxMTYwhoUXtCBAEndBULcRIQaAY=" ECI="1" CAVV="AAABBIIFmAAAAAAAAAAAAAAAAAA=" XID="CxMTYwhoUXtCBAEndBULcRIQaAY=" />'), 'SIGNATURE' => 'test-signature'} }
        it 'raises generic error' do
          expect { subject.handle_pay_confirm(options) }.to raise_error(Saferpay::Error::BadRequest, 'An Error occurred')
        end
      end

      context 'when data and signature match' do
        let (:options) { {'DATA' => URI.encode('<IDP MSGTYPE="PayConfirm" TOKEN="(unused)" VTVERIFY="(obsolete)" KEYID="1-0" ID="A668MSAprOj4tAzv7G9lAQUfUr3A" ACCOUNTID="99867-94913159" PROVIDERID="90" PROVIDERNAME="Saferpay Test Card" ORDERID="123456789-001" AMOUNT="1000" CURRENCY="EUR" IP="193.247.180.193" IPCOUNTRY="CH" CCCOUNTRY="XX" MPI_LIABILITYSHIFT="yes" MPI_TX_CAVV="AAABBIIFmAAAAAAAAAAAAAAAAAA=" MPI_XID="CxMTYwhoUXtCBAEndBULcRIQaAY=" ECI="1" CAVV="AAABBIIFmAAAAAAAAAAAAAAAAAA=" XID="CxMTYwhoUXtCBAEndBULcRIQaAY=" />'), 'SIGNATURE' => '7b2bb163f4ef86d969d992b4e2d61ad48d3b9022e0ec68177e35fe53184e6b3399730d1a3641d2a984ce38699daad72ab006d5d6a9565c5ae1cff8bdc8a1eb63'} }
        
        it 'does not raise an error' do
          expect { subject.handle_pay_confirm(options) }.not_to raise_error
        end

        describe 'the response' do
          let(:response) { subject.handle_pay_confirm(options) }

          it 'is an hash' do
            expect(response).to be_an Hash
          end

          it 'contains the id' do
            expect(response[:id]).to match /\w{28}/
          end

          it 'contains callback data' do
            expect(response[:callback_data]).not_to be_nil
          end

          describe 'the callback data' do
            let(:callback_data) { response[:callback_data] }

            it 'is an hash' do
              expect(callback_data).to be_an Hash
            end

            it 'contains normalized keys' do
              expect(callback_data.keys).to eq([:data, :signature])
            end

            it 'contains the XML data' do
              expect(callback_data[:data]).to be_an Hash
            end

            it 'contains the expected Message Type' do
              expect(callback_data[:data][:msgtype]).to eq 'PayConfirm'
            end

            it 'contains the expected Account ID' do
              expect(callback_data[:data][:accountid]).to eq subject.account_id
            end

            it 'contains the expected Amount' do
              expect(callback_data[:data][:amount]).to be '1000'
            end
          end
        end
      end
    end

  end

end
