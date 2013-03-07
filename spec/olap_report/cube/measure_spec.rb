require "spec_helper"

describe OlapReport::Cube::Measure do
  describe "#initialize" do
    it "should create measure with model & name specified" do
      described_class.new(Fact, :measure_name).tap do |m|
        m.name.should == :measure_name
        m.function.should == :sum
        m.column.should == m.name
      end
    end

    it "should raise error if model was not specified" do
      expect{ described_class.new }.to raise_error(ArgumentError)
    end

    it "should raise error if name was not specified" do
      expect{ described_class.new(Fact) }.to raise_error(ArgumentError)
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
    expect { described_class.new(Fact, :foobar, :bad_function, {}) }.to raise_exception(OlapReport::Cube::ProhibitedFunctionError)
  end

  describe "#==" do
    it "should return true if compared object is a Measure and has the same name, column & function" do
      described_class.new(Fact, :measure_name).should == described_class.new(Fact, :measure_name, :sum)
      described_class.new(Fact, :measure_name, :count, column: :column_name).should == described_class.new(Fact, :measure_name, :count, column: :column_name)
    end

    it "should return false if compared object is not a Measure" do
      described_class.new(Fact, :measure_name).should_not == []
    end
  end

  describe "#select_column" do
    it "should return proper sql select field statement if function specified as Symbol" do
      described_class.new(Fact, :score, :avg).select_column.should == "AVG(#{Fact.column_name_with_table('score')})"
    end

    it "should return proper sql select field statement if function specified as Proc" do
      expected = "SUM(#{Fact.column_name_with_table('score')}) / COUNT(#{Fact.column_name_with_table('score')})"
      described_class.new(Fact, :score_calc, ->{ score_sum / score_count }).select_column.should == expected
    end
  end

  describe "#to_sql" do
    it "should return proper part of sql select statement" do
      described_class.new(Fact, :score_count, :count, column: :score).to_sql.should == "COUNT(#{Fact.column_name_with_table('score')}) AS #{Fact.quote_column_name('score_count')}"
      described_class.new(Fact, :score, :avg).to_sql.should == "AVG(#{Fact.column_name_with_table('score')}) AS #{Fact.quote_column_name('score')}"
    end
  end
end