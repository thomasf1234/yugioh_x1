db_name = "db_#{ENV['ENV']}"

ActiveRecord::Base.logger = Logger.new(File.open("log/#{db_name}.log", 'w+'))

ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => db_name
)

# require 'db/'
require_relative 'card_data_fetcher'