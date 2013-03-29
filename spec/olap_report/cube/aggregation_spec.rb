require 'spec_helper'

describe OlapReport::Cube::Aggregation do
  before(:all) do
    @original_aggregations = Fact.aggregations
  end

  before(:each) do
    Fact.instance_variable_set(:@aggregations, [])
  end

  after(:each) do
    Fact.instance_variable_set(:@aggregations, @original_aggregations)
  end

  describe "::define_aggregation" do
    it "should respond" do
      Fact.should respond_to :define_aggregation
    end

    it "should add aggregation to @aggregations" do
      Fact.instance_variable_get(:@aggregations).size.should == 0

      Fact.define_aggregation user: :user_id
      Fact.instance_variable_get(:@aggregations).size.should == 1

      Fact.define_aggregation user: :group_id, date: :created_at
      Fact.instance_variable_get(:@aggregations).size.should == 2
    end

    it "should create Aggregation::Table object for each aggregation with proper params" do
      Fact.define_aggregation user: :user_id
      aggr = Fact.instance_variable_get(:@aggregations).last
      aggr.should be_instance_of(OlapReport::Cube::Aggregation::Table)
      aggr.levels.map{|l| {l.dimension_name => l.name}}.should == [{user: :user_id}]

      Fact.define_aggregation user: :group_id, date: :day
      aggr = Fact.instance_variable_get(:@aggregations).last
      aggr.should be_instance_of(OlapReport::Cube::Aggregation::Table)
      aggr.levels.map{|l| {l.dimension_name => l.name}}.should == [{user: :group_id}, {date: :day}]
    end

    it "raise an error if same aggregation already exists" do
      expect do
        Fact.define_aggregation user: :user_id
        Fact.define_aggregation user: :user_id
      end.to raise_error OlapReport::Cube::DuplicateAggregationError
    end
  end

  describe "::aggregations" do
    it "should return aggregations" do
      Fact.define_aggregation user: :user_id
      Fact.aggregations.should be_an(Array)
      Fact.aggregations.first.should be_a(OlapReport::Cube::Aggregation::Table)
    end
  end

  describe "::aggregate!" do
    it "should respond to method" do
      Fact.should respond_to :aggregate!
    end

    it "should call ::aggregate_table! method for each one of defined aggregations" do
      OlapReport::Cube::Aggregation::Table.any_instance.stub(:aggregate_table!).and_return(true)
      Fact.define_aggregation user: :group_id
      Fact.aggregations.each{|a| a.should_receive(:aggregate_table!)}

      Fact.aggregate!
    end
  end
end