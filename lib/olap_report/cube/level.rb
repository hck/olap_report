module OlapReport
  class Cube::Level
    attr_reader :dimension, :name, :options, :joins

    private :dimension

    delegate :model, to: :dimension

    def initialize(dimension, name, options = {})
      @dimension, @name, @options = dimension, name, options.select{|k,v| [:joins, :group_by].include?(k)}
      raise ArgumentError if options[:joins].is_a?(Hash) && options[:joins].size > 1
      @joins, @group_by = options.values_at(:joins, :group_by)
    end

    def group_by
      @group_by || name
    end

    def select_sql(aggregation_table_name=nil)
      model.column_name_with_table(name, table_name_for_sql(aggregation_table_name))
    end

    def group_sql(aggregation_table_name=nil)
      if group_by.is_a?(Symbol)
         model.column_name_with_table(group_by, table_name_for_sql(aggregation_table_name))
      else
        group_by
      end
    end

    def dimension_name
      dimension.name
    end

    private
    def table_name_for_sql(aggregation_table_name=nil)
      if aggregation_table_name
        aggregation_table_name
      elsif joins
        model.join_table_name(joins)
      else
        model.table_name
      end
    end
  end
end