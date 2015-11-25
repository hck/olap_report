module OlapReport
  module Cube
    def self.included(base)
      unless base.ancestors.include?(::ActiveRecord::Base)
        fail ArgumentError, "#{base.name} should be descendant from ActiveRecord::Base"
      end

      base.extend ClassMethods
      base.extend QueryMethods
      base.extend Aggregation
    end

    module ClassMethods
      include OlapReport::ActiveRecord::Helpers

      attr_reader :dimensions, :measures

      def self.extended(base)
        base.instance_variable_set(:@dimensions, [])
        base.instance_variable_set(:@measures, [])
      end

      # Returns adapter instance for ActiveRecord model
      #
      # @return [OlapReport::Cube::Adapters::AbstractAdapter]
      def adapter
        @adapter ||= begin
          klass_name = ['OlapReport::Cube::Adapters', connection.adapter_name + 'Adapter'].join('::')
          Object.const_get(klass_name).new(self)
        end
      end

      # Returns measures scope
      #
      # @return [OlapReport::Cube::Measure::Scope]
      def measures_scope
        @measures_scope ||= OlapReport::Cube::Measure::Scope.new
      end

      # Defines dimension for ActiveRecord model
      #
      # @param [Symbol] name dimension name
      # @param [Proc] block code block to define dimension levels etc.
      def define_dimension(name, &block)
        dimension = OlapReport::Cube::Dimension.new(self, name)
        @dimensions << dimension
        dimension.instance_exec(&block)
      end

      # Define measure for ActiveRecord model
      #
      # @param [Symbol] name measure name
      # @param [Symbol] function measure function (:sum, :avg, :count, :min, :max)
      # @param [Hash] options optional parameters
      # @return [OlapReport::Cube::Measure]
      def define_measure(name, function = :sum, options = {})
        @measures << OlapReport::Cube::Measure.new(self, name, function, options)
      end

      # Get dimension by name
      #
      # @param [Symbol] name
      # @return [OlapReport::Cube::Dimension]
      def dimension(name)
        dimensions.find { |d| d.name == name } || fail(KeyError, "Dimension #{name} not found")
      end

      # Get dimension by name
      #
      # @param [Symbol] name
      # @return [OlapReport::Cube::Measure]
      def measure(name)
        measures.find { |m| m.name == name }
      end
    end

    class ProhibitedFunctionError < StandardError; end
    class DuplicateAggregationError < StandardError; end
  end
end
