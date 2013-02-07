require "spec_helper"

describe OlapReport::Cube::Level do
  describe "#initialize" do
    it "should create level if name specified" do
      described_class.new(:level).should be_instance_of(described_class)
    end

    it "should raise exception if name is not provided" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end
end