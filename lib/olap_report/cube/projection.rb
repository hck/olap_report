module OlapReport
  module Cube
    module Projection
      attr_reader :dimensions, :measures, :measure_scope

      def self.extended(base)
        base.instance_variable_set(:@dimensions, {})
        base.instance_variable_set(:@measures, {})
      end

      def dimension(name, options = {})
        dimension = OlapReport::Cube::Dimension.new(self, name, options)
        yield dimension if block_given?
        @dimensions[name] = dimension
      end

      def measure(name, function = :sum, options= {})
        @measure_scope ||= OlapReport::Cube::Measure::Scope.new
        @measures[name] = OlapReport::Cube::Measure.new(self, name, function, options)
      end

      def measures_for(column, functions)
        functions.each do |function|
          measure "#{column}_#{function}".to_sym, function, column: column
        end
      end

      def projection(options)
        relation = build_relation_for_dimensions(options[:dimensions])
        build_relation_for_measures options[:measures], relation
      end

      private
      def build_relation_for_dimensions(dims, rel=nil)
        rel ||= self

        rel = dims.inject(rel) do |res,(dim,lvl)|
          dimension = dimensions[dim]
          level = dimension.levels[lvl]
          res = res.select level.select_sql
          res = res.joins(level.joins) if level.joins
          res = res.group level.group_sql
          res
        end if dims

        rel
      end

      def build_relation_for_measures(msrs, rel=nil)
        rel ||= self

        rel = msrs.inject(rel) do |res,msr|
          res = res.select measures[msr].to_sql
          res
        end if msrs

        rel
      end
    end
  end
end