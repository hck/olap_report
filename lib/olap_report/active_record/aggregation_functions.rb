module OlapReport
  module ActiveRecord::AggregationFunctions
    def function(name, column, column_alias=nil)
      "#{name.upcase}(#{column_name_with_table(column)}) AS #{column_name(column_alias || "#{column}_#{name}")}".strip
    end
  end
end