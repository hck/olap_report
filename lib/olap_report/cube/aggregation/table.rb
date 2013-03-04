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

    # Creates tables with aggregated data and fills them with actual values
    def aggregate_table!
      create_table
      fill_with_values
    end

    # Updates already existing aggregations with values from new records
    def update!(start_id=nil)
      update_values_stmt =  measures.values.each_with_object([]) do |m,acc|
        stmt = build_update(m)
        if stmt
          acc << stmt
        else
          # if no statement for measure - aggregate all from scratch
          aggregate_table! and return
        end
      end

      sql = fill_sql do |rel|
        rel.where("#{model.column_name_with_table(model.primary_key)} > ?", start_id)
      end
      update_sql = [sql, "ON DUPLICATE KEY UPDATE", update_values_stmt.join(', ')].join(' ')
      connection.execute update_sql
    end

    def table_name
      @table_name ||= ([model.table_name, 'by'] << levels.map(&:name).sort.join('_and_')).join('_')
    end

    def ==(obj)
      obj.is_a?(self.class) && self.levels == obj.levels
    end

    def projection(msrs)
      relation = levels.inject(model) do |rel,l|
        rel.select model.quote_column_name(l.name)
      end

      relation = msrs.inject(relation) do |rel,m|
        rel.select model.quote_column_name(m)
      end

      relation.from table_name
    end

    private
    def level_column_definitions
      levels.each_with_object([]) do |l,acc|
        columns = (l.joins ? model.association_class(l.joins) : model).columns
        col = columns.find{|col| col.name.to_sym == l.column_name}
        col.instance_variable_set(:@name, l.name)
        acc << col
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

      index_columns = levels.map(&:name).sort
      index_name = (["idx"] + index_columns).join('_')
      connection.add_index table_name, index_columns, unique: true, name: index_name
    end

    def fill_sql
      dims = levels.each_with_object({}){ |l,acc| acc[l.dimension_name] = l.name }
      projection = model.projection(dimensions: dims, measures: measures.keys, skip_aggregated: true)
      projection = yield projection if block_given?
      "INSERT INTO #{model.quote_table_name(table_name)} (#{projection.to_sql})"
    end

    def fill_with_values
      connection.execute fill_sql
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
    def build_update(measure)
      case measure.function
      when :avg
        base_measure = measures.values.find{|v| [:sum, :count].include?(v.function)}
        if base_measure
          case base_measure.function
          when :sum
            "#{measure.name} = (#{base_measure.name} + VALUES(#{base_measure.name})) / (#{base_measure.name} / #{measure.name} + VALUES(#{base_measure.name}) / VALUES(#{measure.name}))"
          when :count
            "#{measure.name} = (#{measure.name} * #{base_measure.name} + VALUES(#{measure.name}) * VALUES(#{base_measure.name})) / (#{base_measure.name} + VALUES(#{base_measure.name})"
          end
        else
          return false
        end
      else
        '%s = %s + VALUES(%s)' % ([measure.name] * 3)
      end
    end
  end
end