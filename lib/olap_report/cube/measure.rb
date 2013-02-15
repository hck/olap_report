module OlapReport
  class Cube::Measure
    attr_reader :model, :name, :function, :options, :column

    private :model

    delegate :measure_scope, to: :model

    ALLOWED_FUNCTIONS = [:avg, :sum, :count]

    def initialize(model, name, function=:sum, options={})
      if !ALLOWED_FUNCTIONS.include?(function) && !function.is_a?(Proc)
        raise OlapReport::Cube::ProhibitedFunctionError, "Function :#{function} is not allowed to use!"
      end

      @model, @name, @function, @options = model, name, function, options
      @column = options[:column] || name

      measure_scope.define_singleton_method name do
        Statement.new(model.measures[name].select_column)
      end
    end

    def column_type
      # @TODO: does this needs refactoring?
      case function
      when :count
        :integer
      when :avg
        :float
      else
        model.columns.find{|col| col.name.to_sym == column}.type
      end
    end

    def select_column(aggregation_table_name=nil)
      if aggregation_table_name
        model.column_name_with_table(name, aggregation_table_name)
      elsif function.is_a?(Proc)
        measure_scope.instance_exec(&function).to_sql
      else
        "#{function.upcase}(#{model.column_name_with_table(column)})"
      end
    end

    def to_sql(aggregation_table_name=nil)
      if aggregation_table_name
        select_column(aggregation_table_name)
      else
        [select_column, model.column_name(name)].join(' AS ').strip
      end
    end

    def ==(obj)
      [:name, :column, :function].inject(obj.class == self.class) do |acc,field|
        acc && send(field) == obj.send(field)
      end
    end
  end
end