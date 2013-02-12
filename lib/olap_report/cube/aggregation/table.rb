module OlapReport
  class Cube::Aggregation::Table
    attr_reader :levels, :model

    private :model

    delegate :connection, :dimensions, :measures, to: :model

    def initialize(model, levels)
      @model = model

      @levels = levels.each_with_object([]) do |(dim,lvl),acc|
        acc << dimensions[dim].levels[lvl]
      end
    end

    def aggregate_table!
      create_table
      fill_with_values
    end

    def ==(obj)
      obj.is_a?(self.class) && self.levels == obj.levels
    end

    private
    def level_column_definitions
      levels.each_with_object([]) do |l,acc|
        columns = (l.joins ? model.association_class(l.joins) : self).columns
        acc << columns.find{|col| col.name.to_sym == l.name}
      end
    end

    def measure_column_definitions
      measures.values.map do |msr|
        model.columns.find{|col| col.name.to_sym == msr.column}.clone.tap do |column|
          column.instance_variable_set(:@name, msr.name)
          column.instance_variable_set(:@type, msr.column_type)
        end
      end
    end

    def columns
      level_column_definitions + measure_column_definitions
    end

    def table_name
      @table_name ||= ([model.table_name, 'by'] << levels.map(&:name).sort.join('_and_')).join('_')
    end

    def create_table
      connection.create_table table_name, id: false, force: true do |t|
        columns.each do |column_obj|
          options = {}
          [:default, :limit, :scale, :precision, :null, :primary, :coder].each do |opt|
            options[opt] = column_obj.public_send(opt)
          end

          t.public_send column_obj.type, column_obj.name, options
        end
      end

      connection.add_index table_name, levels.map(&:name).sort, unique: true
    end

    def fill_with_values
      dims = levels.inject({}) do |acc,l|
        acc[l.dimension_name] = l.name
        acc
      end

      projection = model.projection(dimensions: dims, measures: measures.keys)
      query = "INSERT INTO #{table_name} (#{projection.to_sql})"
      connection.execute query
    end
  end
end