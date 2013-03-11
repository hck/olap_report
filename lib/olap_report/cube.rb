module OlapReport
  module Cube
    def self.included(base)
      raise ArgumentError, "#{base.name} should be descendant from ActiveRecord::Base" unless base.ancestors.include?(::ActiveRecord::Base)

      base.extend ClassMethods
      base.extend Aggregation
      base.extend Projection
    end

    module ClassMethods
      include OlapReport::ActiveRecord::Helpers

      def adapter
        @adapter ||= ['OlapReport::Cube::Adapters', self.connection.adapter_name].join('::').constantize.new(self)
      end
    end

    class ProhibitedFunctionError < StandardError; end
    class DuplicateAggregationError < StandardError; end
  end
end