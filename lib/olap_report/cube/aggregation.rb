module OlapReport
  module Cube
    module Aggregation
      attr_reader :aggregations

      def self.extended(base)
        base.instance_variable_set(:@aggregations, [])
      end

      def aggregation(levels)
        table = Table.new(self, levels)
        raise OlapReport::Cube::DuplicateAggregationError if aggregations.include?(table)
        @aggregations << table
      end

      def aggregate!
        aggregations.each(&:aggregate_table!)
      end
    end
  end
end