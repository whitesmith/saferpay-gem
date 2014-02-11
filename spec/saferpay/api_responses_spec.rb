shared_examples_for 'the get payment url response' do
  let(:response) { subject.get_url(options) }

  it 'is an hash' do
    expect(response).to be_an Hash
  end

  it 'contains the payment url' do
    expect(response[:payment_url]).to match /^https:\/\/www.saferpay.com\/.+/
  end
end

shared_examples_for 'the verify pay confirm response' do
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
      expect(callback_data[:data][:amount]).to eq '1000'
    end
  end
end

shared_examples_for 'the complete payment response' do
  let(:response) { subject.complete_payment(options) }

  it 'is an hash' do
    expect(response).to be_an Hash
  end

  it 'contains the id' do
    expect(response[:id]).to eq options['ID']
  end

  it 'specifies if the request was successfully processed' do
    expect(response[:successful]).to be_true
  end

  it 'contains the expected Message Type' do
    expect(response[:msgtype]).to eq 'PayConfirm'
  end
end
