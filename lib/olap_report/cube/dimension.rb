module OlapReport
  class Cube::Dimension
    attr_reader :model, :name, :levels, :options

    private :model

    def initialize(model, name, options = {})
      @model, @name, @options, @levels = model, name, options, {}
    end

    def level(name, options = {})
      @levels[name] = Cube::Level.new(self, name, options)
    end
  end
end