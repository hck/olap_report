require 'spec_helper'

describe OlapReport::Cube::Aggregation do
  subject { described_class.new(levels: {some: :level}, measures: [:measure]) }

  it "should initialize with levels specified" do
    expect {described_class.new}.to raise_error ArgumentError
    expect {described_class.new(true)}.to raise_error ArgumentError
  end

  describe "#aggregate!" do
    it "responds to method" do
      subject.should respond_to :aggregate!
    end
  end

  describe "#column_names" do
    it "returns column names for aggretation table" do
      subject.column_names.should == [:level, :measure]
    end
  end

  describe "#create_table!" do
    pending
  end
end