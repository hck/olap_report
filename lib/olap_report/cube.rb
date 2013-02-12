module OlapReport
  module Cube
    def self.included(base)
      raise ArgumentError, "#{base.name} should be descendant from ActiveRecord::Base" unless base.ancestors.include?(::ActiveRecord::Base)

      base.extend Cube::ClassMethods
      base.extend Cube::Aggregation
      base.extend Cube::Projection
    end

    module ClassMethods
      include OlapReport::ActiveRecord::Helpers
    end

    class DuplicateAggregationError < StandardError; end
  end
end