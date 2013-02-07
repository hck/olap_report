module OlapReport
  module Report
    delegate :to_ary, :to_a, :empty?, :[], :first, :last, to: :result

    def self.included(base)
      base.extend ClassMethods
    end

    def initialize(options={})
      class_opts = self.class.options
      @relation = class_opts[:cube_class].projection(dimensions: class_opts[:dimensions], measures: class_opts[:measures])
      @options = options
    end

    private
    def result
      @result || _result
    end

    def _result
      cols = self.class.options[:dimensions].values + self.class.options[:measures]
      klass = Struct.new(*cols)
      @relation.where(@options[:conditions]).order(@options[:order]).map do |row| # => Struct
        klass.new(cols.map{ |col| row.public_send(col) })
      end
    end

    module ClassMethods
      def cube_class(klass)
        @cube_class = klass
      end

      def dimensions(dims)
        @dimensions = dims
      end

      def measures(*msrs)
        @measures = msrs
      end

      def options
        {
          cube_class: @cube_class,
          dimensions: @dimensions,
          measures: @measures
        }
      end
    end
  end
end