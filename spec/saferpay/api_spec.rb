require 'spec_helper'
require 'saferpay'

shared_examples_for 'default redefinition' do
  context 'when account_id is redefined' do
    let (:redefined_options) { options.merge( {'ACCOUNTID' => 'random-ID'} ) }
    
    it 'uses the new value instead of the default' do
      expect(subject.class).to receive(:get).with anything, { :query => redefined_options }
      subject.send(testing_method, redefined_options) rescue nil # don't care if it fails after
    end
  end
end

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
        expect { subject.get_payment_url(options) }.to raise_error(Saferpay::Error::BadRequest, 'Missing AMOUNT attribute')
      end
    end

    context 'when currency is missing' do
      let (:options) { {'AMOUNT' => 1000} }
      it 'raises Missing CURRENCY error' do
        expect { subject.get_payment_url(options) }.to raise_error(Saferpay::Error::BadRequest, 'Missing CURRENCY attribute')
      end
    end

    context 'when description is missing' do
      let (:options) { {'AMOUNT' => 1000, 'CURRENCY' => 'EUR'} }
      it 'raises Missing DESCRIPTION error' do
        expect { subject.get_payment_url(options) }.to raise_error(Saferpay::Error::BadRequest, 'Missing DESCRIPTION attribute')
      end
    end

    context 'when amount, currency and description are defined' do
      let (:options) { {'AMOUNT' => 1000, 'CURRENCY' => 'EUR', 'DESCRIPTION' => 'Test description.'} }

      it 'does not raise an error' do
        expect { subject.get_payment_url(options) }.not_to raise_error
      end

      it_behaves_like 'the get payment url response'

      include_examples 'default redefinition' do
        let (:testing_method) { :get_payment_url }
      end
    end

    context 'when a known parameter is also defined' do
      let (:options) { {'AMOUNT' => 1000, 'CURRENCY' => 'EUR', 'DESCRIPTION' => 'Test description.', 'NOTIFYURL' => 'http://example.com'} }

      it 'does not raise an error' do
        expect { subject.get_payment_url(options) }.not_to raise_error
      end

      it_behaves_like 'the get payment url response'

      let(:response) { subject.get_payment_url(options) }

      it 'includes the extra parameter in the response' do
        expect(response).to include 'NOTIFYURL'
      end

      include_examples 'default redefinition' do
        let (:testing_method) { :get_payment_url }
      end
    end

    context 'when an unknown parameter is defined' do
      let (:options) { {'AMOUNT' => 1000, 'CURRENCY' => 'EUR', 'DESCRIPTION' => 'Test description.', 'XYZ' => 'something'} }

      it 'does not raise an error' do
        expect { subject.get_payment_url(options) }.not_to raise_error
      end

      it_behaves_like 'the get payment url response'

      let(:response) { subject.get_payment_url(options) }

      it 'does not include the extra parameter in the response' do
        expect(response).not_to include 'XYZ'
      end

      include_examples 'default redefinition' do
        let (:testing_method) { :get_payment_url }
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

        it_behaves_like 'the verify pay confirm response'

        describe 'the original options parameter' do
          subject { Saferpay::API.new(:account_id => '99867-94913159') }

          context 'when nothing matches' do
            subject { Saferpay::API.new(:account_id => '123123') }
            let (:original_options) { {} }
            it 'raises Possible Manipulation error' do
              expect { subject.handle_pay_confirm(options, original_options) }.to raise_error(Saferpay::Error::BadRequest, 'Possible manipulation - AMOUNT, CURRENCY, ORDERID, ACCOUNTID not matching')
            end
          end

          context 'when amount doesn\'t match' do
            let (:original_options) { { 'CURRENCY' => 'EUR', 'ORDERID' => '123456789-001' } }
            it 'raises Possible Manipulation error' do
              expect { subject.handle_pay_confirm(options, original_options) }.to raise_error(Saferpay::Error::BadRequest, 'Possible manipulation - AMOUNT not matching')
            end
          end

          context 'when currency doesn\'t match' do
            let (:original_options) { { 'AMOUNT' => '1000', 'ORDERID' => '123456789-001' } }
            it 'raises Possible Manipulation error' do
              expect { subject.handle_pay_confirm(options, original_options) }.to raise_error(Saferpay::Error::BadRequest, 'Possible manipulation - CURRENCY not matching')
            end
          end

          context 'when orderid doesn\'t match' do
            let (:original_options) { { 'AMOUNT' => '1000', 'CURRENCY' => 'EUR', 'ORDERID' => 'random' } }
            it 'raises Possible Manipulation error' do
              expect { subject.handle_pay_confirm(options, original_options) }.to raise_error(Saferpay::Error::BadRequest, 'Possible manipulation - ORDERID not matching')
            end
          end

          context 'when account_id doesn\'t match' do
            subject { Saferpay::API.new(:account_id => '123123') }
            let (:original_options) { { 'AMOUNT' => '1000', 'CURRENCY' => 'EUR', 'ORDERID' => '123456789-001' } }
            it 'raises Possible Manipulation error' do
              expect { subject.handle_pay_confirm(options, original_options) }.to raise_error(Saferpay::Error::BadRequest, 'Possible manipulation - ACCOUNTID not matching')
            end
          end

          context 'when everything matches' do
            let (:original_options) { { 'AMOUNT' => '1000', 'CURRENCY' => 'EUR', 'ORDERID' => '123456789-001' } }
            it 'does not raise an error' do
              expect { subject.handle_pay_confirm(options, original_options) }.not_to raise_error
            end
          end

        end
      end

      context 'when more than data and signature are defined' do
        let (:options) { {:id => 1, :controller => 'test', 'DATA' => URI.encode('<IDP MSGTYPE="PayConfirm" TOKEN="(unused)" VTVERIFY="(obsolete)" KEYID="1-0" ID="A668MSAprOj4tAzv7G9lAQUfUr3A" ACCOUNTID="99867-94913159" PROVIDERID="90" PROVIDERNAME="Saferpay Test Card" ORDERID="123456789-001" AMOUNT="1000" CURRENCY="EUR" IP="193.247.180.193" IPCOUNTRY="CH" CCCOUNTRY="XX" MPI_LIABILITYSHIFT="yes" MPI_TX_CAVV="AAABBIIFmAAAAAAAAAAAAAAAAAA=" MPI_XID="CxMTYwhoUXtCBAEndBULcRIQaAY=" ECI="1" CAVV="AAABBIIFmAAAAAAAAAAAAAAAAAA=" XID="CxMTYwhoUXtCBAEndBULcRIQaAY=" />'), 'SIGNATURE' => '7b2bb163f4ef86d969d992b4e2d61ad48d3b9022e0ec68177e35fe53184e6b3399730d1a3641d2a984ce38699daad72ab006d5d6a9565c5ae1cff8bdc8a1eb63'} }
        
        it 'does not raise an error' do
          expect { subject.handle_pay_confirm(options) }.not_to raise_error
        end

        it_behaves_like 'the verify pay confirm response'

        include_examples 'default redefinition' do
          let (:testing_method) { :handle_pay_confirm }
        end
      end
    end

  end

  describe 'GET complete payment' do
    let (:default_options) { {'spPassword' => 'XAjc3Kna'} }   # only for test account on PayComplete method (via HTTPs interface)

    context 'when id is missing' do
      let (:options) { default_options.merge({}) }
      it 'raises Missing ID error' do
        expect { subject.complete_payment(options) }.to raise_error(Saferpay::Error::BadRequest, 'Missing ID attribute')
      end
    end

    context 'when id is defined' do

      context 'when id is not valid' do
        let (:options) { default_options.merge({'ID' => 'test-id'}) }
        it 'raises invalid ID error' do
          expect { subject.complete_payment(options) }.to raise_error(Saferpay::Error::BadRequest, 'Transaction not available')
        end
      end

      context 'when id is valid' do
        let (:options) { default_options.merge({'ID' => 'WxWrIlA48W06rAjKKOp5bzS80E5A'}) }
        
        it 'does not raise an error' do
          expect { subject.complete_payment(options) }.not_to raise_error
        end

        it_behaves_like 'the complete payment response'

        include_examples 'default redefinition' do
          let (:testing_method) { :complete_payment }
        end
      end
    end

  end

end
