module OlapReport
  module Cube
    module Aggregation
      attr_reader :aggregations

      def self.extended(base)
        base.instance_variable_set(:@aggregations, [])
      end

      def define_aggregation(levels)
        table = Table.new(self, levels)
        raise OlapReport::Cube::DuplicateAggregationError if aggregations.include?(table)
        @aggregations << table
      end

      def aggregate!
        aggregations.each(&:aggregate_table!)
      end

      def update!
        aggregations.each(&:update!)
      end

      def aggregation(levels)
        aggregations.find do |a|
          levels_def = a.levels.each_with_object({}){|level,acc| acc[level.dimension_name] = level.name}
          levels_def == levels
        end
      end
    end
  end
end