require "spec_helper"

describe OlapReport::Cube::Dimension do
  describe "#initialize" do
    it "should create dimension if model & name specified" do
      obj = described_class.new(ActiveRecord::Base, :product)
      obj.should be_instance_of(described_class)
      obj.name.should == :product
    end

    it "should raise error if model not specified" do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
    end

    it "should raise error if name not specified" do
      expect { described_class.new(ActiveRecord::Base, nil) }.to raise_error(ArgumentError)
    end
  end

  describe "#level"
  it "should define level with appropriate method" do
    obj = described_class.new(ActiveRecord::Base, :date)
    obj.level :day
    obj.level :month
    obj.level :year

    [:day, :month, :year].each do |name|
      obj[name].should be_instance_of(OlapReport::Cube::Level)
      obj[name].name.should == name
    end
  end
end