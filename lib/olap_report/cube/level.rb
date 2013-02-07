module OlapReport
  class Cube::Level
    attr_reader :name, :options, :joins

    def initialize(name, options = {})
      @name, @options = name, options.reject{|k,v| ![:joins, :group_by].include?(k)}
      @joins, @group_by = options.values_at(:joins, :group_by)
    end

    def group_by
      @group_by || name
    end
  end
end