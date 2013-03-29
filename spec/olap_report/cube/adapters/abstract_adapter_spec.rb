require 'spec_helper'

describe OlapReport::Cube::Adapters::AbstractAdapter do
  describe "#initialize" do
    it "should initialize instance with specified model" do
      described_class.new(Fact).should be_instance_of(described_class)
    end

    it "should raise ArgumentError if model is nil" do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
    end
  end

  describe "method calls" do
    let(:adapter){ described_class.new(Fact) }

    it "should forward calls of missing methods to @connection" do
      adapter.adapter_name.should == Fact.connection.adapter_name
    end

    it "should raise NoMethodError error if connection does not respond to missing method" do
      expect { adapter.foo }.to raise_error(NoMethodError)
    end
  end
end