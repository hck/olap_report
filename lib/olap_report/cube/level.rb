module OlapReport
  class Cube::Level
    attr_reader :dimension, :name, :column_name, :joins, :type

    private :dimension

    delegate :model, to: :dimension

    # New level instance initialization
    # @param [OlapReport::Cube::Dimension] dimension - dimension to include level in
    # @param [Symbol] name - level name
    # @param [Hash] options - hash containing :column, :joins, :type
    #   :column overrides column name, that is usually taken from level name
    #   :joins  specifies joined relations
    #   :type   specifies level type (:hour, :day, :week, :month, :year for grouping of date/time based fields)
    # @return [OlapReport::Cube::Level]
    def initialize(dimension, name, options = {})
      @dimension, @name, @options = dimension, name, options.select{|k,| [:joins, :group_by, :type].include?(k)}
      raise ArgumentError if options[:joins].is_a?(Hash) && options[:joins].size > 1
      @joins, @group_by = options.values_at(:joins, :group_by)

      @column_name, @type = (options[:column] || @name), options[:type]
    end

    # Returns group by column
    def group_by
      @group_by || column
    end

    # Returns
    def column
      field = model.column_name_with_table(@column_name, table_name_for_sql)
      type ? model.adapter.column_name(field, type) : field
    end

    # Returns select part of sql statement for level
    def select_sql
      if type
        [column, name].join(' AS ')
      else
        column
      end
    end

    # Returns group_by part of sql statement for level
    def group_sql
      if group_by.is_a?(Symbol)
         model.column_name_with_table(group_by, table_name_for_sql)
      else
        group_by
      end
    end

    def dimension_name
      dimension.name
    end

    private
    def table_name_for_sql
      if joins
        model.join_table_name(joins)
      else
        model.table_name
      end
    end
  end
end