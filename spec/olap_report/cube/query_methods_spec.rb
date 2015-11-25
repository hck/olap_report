require 'spec_helper'

describe OlapReport::Cube::QueryMethods do
  before(:all) do
    @facts = FactoryGirl.create_list(:fact, 10)
  end

  describe "::slice" do
    it "should fetch level" do
      Fact.slice(dimensions: { user: :user_id }).should == Fact.select('"facts"."user_id" AS "user_id"').group('"facts"."user_id"')
    end

    it "should fetch level with joins" do
      Fact.slice(dimensions: { user: :group_id }).should == Fact.select('"users"."group_id" AS "group_id"').joins(:user).group('"users"."group_id"')
    end

    it "should fetch level through another level" do
      Fact.slice(dimensions: { user: :category }, skip_aggregated: true).should == Fact.select('"groups"."category" AS "category"').joins(user: :group).group('"groups"."category"')
    end

    it "should fetch specified dimension & measure" do
      expected = Fact.select("#{Fact.quote_table_column('group_id', 'users')}, SUM(#{Fact.quote_table_column('score')}) group_score, COUNT(#{Fact.quote_table_column('score')}) score_count").
        joins(:user).group(Fact.quote_table_column('group_id', 'users'))
      Fact.slice(dimensions: { user: :group_id }, measures: [:score_sum]).map(&:score_sum).should == expected.map(&:group_score)
      Fact.slice(dimensions: { user: :group_id }, measures: [:score_sum]).map(&:group_id).should == expected.map(&:group_id)
      Fact.slice(dimensions: { user: :group_id }, measures: [:score_count]).map(&:score_count).should == expected.map(&:score_count)
    end

    it "should calculate correct average" do
      expected = Fact.select("#{Fact.quote_table_column('group_id', 'users')}, AVG(#{Fact.quote_table_column('score')}) score_avg").
        joins(:user).group(Fact.quote_table_column('group_id', 'users'))
      Fact.slice(dimensions: { user: :group_id }, measures: [:score_avg]).map(&:score_avg).should == expected.map(&:score_avg)
    end

    #it "should select data from aggregated table if it was defined for specified dimensions & levels" do
    #  Fact.aggregate!
    #  expected = Fact.select("#{Fact.quote_column_name('category')}, #{Fact.quote_column_name('score_count')}").
    #    from('facts_by_category')
    #  Fact.projection(dimensions: {user: :category}, measures: [:score_count]).should == expected
    #end

    describe "date levels" do
      it "should fetch dimension grouped by month" do
        level = Fact.dimension(:date)[:month]
        field = '"facts"."created_at"'

        Fact.adapter.should_receive(:column_name).with(field, level.type).exactly(2).times
        Fact.slice(dimensions: { date: :month, user: :user_id })
      end
    end
  end

  describe "::drilldown" do
    it "should fetch level details down the hierarchy 1 level" do
      expected = Fact.select('"users"."group_id" AS "group_id", COUNT("facts"."score") AS "score_count"').
        joins(user: :group).
        group('"users"."group_id"')

      Fact.drilldown(dimensions: { user: :category }, measures: :score_count).should == expected
    end

    it "should fetch level details down the hierarchy to the specified level" do
      expected = Fact.select('"facts"."user_id" AS "user_id", COUNT("facts"."score") AS "score_count"').
        joins(user: :group).
        group('"facts"."user_id"')

      Fact.drilldown(dimensions: { user: { category: :user_id } }, measures: :score_count).should == expected
    end
  end
end
