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

  describe "::projection" do
    #before(:each) do
    #  @facts = FactoryGirl.create_list(:fact, 10)
    #end

    it "should fetch dimension grouped by self" do
      Fact.projection(cube: {user: :user_id}).should == Fact.select('`facts`.`user_id`').group('`facts`.`user_id`')
      Fact.projection(cube: {user: :group}).should == Fact.select('`users`.`group`').joins(:user).group('`users`.`group`')
    end

    it "should fetch specified dimension & measure" do
      # @TODO: complete this spec
      pending
      Fact.projection(cube: {user: :group}, measures: [:score]).should == true
    end
  end
end