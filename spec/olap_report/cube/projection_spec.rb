require 'spec_helper'

describe OlapReport::Cube::Projection do
  it "should respond to dimensions method" do
    Fact.should respond_to(:dimensions)
  end

  it "should respond to measures method" do
    Fact.should respond_to(:measures)
  end

  it "should return defined cube" do
    Fact.dimensions.size.should == 2

    [:user_id, :group_id, :category].each do |level_name|
      Fact.dimensions[:user].levels[level_name].should be_instance_of(OlapReport::Cube::Level)
      Fact.dimensions[:user].levels[level_name].name.should == level_name
    end
  end

  describe "::measure" do
    it "should define valid measure" do
      Fact.measures[:score_count].should == OlapReport::Cube::Measure.new(Fact, :score_count, :count, column: :score)
    end
  end

  describe "::measures_for" do
    it "should define valid measures for column" do
      Fact.measures[:score_sum].should == OlapReport::Cube::Measure.new(Fact, :score_sum, :sum, column: :score)
      Fact.measures[:score_avg].should == OlapReport::Cube::Measure.new(Fact, :score_avg, :avg, column: :score)
    end
  end

  describe "::projection" do
    before(:each) do
      @facts = FactoryGirl.create_list(:fact, 10)
    end

    it "should fetch dimension grouped by level name" do
      Fact.projection(dimensions: {user: :user_id}).should == Fact.select('`facts`.`user_id`').group('`facts`.`user_id`')
      Fact.projection(dimensions: {user: :group_id}).should == Fact.select('`users`.`group_id`').joins(:user).group('`users`.`group_id`')
      Fact.projection(dimensions: {user: :category}, skip_aggregated: true).should == Fact.select('`groups`.`category`').joins(user: :group).group('`groups`.`category`')
    end

    it "should fetch specified dimension & measure" do
      expected = Fact.select('`users`.`group_id`, SUM(`facts`.`score`) group_score, COUNT(`facts`.`score`) score_count').joins(:user).group('`users`.`group_id`')
      Fact.projection(dimensions: {user: :group_id}, measures: [:score_sum]).map(&:score_sum).should == expected.map(&:group_score)
      Fact.projection(dimensions: {user: :group_id}, measures: [:score_sum]).map(&:group_id).should == expected.map(&:group_id)
      Fact.projection(dimensions: {user: :group_id}, measures: [:score_count]).map(&:score_count).should == expected.map(&:score_count)
    end

    it "should calculate correct average" do
      expected = Fact.select('`users`.`group_id`, AVG(`facts`.`score`) score_avg').joins(:user).group('`users`.`group_id`')
      Fact.projection(dimensions: {user: :group_id}, measures: [:score_avg]).map(&:score_avg).should == expected.map(&:score_avg)
    end

    it "should select data from aggregated table if it was defined for specified dimensions & levels" do
      Fact.aggregate!
      expected = Fact.select('`facts_by_category`.`category`, `facts_by_category`.`score_count`').from('facts_by_category')
      Fact.projection(dimensions: {user: :category}, measures: [:score_count]).should == expected
    end
  end
end