module OlapReport
  class Cube::Measure::Statement
    attr_reader :sql

    def initialize(sql)
      @sql = sql
    end

    def to_sql
      sql
    end

    [:+, :-, :*, :/].each do |method_name|
      define_method method_name do |obj|
        self.class.new [self, obj].map(&:sql).join(" #{method_name} ")
      end
    end
  end
end