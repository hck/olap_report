# @TODO needs refactoring
module OlapReport
  class Cube::Measure
    attr_reader :name, :function, :column

    delegate :adapter, :measures_scope, :column_with_alias, :quote_table_column, to: :@model

    ALLOWED_FUNCTIONS = [:avg, :sum, :count]

    def initialize(model, name, function=:sum, options={})
      raise ArgumentError unless model && name

      if !ALLOWED_FUNCTIONS.include?(function) && !function.is_a?(Proc)
        raise OlapReport::Cube::ProhibitedFunctionError, "Function :#{function} is not allowed to use!"
      end

      @model = model
      @name, @function = name, function
      @column = options[:column] || name

      measures_scope.define_singleton_method name do
        Statement.new(column_sql)
      end
    end

    def build_relation(relation)
      relation.select column_with_alias(column_sql, name)
    end

    def column_type
      # @TODO: does this needs refactoring?
      case function
      when :count
        :integer
      when :avg
        :float
      else
        #model.columns.find{|col| col.name.to_sym == column}.type
        nil
      end
    end

    private

    def column_sql
      "#{function.upcase}(#{quote_table_column(column)})"
    end
  end
end
