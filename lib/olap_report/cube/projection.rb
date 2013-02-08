module OlapReport
  module Cube
    module Projection
      def dimension(name, options = {})
        dimension = OlapReport::Cube::Dimension.new(name, options)
        yield dimension if block_given?
        @dimensions[name] = dimension
      end

      def dimensions
        @dimensions
      end

      def measure(name, function = :sum, options= {})
        @measures[name] = OlapReport::Cube::Measure.new(name, function, options)
      end

      def measures_for(column, functions)
        functions.each do |function|
          measure "#{column}_#{function}".to_sym, function, column: column
        end
      end

      def measures
        @measures
      end

      def measures_columns
        @measures.map{|k,v| v.column}
      end

      def projection(options)
        relation = options[:dimensions].inject(self) do |res,(dim,lvl)|
          dimension = dimensions[dim]
          level = dimension.levels[lvl]
          res = res.select build_select(level)
          res = res.joins(level.joins) if level.joins
          res = res.group build_group_by(level)
          res
        end

        relation = options[:measures].inject(relation) do |res,msr|
          measure = measures[msr]
          res.select function(measure.function, measure.column, measure.name)
        end if options[:measures]

        relation
      end

      private
      def build_select(level)
        params = level.joins ? [level.name, join_table_name(level.joins)] : level.name
        column_name_with_table(*params)
      end

      def build_group_by(level)
        if level.group_by.is_a?(Symbol)
          params = level.joins ? [level.group_by, join_table_name(level.joins)] : level.group_by
          column_name_with_table(*params)
        else
          group_by
        end
      end
    end
  end
end