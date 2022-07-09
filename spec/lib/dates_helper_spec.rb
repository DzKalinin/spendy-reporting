require 'spec_helper'

describe DatesHelper do
  before(:each) { Timecop.freeze(Time.zone.parse('2022-06-09').midday) }
  after(:each) { Timecop.return }

  it 'should return beginning of day for start date' do
    expect(described_class.start_timestamp('2022-06-04')).to eq(1654315200)
  end

  it 'should return end of passed day timestamp for end date < today' do
    expect(described_class.end_timestamp('2022-06-08')).to eq(1654747199)
  end

  it 'should return end of current day timestamp for end date > today' do
    expect(described_class.end_timestamp('2022-06-10')).to eq(1654833599)
  end

  it 'should return end of current day timestamp for end date = today' do
    expect(described_class.end_timestamp('2022-06-09')).to eq(1654833599)
  end
end
