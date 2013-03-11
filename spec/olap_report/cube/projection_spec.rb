require 'spec_helper'

describe OlapReport::Cube::Projection do
  it "should respond to dimensions method" do
    Fact.should respond_to(:dimensions)
  end

  it "should respond to measures method" do
    Fact.should respond_to(:measures)
  end

  it "should return defined cube" do
    Fact.dimensions.size.should == 2

    [:user_id, :group_id, :category].each do |level_name|
      Fact.dimensions[:user].levels[level_name].should be_instance_of(OlapReport::Cube::Level)
      Fact.dimensions[:user].levels[level_name].name.should == level_name
    end
  end

  describe "::measure" do
    it "should define valid measure" do
      Fact.measures[:score_count].should == OlapReport::Cube::Measure.new(Fact, :score_count, :count, column: :score)
    end
  end

  describe "::measures_for" do
    it "should define valid measures for column" do
      Fact.measures[:score_sum].should == OlapReport::Cube::Measure.new(Fact, :score_sum, :sum, column: :score)
      Fact.measures[:score_avg].should == OlapReport::Cube::Measure.new(Fact, :score_avg, :avg, column: :score)
    end
  end

  describe "::projection" do
    before(:each) do
      @facts = FactoryGirl.create_list(:fact, 10)
    end

    it "should fetch dimension grouped by level name" do
      fields = {user_id: :facts, group_id: :users, category: :groups}.each_with_object({}) do |(k,v),acc|
        acc[k] = Fact.column_name_with_table(k,v)
      end

      Fact.projection(dimensions: {user: :user_id}).should == Fact.select(fields[:user_id]).group(fields[:user_id])
      Fact.projection(dimensions: {user: :group_id}).should == Fact.select(fields[:group_id]).joins(:user).group(fields[:group_id])
      Fact.projection(dimensions: {user: :category}, skip_aggregated: true).should == Fact.select(fields[:category]).joins(user: :group).group(fields[:category])
    end

    it "should fetch specified dimension & measure" do
      expected = Fact.select("#{Fact.column_name_with_table('group_id', 'users')}, SUM(#{Fact.column_name_with_table('score')}) group_score, COUNT(#{Fact.column_name_with_table('score')}) score_count").
        joins(:user).group(Fact.column_name_with_table('group_id', 'users'))
      Fact.projection(dimensions: {user: :group_id}, measures: [:score_sum]).map(&:score_sum).should == expected.map(&:group_score)
      Fact.projection(dimensions: {user: :group_id}, measures: [:score_sum]).map(&:group_id).should == expected.map(&:group_id)
      Fact.projection(dimensions: {user: :group_id}, measures: [:score_count]).map(&:score_count).should == expected.map(&:score_count)
    end

    it "should calculate correct average" do
      expected = Fact.select("#{Fact.column_name_with_table('group_id', 'users')}, AVG(#{Fact.column_name_with_table('score')}) score_avg").
        joins(:user).group(Fact.column_name_with_table('group_id', 'users'))
      Fact.projection(dimensions: {user: :group_id}, measures: [:score_avg]).map(&:score_avg).should == expected.map(&:score_avg)
    end

    it "should select data from aggregated table if it was defined for specified dimensions & levels" do
      Fact.aggregate!
      expected = Fact.select("#{Fact.quote_column_name('category')}, #{Fact.quote_column_name('score_count')}").
        from('facts_by_category')
      Fact.projection(dimensions: {user: :category}, measures: [:score_count]).should == expected
    end

    describe "date levels" do
      it "should fetch dimension grouped by month" do
        #expected = Fact.select("DATE_FORMAT(`facts`.`created_at`, '%Y-%m') AS month").
        #  select('`facts`.`user_id`').
        #  group("DATE_FORMAT(`facts`.`created_at`, '%Y-%m'), `facts`.`user_id`")

        level = Fact.dimensions[:date].levels[:month]
        field = Fact.column_name_with_table('created_at')
        Fact.adapter.should_receive(:column_name).with(field, level.type).exactly(3).times

        Fact.projection(dimensions: {date: :month, user: :user_id})
      end
    end
  end
end