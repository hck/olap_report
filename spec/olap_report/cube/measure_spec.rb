require 'spec_helper'

describe OlapReport::Cube::Measure do
  it "validates incoming functions" do
    expect { described_class.new(:foobar, :bad_function, {}) }.to raise_exception(OlapReport::Cube::ProhibitedFunctionError)
  end
end
