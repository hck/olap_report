# OlapReport

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
      # dimension <dimension name> do |d|
      dimension :user do |d|
        # d.level <column name of level>
        d.level :user_id
        d.level :group_id, joins: :user
        d.level :category, joins: {user: :group}
      end

      dimension :date do |d|
        # define layers by date periods
        # d.dates <column name>, by: <Array of periods (:minute, :hour, :day, :week, :month, :year)>
        d.dates :created_at, by: [:minute, :hour, :day, :week, :month, :year]
      end

      # define measures that you want to calculate from the facts table
      # measures_for <measure name>, [<array of functions you want to be used to calculate measures>]
      measures_for :score, [:avg, :sum]

      # measure <measure name>, <function name, :sum by default>, hash of options
      measure :score_count, :count, column: :score

      # define table aggregations if needed
      # aggregation <dimension name> => <level name>
      aggregation user: :category
      aggregation user: :group_id, date: :year
    end

Use #projection method of your model class to calculate summaries by levels

    Fact.projection(dimensions: {<dimension name> => <level name>, ...}, measures: [<measure name>, <measure_name>, ...])

Use # aggregate! method of your model class to create aggregation tables for defined aggregations

    Fact.aggregate!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request