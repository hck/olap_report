module OlapReport
  class Cube::Aggregation
    attr_reader :levels, :measures

    def initialize(levels_and_measures)
      raise ArgumentError unless levels_and_measures.is_a?(Hash) &&
        levels_and_measures[:levels] &&
        levels_and_measures[:measures]
      @levels, @measures = levels_and_measures.values_at(:levels, :measures)
    end

    def aggregate!
    end

    def column_names
    end

    def ==(obj)
      obj.is_a?(self.class) && self.levels == obj.levels && self.measures == obj.measures
    end
  end
end