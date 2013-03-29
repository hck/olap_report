require "spec_helper"

describe OlapReport::Cube do
  it "should raise error if it isn't descendant of ActiveRecord::Base" do
    expect do
      class Bar
        include OlapReport::Cube
      end
    end.to raise_error(ArgumentError)
  end

  it "should respond to dimensions method" do
    Fact.should respond_to(:dimensions)
  end

  it "should respond to measures method" do
    Fact.should respond_to(:measures)
  end

  describe "::adapter" do
    it "should initialize appropriate adapter for model connection" do
      Fact.adapter.should be_instance_of(OlapReport::Cube::Adapters::PostgreSQLAdapter)
    end
  end

  describe "::define_dimension" do
    it "should return defined cube" do
      Fact.dimensions.size.should == 2

      [:user_id, :group_id, :category].each do |level_name|
        Fact.dimension(:user)[level_name].should be_instance_of(OlapReport::Cube::Level)
        Fact.dimension(:user)[level_name].name.should == level_name
      end
    end
  end

  describe "::dimension" do
    it "should return dimension by name" do
      Fact.dimension(:user).tap do |d|
        d.should be_instance_of(OlapReport::Cube::Dimension)
        d.name.should == :user
      end
    end

    it "should return nil if no dimension with specified name exists" do
      Fact.dimension(:new_dimension).should be_nil
    end
  end

  describe "::define_measure" do
    it "should define valid measure" do
      Fact.measure(:score_count).tap do |m|
        m.name.should == :score_count
        m.column.should ==  :score
        m.function.should == :count
      end
    end
  end

  describe "::measure" do
    it "should return measure by name" do
      Fact.measure(:score_count).tap do |m|
        m.should be_instance_of OlapReport::Cube::Measure
        m.name.should == :score_count
      end
    end

    it "should return nil if no measure with specified name exists" do
      Fact.measure(:new_measure).should be_nil
    end
  end
end