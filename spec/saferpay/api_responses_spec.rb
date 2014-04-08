shared_examples_for 'the get payment url response' do
  let(:response) { subject.get_payment_url(options) }

  it 'is a string' do
    expect(response).to be_a String
  end

  it 'contains the payment url' do
    expect(response).to match /^https:\/\/www.saferpay.com\/.+/
  end
end

shared_examples_for 'the verify pay confirm response' do
  let(:response) { subject.handle_pay_confirm(options) }

  it 'is an hash' do
    expect(response).to be_an Hash
  end

  it 'contains normalized keys' do
    expect(response.keys).to include(:id, :token, :accountid, :amount, :currency, :ip, :msgtype)
  end

  it 'contains the id' do
    expect(response[:id]).to match /\w{28}/
  end

  it 'contains the expected Message Type' do
    expect(response[:msgtype]).to eq 'PayConfirm'
  end

  it 'contains the expected Account ID' do
    expect(response[:accountid]).to eq subject.account_id
  end

  it 'contains the expected Amount' do
    expect(response[:amount]).to eq '1000'
  end

  it 'contains the expected Currency' do
    expect(response[:currency]).to eq 'EUR'
  end

  it 'does not contain the Signature' do
    expect(response[:signature]).to be_nil
  end
end

shared_examples_for 'the complete payment response' do
  let(:response) { subject.complete_payment(options) }

  it 'is an hash' do
    expect(response).to be_an Hash
  end

  it 'contains normalized keys' do
    expect(response.keys).to include(:id, :successful, :result, :msgtype)
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
