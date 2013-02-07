module OlapReport
  class Cube::Measure
    attr_reader :name, :function, :options, :column

    def initialize(name, function=:sum, options={})
      # @TODO: add functions validation here
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