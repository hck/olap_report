class User < ActiveRecord::Base
  has_many :facts
  belongs_to :group

  def self.prepare_table
    connection.execute("DROP TABLE IF EXISTS #{table_name}")
    connection.create_table(table_name) do |t|
      t.string :name
      t.integer :group_id
      t.timestamp :registered_at
    end
  end
end