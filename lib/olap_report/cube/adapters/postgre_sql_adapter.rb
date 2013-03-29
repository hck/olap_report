module OlapReport::Cube::Adapters
  class PostgreSQLAdapter < AbstractAdapter
    def create_aggregated_table(table)
      super

      keys_condition = table.levels.map{|l| "#{l.name} = NEW.#{l.name}"}.join(' AND ')
      measures_sql = table.build_update_statements_for_measures

      connection.execute <<-SQL
        CREATE OR REPLACE FUNCTION #{table.table_name}_update_measures() RETURNS TRIGGER AS $$
        BEGIN
          IF (EXISTS(SELECT 1 FROM #{table.table_name} WHERE #{keys_condition})) THEN
            UPDATE #{table.table_name}
            SET #{measures_sql.join(', ')}
            WHERE #{keys_condition};
            RETURN NULL;
          ELSE
            RETURN NEW;
          END IF;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER update_measures
          BEFORE INSERT ON #{table.table_name}
          FOR EACH ROW EXECUTE PROCEDURE #{table.table_name}_update_measures();
      SQL
    end

    def column_name(field, type)
      case type
      when :minute
        "date_trunc('minute', #{field})"
      when :hour
        "date_trunc('hour', #{field})"
      when :day
        "date_trunc('day', #{field})"
      when :week
        "date_trunc('week', #{field})"
      when :month
        "date_trunc('month', #{field})"
      when :year
        "date_trunc('year', #{field})"
      end
    end

    def measure_update_sql(measure, measures=[])
      case measure.function
      when :avg
        base_measure = measures.find{|v| [:sum, :count].include?(v.function)}
        if base_measure
          case base_measure.function
          when :sum
            "#{measure.name} = (#{base_measure.name} + NEW.#{base_measure.name}) / (#{base_measure.name} / #{measure.name} + NEW.#{base_measure.name} / NEW.#{measure.name})"
          when :count
            "#{measure.name} = (#{measure.name} * #{base_measure.name} + NEW.#{measure.name} * NEW.#{base_measure.name}) / (#{base_measure.name} + NEW.#{base_measure.name})"
          end
        else
          return false
        end
      else
        '%s = %s + NEW.%s' % ([measure.name] * 3)
      end
    end
  end
end