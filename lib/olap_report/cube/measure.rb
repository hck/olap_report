module OlapReport
  class Cube::Measure
    attr_reader :model, :name, :function, :options, :column

    private :model

    delegate :measure_scope, to: :model

    def initialize(model, name, function=:sum, options={})
      # @TODO: add functions validation here
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

    def select_column
      if function.is_a?(Proc)
        model.measure_scope.instance_exec(&function).to_sql
      else
        "#{function.upcase}(#{model.column_name_with_table(column)})"
      end
    end

    def to_sql
      [select_column, model.column_name(name)].join(' AS ').strip
    end

    def ==(obj)
      [:name, :column, :function].inject(obj.class == self.class) do |acc,field|
        acc && send(field) == obj.send(field)
      end
    end
  end
end