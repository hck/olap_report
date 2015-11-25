require 'spec_helper'

RSpec.describe OlapReport::Cube::Measure::Statement do
  [:+, :-, :*, :/].each do |func|
    describe "##{func}" do
      it "#{func} returns proper sql select statements" do
        m1 = described_class.new('SUM(a)')
        m2 = described_class.new('COUNT(a)')
        expect(m2.public_send(func, m1).sql).to eq(described_class.new("COUNT(a) #{func} SUM(a)").sql)
      end
    end
  end
end
