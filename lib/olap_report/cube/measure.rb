module OlapReport
  class Cube::Measure
    attr_reader :name, :function, :options

    def initialize(name, function=:sum, options={})
      # @TODO: add functions validation here
      @name, @function, @options = name, function, options
    end
  end
end