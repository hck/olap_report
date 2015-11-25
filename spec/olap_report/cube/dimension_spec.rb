require 'spec_helper'

RSpec.describe OlapReport::Cube::Dimension do
  describe '#initialize' do
    let(:dimension) { described_class.new(ActiveRecord::Base, :product) }

    specify { expect(dimension).to be_instance_of(described_class) }
    specify { expect(dimension.name).to eq(:product) }

    it 'raises error if model not specified' do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
    end

    it 'raises error if name not specified' do
      expect { described_class.new(ActiveRecord::Base, nil) }.to raise_error(ArgumentError)
    end
  end

  describe '#level' do
    let(:dimension) { described_class.new(ActiveRecord::Base, :date) }

    [:day, :month, :year].each do |name|
      specify { expect(dimension.level(name)).to be_instance_of(OlapReport::Cube::Level) }
      specify { expect(dimension.level(name).name).to eq(name) }
    end
  end
end
