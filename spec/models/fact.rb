class Fact < ActiveRecord::Base
  include OlapReport::Cube

  belongs_to :user

  dimension :user do |d|
    d.level :user_id
    d.level :group_id, joins: :user
    d.level :category, joins: {user: :group}
    #d.level :date
  end

  dimension :date do |d|
    d.level :created_at
  end

  measures_for :score, [:avg, :sum]

  measure :score_count, :count, column: :score

  aggregation user: :category
  aggregation user: :group_id, date: :year

  def self.prepare_table
    connection.execute("DROP TABLE IF EXISTS #{table_name}")
    connection.create_table(table_name) do |t|
      t.integer :user_id
      t.integer :score
      t.timestamp :created_at
    end
  end
end