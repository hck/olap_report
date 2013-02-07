module OlapReport
  class Cube::Measure
    attr_reader :name, :function, :options

    def initialize(name, function=:sum, options={})
      # @TODO: add functions validation here
      @name, @function, @options = name, function, options
    end

    def build_select
      public_send(function)
    end

    def sum
      "SUM(#{name})"
    end

    def avg
      "AVG(#{name})"
    end
  end
end