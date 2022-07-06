require 'spec_helper'

describe UserSpendAggregator do
  let(:name) { 'test' }
  let!(:mocked_data) do
    [OpenStruct.new(fields: { 'user_name' => { string_value: name},
                              'category' => { string_value: 'taxi'},
                              'currency' => { string_value: 'usd'},
                              'amount' => { double_value: 5.5},
                              'place' => { string_value: 'bolt'},
                              'created_at' => { integer_value: 1656648000 }}),
     OpenStruct.new(fields: { 'user_name' => { string_value: name},
                              'category' => { string_value: 'taxi'},
                              'currency' => { string_value: 'usd'},
                              'amount' => { double_value: 12.2},
                              'place' => { string_value: 'bolt'},
                              'created_at' => { integer_value: 1656648000 } }),
     OpenStruct.new(fields: { 'user_name' => { string_value: name},
                              'category' => { string_value: 'food'},
                              'currency' => { string_value: 'byn'},
                              'amount' => { double_value: 153.5},
                              'place' => { string_value: 'green'},
                              'created_at' => { integer_value: 1656648000 }}),
     OpenStruct.new(fields: { 'user_name' => { string_value: name},
                              'category' => { string_value: 'food'},
                              'currency' => { string_value: 'usd'},
                              'amount' => { double_value: 46.5 },
                              'place' => { string_value: ''},
                              'created_at' => { integer_value: 1656734400 }})]
  end

  subject { described_class.new(name) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:user_data).and_return(mocked_data)
  end

  it 'should return data by category with total row' do
    expect(subject.agg_spend_by('category')).to eq([
                                                     { agg_field_value: 'total usd', currency: 'usd', amount: 64.2 },
                                                     { agg_field_value: 'total byn', currency: 'byn', amount: 153.5 },
                                                     { agg_field_value: 'food', currency: 'byn', amount: 153.5 },
                                                     { agg_field_value: 'food', currency: 'usd', amount: 46.5 },
                                                     { agg_field_value: 'taxi', currency: 'usd', amount: 17.7 } ])
  end

  it 'should return data by day with total row' do
    expect(subject.agg_spend_by('created_at')).to eq([
                                                     { agg_field_value: 'total usd', currency: 'usd', amount: 64.2 },
                                                     { agg_field_value: 'total byn', currency: 'byn', amount: 153.5 },
                                                     { agg_field_value: '01 Jul 2022', currency: 'byn', amount: 153.5 },
                                                     { agg_field_value: '01 Jul 2022', currency: 'usd', amount: 17.7 },
                                                     { agg_field_value: '02 Jul 2022', currency: 'usd', amount: 46.5 } ])
  end
end
