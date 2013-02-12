require "spec_helper"

describe OlapReport::Cube::Measure::Statement do
  [:+, :-, :*, :/].each do |func|
    describe "##{func}" do
      it "#{func} should return proper sql select statements" do
        m1 = described_class.new("SUM(a)")
        m2 = described_class.new("COUNT(a)")
        m2.public_send(func, m1).sql.should == described_class.new("COUNT(a) #{func} SUM(a)").sql
      end
    end
  end
end