module OlapReport
  class Cube::Dimension
    attr_reader :model, :name, :levels, :options

    private :model

    def initialize(model, name, options = {})
      @model, @name, @options, @levels = model, name, options, {}
    end

    # Defines level for dimension
    # @param [Symbol] name - level name (in general column name from table)
    # @param [Hash] options - options hash
    def level(name, options = {})
      @levels[name] = Cube::Level.new(self, name, options)
    end

    # Defines date-based levels for dimension
    def dates(field, options = {})
      levels = options[:by]
      if levels.present?
        levels.each{ |name| level name, column: field, type: name }
      else
        level field
      end
    end
  end
end