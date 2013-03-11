require "spec_helper"

describe OlapReport::Cube::Aggregation::Table do
  describe "#initialize" do
    it "should create table if model & levels specified" do
      table = described_class.new(Fact, user: :group_id)
      table.should be_instance_of(described_class)
      table.levels.size.should == 1
      table.levels.first.should == Fact.dimensions[:user].levels[:group_id]
    end

    it "should raise error if model not specified" do
      expect{ described_class.new }.to raise_error(ArgumentError)
    end

    it "should raise error if levels not specified" do
      expect{ described_class.new(Fact) }.to raise_error(ArgumentError)
    end
  end

  describe "#aggregate_table!" do
    before(:each) do
      FactoryGirl.create_list(:group, 3).each do |g|
        FactoryGirl.create_list(:user, 10, group: g).each do |u|
          FactoryGirl.create_list(:fact, 10, user: u)
        end
      end
    end

    it "should call #create_table & #fill_sql" do
      table = Fact.aggregations.first
      Fact.adapter.should_receive(:create_aggregated_table)
      #table.should_receive(:fill_sql)
      table.aggregate_table!
    end

    it "should properly create aggregated table" do
      Fact.aggregations.first.aggregate_table!

      expected = Group.all.each_with_object({}) do |g,o|
        o[g.category] ||= Hash.new(0)
        o[g.category][:score_sum] += g.facts.inject(0){|sum,f| sum + f.score}
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

  describe "#update!" do
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

      expected = Group.all.each_with_object({}) do |g,o|
        o[g.category] ||= Hash.new(0)
        o[g.category][:score_sum] += g.facts.inject(0){|sum,f| sum + f.score}
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

  #it "should test" do
  #  p FactoryGirl.create_list(:group, 2)
  #  p '+'*50
  #  sleep 20
  #end
end