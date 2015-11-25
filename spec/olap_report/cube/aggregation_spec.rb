require 'spec_helper'

RSpec.describe OlapReport::Cube::Aggregation do
  before(:all) do
    @original_aggregations = Fact.aggregations
  end

  before(:each) do
    Fact.instance_variable_set(:@aggregations, [])
  end

  after(:each) do
    Fact.instance_variable_set(:@aggregations, @original_aggregations)
  end

  describe '.define_aggregation' do
    specify { expect(Fact).to respond_to(:define_aggregation) }

    it 'adds aggregation to @aggregations' do
      expect {
        Fact.define_aggregation user: :user_id
      }.to change { Fact.instance_variable_get(:@aggregations).size }.by(1)
    end

    it 'creates Aggregation::Table object for each aggregation with proper params' do
      Fact.define_aggregation user: :user_id
      aggr = Fact.instance_variable_get(:@aggregations).last
      expect(aggr).to be_instance_of(OlapReport::Cube::Aggregation::Table)
      expect(aggr.levels.map { |l| { l.dimension_name => l.name } }).to eq([{ user: :user_id }])

      Fact.define_aggregation user: :group_id, date: :day
      aggr = Fact.instance_variable_get(:@aggregations).last
      expect(aggr).to be_instance_of(OlapReport::Cube::Aggregation::Table)
      expect(aggr.levels.map { |l| { l.dimension_name => l.name } }).to eq([{ user: :group_id }, { date: :day }])
    end

    it 'raises an error if same aggregation already exists' do
      expect do
        Fact.define_aggregation user: :user_id
        Fact.define_aggregation user: :user_id
      end.to raise_error OlapReport::Cube::DuplicateAggregationError
    end
  end

  describe '.aggregations' do
    it 'returns aggregations' do
      Fact.define_aggregation user: :user_id
      expect(Fact.aggregations).to be_an(Array)
      expect(Fact.aggregations.first).to be_a(OlapReport::Cube::Aggregation::Table)
    end
  end

  describe '::aggregate!' do
    specify { expect(Fact).to respond_to(:aggregate!) }

    it 'calls ::aggregate_table! method for each one of defined aggregations' do
      allow_any_instance_of(OlapReport::Cube::Aggregation::Table).to receive(:aggregate_table!).and_return(true)
      Fact.define_aggregation user: :group_id
      Fact.aggregations.each { |a| expect(a).to receive(:aggregate_table!) }

      Fact.aggregate!
    end
  end
end
