module OlapReport
  module Cube
    def self.included(base)
      raise ArgumentError, "#{base.name} should be descendant from ActiveRecord::Base" unless base.ancestors.include?(::ActiveRecord::Base)

      base.extend ClassMethods
      base.extend Cube::Aggregation
      base.extend Cube::Projection
      base.instance_variable_set(:@dimensions, {})
      base.instance_variable_set(:@measures, {})
    end

    class DuplicateAggregationError < StandardError; end
  end

  module ClassMethods
    include OlapReport::ActiveRecord::AggregationFunctions
    include OlapReport::ActiveRecord::Helpers
  end
end