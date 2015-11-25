require 'spec_helper'

RSpec.describe OlapReport::Cube::Measure do
  describe '#initialize' do
    it 'creates measure with name specified' do
      measure = described_class.new(Fact, :measure_name)
      expect([measure.name, measure.function, measure.column]).to eq([:measure_name, :sum, :measure_name])
    end

    it 'raises error if model not specified' do
      expect{ described_class.new(nil) }.to raise_error(ArgumentError)
    end

    it 'raises error if name not specified' do
      expect{ described_class.new(Fact, nil) }.to raise_error(ArgumentError)
    end

    it 'creates measure with name & function specified' do
      measure = described_class.new(Fact, :measure_name, :count)
      expect([measure.name, measure.function, measure.column]).to eq([:measure_name, :count, :measure_name])
    end

    it 'creates measure with name, function & column specified' do
      measure = described_class.new(Fact, :measure_name, :count, column: :column_name)
      expect([measure.name, measure.function, measure.column]).to eq([:measure_name, :count, :column_name])
    end
  end

  it 'validates incoming functions' do
    expect {
      described_class.new(:foobar, :bad_function, {})
    }.to raise_exception(OlapReport::Cube::ProhibitedFunctionError)
  end

  describe '#build_relation' do
    let(:connection) { ActiveRecord::Base.connection }

    it 'adds select to relation' do
      measure = Fact.measure(:score_count)
      expected_select = "COUNT(#{connection.quote_table_name('facts')}.#{connection.quote_table_name('score')}) AS #{connection.quote_table_name('score_count')}"
      expect(measure.build_relation(Fact).select_values).to eq([expected_select])
    end
  end
end
