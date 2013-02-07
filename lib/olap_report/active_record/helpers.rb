module OlapReport
  module ActiveRecord::Helpers
    def column_name(name)
      connection.quote_column_name(name)
    end

    def column_name_with_table(name, table_name=self.table_name)
      [connection.quote_table_name(table_name), column_name(name)].join('.')
    end

    def join_table_name(level)
      reflect_on_association(level.joins).klass.table_name
    end
  end
end