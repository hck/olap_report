require "spec_helper"

describe OlapReport::Cube::Level do
  let(:dimension){ OlapReport::Cube::Dimension.new(Fact, :dimension_name) }

  describe "#initialize" do
    it "should create level if name specified" do
      described_class.new(dimension, :level).should be_instance_of(described_class)
    end

    it "should raise exception if dimension is not provided" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it "should raise exception if name is not provided" do
      expect { described_class.new(dimension) }.to raise_error(ArgumentError)
    end
  end

  describe "#group_by" do
    it "should return group by if it was specified in initialize" do
      level = described_class.new(dimension, :level, group_by: :group_by_field)
      level.group_by.should == :group_by_field
    end

    it "should return name by if no group by option provided in initialize" do
      level = described_class.new(dimension, :level)
      level.group_by.should == level.model.column_name_with_table('level', 'facts')
    end
  end

  describe "#column" do
    it "should return column name if no type specified" do
      Fact.dimensions[:user].levels[:group_id].column.should == Fact.column_name_with_table('group_id', 'users')
    end

    it "should return proper column name with alias if type specified" do
      Fact.dimensions[:date].levels.values.each do |level|
        field = Fact.column_name_with_table('created_at')
        level.column.should == Fact.adapter.column_name(field, level.type)
      end
    end
  end

  describe "#select_sql" do
    pending
  end

  describe "#group_sql" do
    pending
  end
end