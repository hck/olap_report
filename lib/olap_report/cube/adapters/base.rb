module OlapReport::Cube::Adapters
  class Base
    attr_reader :model

    delegate :connection, :dimensions, :measures, to: :model

    private :model

    def initialize(model)
      @model = model
    end

    # @param [OlapReport::Cube::Aggregation::Table] table
    def create_aggregated_table(table)
      connection.create_table table.table_name, id: false, force: true do |t|
        table.columns.each do |column_obj|
          options = {}
          [:default, :limit, :scale, :precision, :null, :primary, :coder].each do |opt|
            options[opt] = column_obj.public_send(opt)
          end

          t.public_send column_obj.type, column_obj.name, options
        end
      end

      index_columns = table.levels.map(&:name).sort
      index_name = (%w|idx| + index_columns).join('_')
      connection.add_index table.table_name, index_columns, unique: true, name: index_name
    end

    # Build update statements for measures' values
    #   sum   = sum + new sum
    #   count = count + new count
    #   max   = MAX(max, new max)
    #   min   = MIN(min, new min)
    #   avg
    #     if no count or sum measures in current aggregation, recreate aggregated table from scratch
    #     if count measure exists
    #       avg = (avg * count + new avg * new count) / (count + new count)
    #     if sum measure exists
    #       avg = (sum + new sum) / (sum / avg + new sum / new avg)
    # @param [OlapReport::Cube::Measure] measure
    def measure_update_sql(measure)
    end

    def update_aggregated_table(query, update_values_sql)
      connection.execute query
    end
  end
end