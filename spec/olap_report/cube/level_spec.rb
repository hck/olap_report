require "spec_helper"

describe OlapReport::Cube::Level do
  let(:dimension){ OlapReport::Cube::Dimension.new(Fact, :dimension_name) }

  describe "#initialize" do
    it "should create level if dimension & name specified" do
      described_class.new(dimension, :level).should be_instance_of(described_class)
    end

    it "should raise exception if dimension is not provided" do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
    end

    it "should raise exception if name is not provided" do
      expect { described_class.new(dimension, nil) }.to raise_error(ArgumentError)
    end
  end

  describe "#build_relation" do
    it "should add select to relation" do
      level = Fact.dimension(:user)[:group_id]
      level.build_relation(Fact).select_values.should == ['"users"."group_id" AS "group_id"']
    end

    it "should add joins to relation" do
      level = Fact.dimension(:user)[:category]
      level.build_relation(Fact).joins_values.should == [{user: :group}]
    end

    it "should add group_by to relation" do
      level = Fact.dimension(:user)[:category]
      level.build_relation(Fact).group_values.should == ['"groups"."category"']
    end

    it "should add select by date range to relation" do
      pending
    end

    it "should add group_by by date range to relation" do
      pending
    end
  end
end