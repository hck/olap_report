require "spec_helper"

describe OlapReport::Cube do
  before(:each) do
    class Foo
      include OlapReport::Cube

      #class Reviews < ActiveRecord::Base
      #  include OlapReport::Cube
      #
      #  dimension :product do |d|
      #    d.level :product_id
      #    d.level :product_type_id, joins: :products
      #    d.level :product_group_id, joins: :products
      #  end
      #end

      dimension :product
      dimension :date do |d|
        d.level :day, joins: :days, group_by: 'DATE_FORMAT('', date)'
        d.level :month
        d.level :year
      end

      measure :score
      measures_for :views, [:sum, :avg]
      measure :purchases, :count, column: :purchase_id
    end
  end

  it "should respond to dimensions method" do
    Foo.should respond_to(:dimensions)
  end

  it "should respond to measures method" do
    Foo.should respond_to(:measures)
  end

  it "should return defined cube" do
    Foo.dimensions.size.should == 2

    [:day, :month, :year].each do |level_name|
      Foo.dimensions[:date].levels[level_name].should be_instance_of(OlapReport::Cube::Level)
      Foo.dimensions[:date].levels[level_name].name.should == level_name
    end
  end

  it "#measure defines valid measure" do
    Foo.measures[:score].should == OlapReport::Cube::Measure.new(:score)
    Foo.measures[:purchases].should == OlapReport::Cube::Measure.new(:purchases, :count, column: :purchase_id)
  end

  it "#measures_for defines valid measures for column" do
    Foo.measures[:views_sum].should == OlapReport::Cube::Measure.new(:views_sum, :sum, column: :views)
    Foo.measures[:views_avg].should == OlapReport::Cube::Measure.new(:views_avg, :avg, column: :views)
  end

  describe "::projection" do
    before(:each) do
      @facts = FactoryGirl.create_list(:fact, 10)
    end

    it "should fetch dimension grouped by self" do
      Fact.projection(dimensions: {user: :user_id}).should == Fact.select('`facts`.`user_id`').group('`facts`.`user_id`')
      Fact.projection(dimensions: {user: :group_id}).should == Fact.select('`users`.`group_id`').joins(:user).group('`users`.`group_id`')
      Fact.projection(dimensions: {user: :category}).should == Fact.select('`groups`.`category`').joins(user: :group).group('`groups`.`category`')
    end

    it "should fetch specified dimension & measure" do
      expected = Fact.select('`users`.`group_id`, SUM(`facts`.`score`) group_score, COUNT(`facts`.`score`) score_count').joins(:user).group('`users`.`group_id`')

      Fact.projection(dimensions: {user: :group_id}, measures: [:score]).map(&:score_sum).should == expected.map(&:group_score)
      Fact.projection(dimensions: {user: :group_id}, measures: [:score]).map(&:group_id).should == expected.map(&:group_id)
      Fact.projection(dimensions: {user: :group_id}, measures: [:score_count]).map(&:score_count).should == expected.map(&:score_count)
    end

    it "calculates correct average" do
      Fact.projection(dimensions: {user: :group_id}, measures: [:score])
    end
  end
end