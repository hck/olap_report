class Fact < ActiveRecord::Base
  include OlapReport::Cube

  belongs_to :user

  dimension :user do |d|
    d.level :user_id
    d.level :group, joins: :user
    #d.level :date
  end

  measure :score

  def self.prepare_table
    connection.execute("DROP TABLE IF EXISTS #{table_name}")
    connection.create_table(table_name) do |t|
      t.integer :user_id
      t.integer :score
      t.timestamp :created_at
    end
  end
end