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

    def select_sql
      params = joins ? [name, model.join_table_name(joins)] : name
      model.column_name_with_table(*params)
    end

    def group_sql
      if group_by.is_a?(Symbol)
         params = joins ? [group_by, model.join_table_name(joins)] : group_by
         model.column_name_with_table(*params)
       else
         group_by
       end
    end

    def dimension_name
      dimension.name
    end
  end
end