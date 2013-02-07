class Group < ActiveRecord::Base
  include OlapReport::Cube

  has_many :users

  def self.prepare_table
    connection.execute("DROP TABLE IF EXISTS #{table_name}")
    connection.create_table(table_name) do |t|
      t.string :name
      t.string :category
    end
  end
end