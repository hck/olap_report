module OlapReport
  class Cube::Aggregation::Table
    attr_reader :levels

    delegate :adapter, :connection, :dimension, :measures, :quote_table_column, :quote_column_name, :quote_table_name, to: :@model

    def initialize(model, levels)
      raise ArgumentError unless model && levels

      @model = model

      @levels = levels.each_with_object([]) do |(dim,lvl),acc|
        acc << dimension(dim)[lvl]
      end
    end

    # Creates tables with aggregated data and fills them with actual values
    def aggregate_table!
      adapter.create_aggregated_table(self)
      connection.execute fill_sql
    end

    # Updates already existing aggregations with values from new records
    def update!(start_id=nil)
      query = fill_sql do |rel|
        rel.where("#{quote_table_column(@model.primary_key)} > ?", start_id)
      end
      adapter.update_aggregated_table query, build_update_statements_for_measures
    end

    def table_name
      @table_name ||= ([@model.table_name, 'by'] << levels.map(&:name).sort.join('_and_')).join('_')
    end

    def columns
      level_column_definitions + measure_column_definitions
    end

    def ==(obj)
      obj.is_a?(self.class) && self.levels == obj.levels
    end

    def slice(msrs)
      relation = levels.inject(model) do |rel,l|
        rel.select quote_column_name(l.name)
      end

      relation = msrs.inject(relation) do |rel,m|
        rel.select quote_column_name(m)
      end

      relation.from table_name
    end

    def build_update_statements_for_measures
      measures.each_with_object([]) do |m,acc|
        stmt = adapter.measure_update_sql(m, measures)
        stmt && acc << stmt
      end
    end

    private
    def level_column_definitions
      levels.each_with_object([]) do |l,acc|
        columns = (l.joins ? @model.association_class(l.joins) : model).columns
        col = columns.find{|col| col.name.to_sym == l.column_name}
        col.instance_variable_set(:@name, l.name)
        acc << col
      end
    end

    def measure_column_definitions
      measures.map do |msr|
        @model.columns.find{|col| col.name.to_sym == msr.column}.clone.tap do |column|
          type = msr.column_type
          column.instance_variable_set(:@name, msr.name)
          column.instance_variable_set(:@type, type) if type
        end
      end
    end

    def fill_sql
      dims = levels.each_with_object({}){ |l,acc| acc[l.dimension_name] = l.name }
      slice = @model.slice(dimensions: dims, measures: measures.map(&:name), skip_aggregated: true)
      slice = yield slice if block_given?

      "INSERT INTO #{quote_table_name(table_name)} (#{slice.to_sql})"
    end
  end
end
