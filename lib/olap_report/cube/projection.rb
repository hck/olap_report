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
        a_table = find_aggregation(options[:dimensions])

        if !options[:skip_aggregated] && a_table
          a_table.projection(options[:measures])
        else
          build_relation(*options.values_at(:dimensions, :measures))
        end
      end

      private
      def build_relation(dims, msrs)
        relation = self

        relation = dims.inject(relation) do |res,(dim,lvl)|
          dimension = dimensions[dim]
          level = dimension.levels[lvl]

          res = res.select level.select_sql
          res = res.joins(level.joins) if level.joins
          res = res.group level.group_sql

          res
        end if dims

        relation = msrs.inject(relation) do |res,msr|
          res = res.select measures[msr].to_sql
          res
        end if msrs

        relation
      end
    end
  end
end