module OlapReport
  module Cube
    module Aggregation
      def aggregation(levels)
        # aggr = OlapReport::Cube::Aggregation.new(levels: levels, measures: measures.map{|k,v| v.column})
        raise OlapReport::Cube::DuplicateAggregationError if aggregations.include?(levels)
        @aggregations = aggregations << levels
      end

      def aggregations
        @aggregations || []
      end

      def aggregate!
        @aggregations.each{ |aggr| aggregate_table!(aggr) }
      end

      private

      def aggregate_table!(levels)
        create_aggregation_table levels
        fill_with_values levels
      end

      def aggregation_columns(levels)
        level_defs = levels.inject([]) do |acc,(dim,lvl)|
          dimension = dimensions[dim]
          level = dimension.levels[lvl]

          columns = (level.joins ? association_class(level.joins) : self).columns

          acc << columns.find{|col| col.name.to_sym == level.name}
          acc
        end

        measure_defs = measures.values.map do |msr|
          self.columns.find{|col| col.name.to_sym == msr.column}.clone.tap do |column|
            column.instance_variable_set(:@name, msr.name)
          end
        end

        level_defs + measure_defs
      end

      def aggregation_table_name(levels)
        @aggregation_table_name ||= ([self.table_name, 'by'] << levels.values.sort.join('_and_')).join('_')
      end

      def create_aggregation_table(levels)
        table_name = aggregation_table_name(levels)
        connection.create_table table_name, id: false, force: true do |t|
          aggregation_columns(levels).each do |column_obj|
            options = {}
            [:default, :limit, :scale, :precision, :null, :primary, :coder].each do |opt|
              options[opt] = column_obj.public_send(opt)
            end

            t.public_send column_obj.type, column_obj.name, options
          end
        end

        connection.add_index table_name, levels.values, unique: true
      end

      def fill_with_values(levels)
        projection = self.projection(dimensions: levels, measures: measures.keys)
        query = "INSERT INTO #{aggregation_table_name(levels)} (#{projection.to_sql})"
        connection.execute query
      end
    end
  end
end