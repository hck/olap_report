require "olap_report/version"

require "olap_report/active_record/helpers"

require "olap_report/cube"

require "olap_report/cube/adapters/base"
require "olap_report/cube/adapters/mysql2"
require "olap_report/cube/adapters/postgre_sql"

require "olap_report/cube/dimension"
require "olap_report/cube/level"
require "olap_report/cube/measure"
require "olap_report/cube/measure/scope"
require "olap_report/cube/measure/statement"
require "olap_report/cube/aggregation"
require "olap_report/cube/aggregation/table"
require "olap_report/cube/projection"

require "olap_report/report"

module OlapReport
end