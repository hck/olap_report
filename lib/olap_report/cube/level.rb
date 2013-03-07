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

      if type
        klass = [self.class.name, model.connection.adapter_name].join('::').constantize
        klass.column_name(field, type)
      else
        field
      end
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

    module PostgreSQL
      def self.column_name(field, type)
        case type
        when :minute
          "date_trunc('minute', #{field})"
        when :hour
          "date_trunc('hour', #{field})"
        when :day
          "date_trunc('day', #{field})"
        when :week
          "date_trunc('week', #{field})"
        when :month
          "date_trunc('month', #{field})"
        when :year
          "date_trunc('year', #{field})"
        end
      end
    end

    module Mysql2
      def self.column_name(field, type)
        case type
        when :minute
          "DATE_FORMAT(#{field}, '%Y-%m-%d %H:%i')"
        when :hour
          "DATE_FORMAT(#{field}, '%Y-%m-%d %H')"
        when :day
          "DATE_FORMAT(#{field}, '%Y-%m-%d')"
        when :week
          "DATE_FORMAT(#{field}, '%Y-%U')"
        when :month
          "DATE_FORMAT(#{field}, '%Y-%m')"
        when :year
          "DATE_FORMAT(#{field}, '%Y')"
        end
      end
    end
  end
end