module OlapReport::Cube::Adapters
  class Mysql2Adapter < AbstractAdapter
    # def create_aggregated_table(table)
    #   super
    #
    #   keys_condition = table.levels.map { |l| "#{l.name} = NEW.#{l.name}" }.join(' AND ')
    #   measures_sql = table.build_update_statements_for_measures
    #
    #   connection.execute <<-SQL
    #     CREATE OR REPLACE FUNCTION #{table.table_name}_update_measures() RETURNS TRIGGER AS $$
    #     BEGIN
    #       IF (EXISTS(SELECT 1 FROM #{table.table_name} WHERE #{keys_condition})) THEN
    #         UPDATE #{table.table_name}
    #         SET #{measures_sql.join(', ')}
    #         WHERE #{keys_condition};
    #         RETURN NULL;
    #       ELSE
    #         RETURN NEW;
    #       END IF;
    #     END;
    #     $$ LANGUAGE plpgsql;
    #
    #     CREATE TRIGGER update_measures
    #       BEFORE INSERT ON #{table.table_name}
    #       FOR EACH ROW EXECUTE PROCEDURE #{table.table_name}_update_measures();
    #   SQL
    # end

    def column_name(field, type)
      case type
      when :minute
        "DATE_FORMAT(#{field}, '%Y-%m-%d %H:%i')"
      when :hour
        "DATE_FORMAT(#{field}, '%Y-%m-%d %H')"
      when :day
        "DATE_FORMAT(#{field}, '%Y-%m-%d')"
      when :week
        "DATE_FORMAT(#{field}, '%Y-%U')"
      when :month
        "DATE_FORMAT(#{field}, '%Y-%m')"
      when :year
        "DATE_FORMAT(#{field}, '%Y')"
      end
    end

    def update_aggregated_table(query, update_values_sql)
      connection.execute [sql, 'ON DUPLICATE KEY UPDATE', update_values_sql.join(', ')].join(' ')
    end

    def measure_update_sql(measure)
      case measure.function
      when :avg
        base_measure = measures.values.find { |v| [:sum, :count].include?(v.function) }
        if base_measure
          case base_measure.function
          when :sum
            "#{measure.name} = (#{base_measure.name} + VALUES(#{base_measure.name})) / (#{base_measure.name} / #{measure.name} + VALUES(#{base_measure.name}) / VALUES(#{measure.name}))"
          when :count
            "#{measure.name} = (#{measure.name} * #{base_measure.name} + VALUES(#{measure.name}) * VALUES(#{base_measure.name})) / (#{base_measure.name} + VALUES(#{base_measure.name}))"
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
