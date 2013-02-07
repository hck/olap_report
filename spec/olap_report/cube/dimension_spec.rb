require "spec_helper"

describe OlapReport::Cube::Dimension do
  describe "#initialize" do
    it "should create dimension if name specified" do
      obj = described_class.new(:product)
      obj.should be_instance_of(described_class)
      obj.name.should == :product
    end

    it "should raise error if name not specified" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  describe "#level"
  it "should define level with appropriate method" do
    obj = described_class.new(:date)
    obj.level :day
    obj.level :month
    obj.level :year

    [:day, :month, :year].each do |name|
      obj.levels[name].should be_instance_of(OlapReport::Cube::Level)
      obj.levels[name].name.should == name
    end
  end
end