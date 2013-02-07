module OlapReport
  class Cube::Dimension
    attr_reader :name, :levels, :options

    def initialize(name, options = {})
      @name, @options, @levels = name, options, {}
    end

    def level(name, options = {})
      @levels[name] = Cube::Level.new(name, options)
    end
  end
end