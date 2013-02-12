module OlapReport
  class Cube::Measure
    attr_reader :name, :function, :options, :column
    ALLOWED_FUNCTIONS = [:avg, :sum, :count]

    def initialize(name, function=:sum, options={})
      raise OlapReport::Cube::ProhibitedFunctionError, "Function :#{function} is not allowed to use!" unless ALLOWED_FUNCTIONS.include?(function)
      @name, @function, @options = name, function, options
      @column = options[:column] || name
    end

    def ==(obj)
      [:name, :column, :function].inject(obj.class == self.class) do |acc,field|
        acc &&= send(field) == obj.send(field)
      end
    end
  end
end