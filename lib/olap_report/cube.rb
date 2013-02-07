module OlapReport
  module Cube
    include OlapReport::ActiveRecord::AggregationFunctions
    include OlapReport::ActiveRecord::Helpers

    def self.included(base)
      #raise ArgumentError, "#{base.name} should be descendant from ActiveRecord::Base" unless base.is_a?(ActiveRecord::Base)

      base.extend self
      base.instance_variable_set(:@dimensions, {})
      base.instance_variable_set(:@measures, {})
    end

    def dimension(name, options = {})
      dimension = Dimension.new(name, options)
      yield dimension if block_given?
      @dimensions[name] = dimension
    end

    def dimensions
      @dimensions
    end

    def measure(name, function = :sum, options= {})
      @measures[name] = Measure.new(name, function, options)
    end

    def measures_for(column, functions)
      functions.each do |function|
        measure "#{column}_#{function}".to_sym, function, column: column
      end
    end

    def measures
      @measures
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
        res.select function(measure.function, measure.name)
      end if options[:measures]

      relation
    end

    private
    def build_select(level)
      level.joins ? column_name_with_table(level.name, join_table_name(level.joins)) : column_name_with_table(level.name)
    end

    def build_group_by(level)
      if level.group_by.is_a?(Symbol)
        level.joins ? column_name_with_table(level.group_by, join_table_name(level.joins)) : column_name_with_table(level.group_by)
      else
        group_by
      end
    end
  end
end