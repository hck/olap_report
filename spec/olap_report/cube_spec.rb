require 'spec_helper'

RSpec.describe OlapReport::Cube do
  it 'raises error if it isn\'t descendant of ActiveRecord::Base' do
    expect {
      Class.new { include OlapReport::Cube }
    }.to raise_error(ArgumentError)
  end

  specify { expect(Fact).to respond_to(:dimensions) }
  specify { expect(Fact).to respond_to(:measures) }

  describe '.adapter' do
    it 'initializes appropriate adapter for model connection' do
      klass = Object.const_get("OlapReport::Cube::Adapters::#{Fact.connection.adapter_name}Adapter")
      expect(Fact.adapter).to be_instance_of(klass)
    end
  end

  describe '.define_dimension' do
    let(:dimension) { Fact.dimension(:user) }

    specify { expect(Fact.dimensions.size).to eq(2) }

    [:user_id, :group_id, :category].each do |level_name|
      specify { expect(dimension[level_name]).to be_instance_of(OlapReport::Cube::Level) }
      specify { expect(dimension[level_name].name).to eq(level_name) }
    end
  end

  describe '.dimension' do
    let(:dimension) { Fact.dimension(:user) }

    specify { expect(dimension).to be_instance_of(OlapReport::Cube::Dimension) }
    specify { expect(dimension.name).to eq(:user) }

    it 'raises KeyError if no dimension with specified name exists' do
      expect { Fact.dimension(:new_dimension) }.to raise_error(KeyError)
    end
  end

  describe '.define_measure' do
    let(:measure) { Fact.measure(:score_count) }

    specify { expect(measure.name).to eq(:score_count) }
    specify { expect(measure.column).to eq(:score) }
    specify { expect(measure.function).to eq(:count) }
  end

  describe '.measure' do
    let(:measure) { Fact.measure(:score_count) }

    specify { expect(measure).to be_instance_of(OlapReport::Cube::Measure) }
    specify { expect(measure.name).to eq(:score_count) }

    it 'returns nil if no measure with specified name exists' do
      expect(Fact.measure(:new_measure)).to be_nil
    end
  end
end
