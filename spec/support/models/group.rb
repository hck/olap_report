class Group < ActiveRecord::Base
  has_many :users
  has_many :facts, through: :users

  def self.prepare_table
    connection.execute("DROP TABLE IF EXISTS #{table_name}")
    connection.create_table(table_name) do |t|
      t.string :name
      t.string :category
    end
  end
end