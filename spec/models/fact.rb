class Fact < ActiveRecord::Base
  include OlapReport::Cube

  belongs_to :user

  define_dimension :user do
    level :user_id
    level :group_id, joins: :user
    level :category, joins: {user: :group}
  end

  define_dimension :date do
    dates :created_at, by: [:day, :week, :month, :quoter, :year]
  end

  define_measure :score_avg, :avg, column: :score
  define_measure :score_sum, :sum, column: :score
  define_measure :score_count, :count, column: :score

  define_aggregation user: :category
  define_aggregation user: :group_id, date: :month

  def self.prepare_table
    connection.execute("DROP TABLE IF EXISTS #{table_name}")
    connection.create_table(table_name) do |t|
      t.integer :user_id
      t.integer :score
      t.timestamp :created_at
    end
  end
end