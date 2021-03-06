require 'rubygems'

require 'active_record'
require 'active_support/core_ext/logger'
require 'database_cleaner'
require 'factory_girl'

require 'olap_report'

MODELS = File.join(File.dirname(__FILE__), 'models')
Dir["#{MODELS}/**/*.rb"].each { |f| require f }

DB_ADAPTER = (ENV["DB_ADAPTER"] || :postgresql).to_sym

ActiveRecord::Base.establish_connection(
  adapter: DB_ADAPTER,
  database: "olap_report_test"
)
#ActiveRecord::Base.logger = Logger.new($stdout)
#ActiveRecord::Base.logger.level = Logger::DEBUG

FactoryGirl.definition_file_paths = [File.join(File.dirname(__FILE__), 'factories')]
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.mock_with :rspec
  config.color_enabled = true

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:suite) do
    [Fact, User, Group].each(&:prepare_table)

    active_record = DatabaseCleaner[:active_record]
    active_record.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
