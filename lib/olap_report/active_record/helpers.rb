module OlapReport
  module ActiveRecord
    module Helpers
      delegate :quote_column_name, :quote_table_name, to: :connection

      def column_name_with_table(name, table_name=self.table_name)
        [quote_table_name(table_name), quote_column_name(name)].join('.')
      end

      def join_table_name(joins)
        association_class(joins).table_name
      end

      def association_class(joins, k=nil)
        if joins.is_a? Hash
          key = joins.keys.first
          klass = reflect_on_association(key).klass
          association_class(joins[key], klass)
        else
          (k || self).reflect_on_association(joins).klass
        end
      end
    end
  end
end