# OlapReport

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'olap_report'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install olap_report

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



retailer
product_id
  [product_type_id, product_group_id, product_id]
date
  [year, month, day]
views
  sum

measure :views, column: :views, function: :sum
measure :avg_views, column: :views, function: :avg


Foo.where...
   .find

   .foobar(dimensions, measures) # => .foobar(dimensions: {:product_id => :product_group_id, :date => :month], measures: [:views, :avg_views])
                                 #
                                 #    ------------------------------------------------
                                 #    | product_group_id | month | views | avg_views |
                                 #    ------------------------------------------------

   .dimensions                   # => AR:Relation
   .measures                     # => AR:Relation

   .where


------------------------------------------------------------------------------------------------

