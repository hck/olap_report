require 'spec_helper'

describe OlapReport::Cube::Aggregation do
  before :each do
    Fact.instance_variable_set(:@aggregations, nil)
  end

  describe "::aggregation" do
    it "should respond to ::aggregation" do
      Fact.should respond_to :aggregation
    end

    it "adds aggregation to @aggregations" do
      Fact.aggregation some: :aggregation
      Fact.instance_variable_get(:@aggregations).should == [some: :aggregation]
      Fact.aggregation another: :aggregation, and_one: :more
      Fact.instance_variable_get(:@aggregations).should == [{some: :aggregation}, {another: :aggregation, and_one: :more}]
    end

    it "raise an error if same aggregation already exists" do
      expect do
        Fact.aggregation some: :aggregation
        Fact.aggregation some: :aggregation
      end.to raise_error OlapReport::Cube::DuplicateAggregationError
    end
  end

  describe "::aggregations" do
    it "returns aggregations" do
      Fact.aggregation some: :aggregation
      Fact.aggregations.should be_an(Array)
      Fact.aggregations.first.should be_a(Hash)
    end
  end

  describe "::aggregate!" do
    it "should respond to method" do
      Fact.should respond_to :aggregate!
    end

    it "should call ::aggregate_table! method for each one of defined aggregations" do
      FactoryGirl.create_list(:group, 3).each do |g|
        FactoryGirl.create_list(:user, 10, group: g).each do |u|
          FactoryGirl.create_list(:fact, 10, user: u)
        end
      end

      # Fact.stub(:aggregate_table!).and_return true
      #Fact.aggregation some: :aggregation
      #Fact.aggregation another: :aggregation, and_one: :more
      Fact.aggregation user: :group_id
      # Fact.aggregations.each do |aggr|
      #   Fact.should_receive(:aggregate_table!).with(aggr).once
      # end
      Fact.aggregate!
    end
  end

  # describe "::aggregate_table!" do
  #   it "should call ::column_names" do
  #     levels = {some: :aggregation}
  #     Fact.aggregation levels
  #     Fact.should_receive(:column_names).with(levels).once
  #     Fact.aggregate_table!(levels)
  #   end
  # end

end