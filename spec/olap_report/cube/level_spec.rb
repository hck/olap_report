require 'spec_helper'

RSpec.describe OlapReport::Cube::Level do
  let(:dimension) { OlapReport::Cube::Dimension.new(Fact, :dimension_name) }

  describe "#initialize" do
    it 'creates level if dimension & name specified' do
      expect(described_class.new(dimension, :level)).to be_instance_of(described_class)
    end

    it 'raises exception if dimension is not provided' do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
    end

    it 'raises exception if name is not provided' do
      expect { described_class.new(dimension, nil) }.to raise_error(ArgumentError)
    end
  end

  describe '#build_relation' do
    let(:connection) { ActiveRecord::Base.connection }

    it 'adds select to relation' do
      level = Fact.dimension(:user)[:group_id]
      expected_select = [
        "#{connection.quote_table_name('users')}.#{connection.quote_column_name('group_id')}",
        connection.quote_column_name('group_id')
      ].join(' AS ')
      expect(level.build_relation(Fact).select_values).to eq([expected_select])
    end

    it 'adds joins to relation' do
      level = Fact.dimension(:user)[:category]
      expect(level.build_relation(Fact).joins_values).to eq([user: :group])
    end

    it 'adds group_by to relation' do
      level = Fact.dimension(:user)[:category]
      expected_group = "#{connection.quote_table_name('groups')}.#{connection.quote_column_name('category')}"
      expect(level.build_relation(Fact).group_values).to eq([expected_group])
    end

    xit 'adds select by date range to relation' do
    end

    xit 'adds group_by by date range to relation' do
    end
  end
end
