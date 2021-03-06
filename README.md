# OlapReport

[![Code Climate](https://codeclimate.com/github/hck/olap_report.png)](https://codeclimate.com/github/hck/olap_report)

Olap-like queries & aggregations for activerecord models using defined hierarchies & measures

## Installation

Add this line to your application's Gemfile:

    gem 'olap_report'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install olap_report

## Usage

Define dimensions, measures & aggregations (if needed) in your ActiveRecord model.

    class Fact < ActiveRecord::Base
      # include OlapReport::Cube module to your ActiveRecord model
      include OlapReport::Cube

      belongs_to :user

      # define dimensions for your model
      # define_dimension <dimension name> do |d|
      define_dimension :user do
        level :user_id
        level :group_id, joins: :user
        level :category, joins: {user: :group}
      end

      define_dimension :date do
        # define layers by date periods
        # dates <column name>, by: <Array of periods (:minute, :hour, :day, :week, :month, :year)>
        dates :created_at, by: [:day, :week, :month, :quoter, :year]
      end

      # define_measure <measure name>, <function name, :sum by default>, hash of options
      define_measure :score_avg, :avg, column: :score
      define_measure :score_sum, :sum, column: :score
      define_measure :score_count, :count, column: :score

      # define table aggregations if needed
      # define_aggregation <dimension name> => <level name>
      define_aggregation user: :category
      define_aggregation user: :group_id, date: :month
    end

Use #projection method of your model class to calculate summaries by levels

    Fact.slice(dimensions: {<dimension name> => <level name>, ...}, measures: [<measure name>, <measure_name>, ...])

Use # aggregate! method of your model class to create aggregation tables for defined aggregations

    Fact.aggregate!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
