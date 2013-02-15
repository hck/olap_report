require "spec_helper"

describe OlapReport::Report do
  before(:all) do
    class TestReport
      include OlapReport::Report

      cube_class Fact
      dimensions user: :category
      measures :score_count
    end
  end

  before(:each) do
    @facts = FactoryGirl.create_list(:fact, 10)
  end

  it "returns array of structs as result" do
    Fact.aggregate! # needed here because of FactoryGirl
    TestReport.new.to_a.first.should be_a(Struct)
  end
end