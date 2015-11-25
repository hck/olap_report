module OlapReport
  class Cube::Level
    attr_reader :dimension_name, :name, :column_name, :joins, :type

    delegate :adapter, :column_with_alias, :quote_table_column, :join_table_name, :table_name, to: :@model

    # New level instance initialization
    # @param [OlapReport::Cube::Dimension] dimension Instance of dimension
    # @param [Symbol] name Level name
    # @param [Hash] options Additional options
    # @option options [Symbol, String] :column Overrides column name, that is usually taken from level name
    # @option options [Hash] :joins Specifies joined relations
    # @option options [Symbol] :type Specifies level type (:hour, :day, :week, :month, :year for grouping of date/time based fields)
    # @return instance of OlapReport::Cube::Level
    def initialize(dimension, name, options = {})
      raise ArgumentError unless dimension && name
      raise ArgumentError if options[:joins].is_a?(Hash) && options[:joins].size > 1

      @model = dimension.model
      @dimension_name = dimension.name
      @name = name
      @column_name = options[:column] || @name
      @joins, @type = options.values_at(:joins, :type)
    end

    # Applies necessary select, joins & group_by statements to passed relation
    def build_relation(relation)
      relation.select(column_with_alias(column, name)).
        joins(joins).
        group(@group_by || column)
    end

    private

    def column
      table = joins ? join_table_name(joins) : table_name
      field = quote_table_column(@column_name, table)
      type ? adapter.column_name(field, type) : field
    end
  end
end
