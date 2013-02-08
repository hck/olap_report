require "spec_helper"

describe OlapReport::Cube do

  it "should raise error if it isn't inheritor of ActiveRecord::Base" do
    expect do
      class Bar
        include OlapReport::Cube
      end
    end.to raise_error(ArgumentError)
  end


end