require "spec_helper"

describe OlapReport::Cube::Measure do
  describe "#initialize" do
    it "should create measure with name specified" do
      described_class.new(Fact, :measure_name).tap do |m|
        m.name.should == :measure_name
        m.function.should == :sum
        m.column.should == m.name
      end
    end

    it "should raise error if model not specified" do
      expect{ described_class.new(nil) }.to raise_error(ArgumentError)
    end

    it "should raise error if name not specified" do
      expect{ described_class.new(Fact, nil) }.to raise_error(ArgumentError)
    end

    it "should create measure with name & function specified" do
      described_class.new(Fact, :measure_name, :count).tap do |m|
        m.name.should == :measure_name
        m.function.should == :count
        m.column.should == m.name
      end
    end

    it "should create measure with name, function & column specified" do
      described_class.new(Fact, :measure_name, :count, column: :column_name).tap do |m|
        m.name.should == :measure_name
        m.function.should == :count
        m.column.should == :column_name
      end
    end
  end

  it "validates incoming functions" do
    expect do
      described_class.new(:foobar, :bad_function, {})
    end.to raise_exception(OlapReport::Cube::ProhibitedFunctionError)
  end

  describe "#build_relation" do
    it "should add select to relation" do
      measure = Fact.measure(:score_count)
      measure.build_relation(Fact).select_values.should == ['COUNT("facts"."score") AS "score_count"']
    end
  end
end