require 'spec_helper'

RSpec.describe OlapReport::Cube::Aggregation::Table do
  describe '#initialize' do
    let(:table) { described_class.new(Fact, user: :group_id) }

    specify { expect(table).to be_instance_of(described_class) }
    specify { expect(table.levels.size).to eq(1) }
    specify { expect(table.levels.first).to eq(Fact.dimension(:user)[:group_id]) }

    it 'raises error if model not specified' do
      expect { described_class.new(nil, user: :group_id) }.to raise_error(ArgumentError)
    end

    it 'raises error if levels not specified' do
      expect { described_class.new(Fact, nil) }.to raise_error(ArgumentError)
    end
  end

  describe '#aggregate_table!' do
    before(:each) do
      FactoryGirl.create_list(:group, 3).each do |g|
        FactoryGirl.create_list(:user, 10, group: g).each do |u|
          FactoryGirl.create_list(:fact, 10, user: u)
        end
      end
    end

    it 'creates aggregated table' do
      table = Fact.aggregations.first
      expect(Fact.connection).to receive(:execute)
      expect(Fact.adapter).to receive(:create_aggregated_table)
      table.aggregate_table!
    end

    it 'properly fills aggregated data' do
      Fact.aggregations.first.aggregate_table!

      expected = Group.all.each_with_object({}) do |g, o|
        o[g.category] ||= Hash.new(0)
        o[g.category][:score_sum] += g.facts.inject(0) { |sum, f| sum + f.score }
        o[g.category][:score_count] += g.facts.size
      end

      FactByCategory.all.each do |fc|
        row = expected[fc.category]
        expect([fc.score_sum, fc.score_count, fc.score_avg]).to eq([row[:score_sum], row[:score_count], row[:score_sum].to_f / row[:score_count]])
      end
    end
  end

  xdescribe '#update!' do
    before(:each) do
      FactoryGirl.create_list(:group, 3).each do |g|
        FactoryGirl.create_list(:user, 10, group: g).each do |u|
          FactoryGirl.create_list(:fact, 10, user: u)
        end
      end
    end

    it "should update aggregated data properly" do
      table = Fact.aggregations.first
      table.aggregate_table!

      last_id = Fact.maximum(:id)
      FactoryGirl.create_list(:fact, 10, user: User.all.sample)

      table.update!(last_id)

      expected = Group.all.each_with_object({}) do |g, o|
        o[g.category] ||= Hash.new(0)
        o[g.category][:score_sum] += g.facts.inject(0) { |sum, f| sum + f.score }
        o[g.category][:score_count] += g.facts.size
      end

      FactByCategory.all.each do |fc|
        row = expected[fc.category]

        fc.score_sum.should == row[:score_sum]
        fc.score_count.should == row[:score_count]
        fc.score_avg.should be_within(0.001).of(row[:score_sum].to_f / row[:score_count])
      end
    end
  end

end
