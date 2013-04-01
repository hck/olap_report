module OlapReport
  module Cube
    module QueryMethods
      # Fetches result(slice) for specified options (dimensions & measures)
      # @param [Hash] options - projection options
      #   :dimensions - dimensions to query in
      #   :measures   - measures to calculate for specified dimensions
      def slice(options)
        a_table = aggregation(options[:dimensions])

        if !options[:skip_aggregated] && a_table
          a_table.slice(options[:measures])
        else
          build_relation(*options.values_at(:dimensions, :measures))
        end
      end

      # Fetches details for specified levels/dimensions
      # @param [Hash] options - projection options
      #   :dimensions - dimensions to query in
      #   :measures   - measures to calculate for specified dimensions
      #
      #    Fact.drilldown(user: :category) # drill 1 level down (group_id)
      #    Fact.drilldown(user: {category: :user_id}) # drill down to specified level (user_id)
      def drilldown(options)
        dimensions, measures = options.values_at(:dimensions, :measures).map{|v| Array(v)}

        joins, dims = {}, {}
        dimensions.each do |k,v|
          dim = dimension(k)

          case v
          when Hash
            raise ArgumentError, "Level for '#{k}' dimension is invalid" if v.size != 1
            lvl, details_lvl = *v.first
            dims[k]          = details_lvl
            joins.merge! dim[lvl].joins
          when Symbol
            dims[k] = dim.prev_level(v).name
            joins.merge! dim[v].joins
          end
        end

        Fact.joins(joins).slice(dimensions: dims, measures: measures, skip_aggregated: true)
      end

      def rollup(options)
        raise "Not implemented yet"
      end

      private
      def build_relation(dimensions, measures)
        relation = self

        relation = dimensions.inject(relation) do |res,(dim,lvl)|
          dimension = dimension(dim)
          by_level(dimension[lvl], res)
        end if dimensions

        relation = measures.inject(relation) do |res,msr|
          by_measure(measure(msr), res)
        end if measures

        relation
      end

      def by_level(level, rel=self)
        level.build_relation(rel)
      end

      def by_measure(measure, rel=self)
        measure.build_relation(rel)
      end
    end
  end
end