module OlapReport
  class Cube::Dimension
    attr_reader :name, :levels, :model

    def initialize(model, name)
      raise ArgumentError unless model && name
      @levels = []
      @name = name
      @model = model
    end

    # Defines level for dimension
    # @param [Symbol] name - level name (in general column name from table)
    # @param [Hash] options - options hash
    def level(name, options = {})
      @levels << Cube::Level.new(self, name, options)
    end

    # Defines date-based levels for dimension
    # @param [Symbol] field - column name for date levels
    # @param [Hash] options - date periods for levels
    def dates(field, options = {})
      levels = options[:by]
      if levels.present?
        levels.each{ |name| level name, column: field, type: name }
      else
        level field
      end
    end

    # Finds level by name from dimension
    # @param [Symbol] level_name
    # @return [OlapReport::Cube::Level]
    def [](level_name)
      levels.find{|l| l.name == level_name}
    end
  end
end