module OlapReport
  module ActiveRecord::AggregationFunctions
    FUNCTIONS = [:sum, :avg, :min, :max, :count]

    def method_missing(name, *args)

    end
  end
end