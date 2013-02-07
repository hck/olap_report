module OlapReport
  module Cube
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

    def measures
      @measures
    end

    def projection(options)
      relation = options[:cube].inject(self) do |res,(dim,lvl)|
        dimension = dimensions[dim]
        level = dimension.levels[lvl]
        res = res.select build_select(level)
        res = res.joins(level.joins) if level.joins
        res = res.group build_group_by(level)
        res
      end

      relation = options[:measures].inject(relation) do |res,msr|
        measure = measures[msr]
        p measure.build_select
        res.select(measure.build_select)
      end if options[:measures]

      relation
    end

    private
    def column_name_with_table(name, table_name=self.table_name)
      [connection.quote_table_name(table_name), connection.quote_column_name(name)].join('.')
    end

    def join_table_name(level)
      reflect_on_association(level.joins).klass.table_name
    end

    def build_select(level)
      level.joins ? column_name_with_table(level.name, join_table_name(level)) : column_name_with_table(level.name)
    end

    def build_group_by(level)
      if level.group_by.is_a?(Symbol)
        level.joins ? column_name_with_table(level.group_by, join_table_name(level)) : column_name_with_table(level.group_by)
      else
        group_by
      end
    end
  end
end