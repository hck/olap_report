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
        aggregated_table_name = (!options[:skip_aggregated] && a_table && a_table.table_name) || nil

        relation = build_relation_for_dimensions(options[:dimensions], self, aggregated_table_name)
        build_relation_for_measures options[:measures], relation, aggregated_table_name
      end

      private
      def build_relation_for_dimensions(dims, rel=nil, aggregated_table_name=nil)
        rel ||= self

        rel = dims.inject(rel) do |res,(dim,lvl)|
          dimension = dimensions[dim]
          level = dimension.levels[lvl]

          # if aggregated_table_name is not specified, will fetch data from model table
          res = res.select level.select_sql(aggregated_table_name)

          # join relative tables if no aggregated table passed
          if !aggregated_table_name && level.joins
            res = res.joins(level.joins)
          end

          # group by level if no aggregation table found
          res = res.group level.group_sql if !aggregated_table_name

          # replace source tables with aggregated table name
          res = res.from(aggregated_table_name) if aggregated_table_name

          res
        end if dims

        rel
      end

      def build_relation_for_measures(msrs, rel=nil, aggregated_table_name=nil)
        rel ||= self

        rel = msrs.inject(rel) do |res,msr|
          res = res.select measures[msr].to_sql(aggregated_table_name)
          res
        end if msrs

        rel
      end
    end
  end
end