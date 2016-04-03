ENV["ENV"] ||= 'test'
require 'rubygems'
require 'rake'
require 'pry'
require 'timecop'
require 'time'
require 'factory_girl'
require 'webmock/rspec'
require File.expand_path("../../yugioh_x1", __FILE__)
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |file| require file }
Dir.glob('lib/tasks/*.rake').each { |file| import(file) }

factories_path = File.expand_path("../../spec/factories",__FILE__)
FactoryGirl.definition_file_paths << factories_path
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.color= true
  config.order= 'rand'
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.raise_errors_for_deprecations!

  config.before(:each) do
    FileUtils.rm_rf('tmp')
    FileUtils.mkdir('tmp')

    reset_tables_and_sequences
  end

  config.after(:each) do
    Timecop.return
  end
end

def reset_tables_and_sequences
  connection = ActiveRecord::Base.connection

  connection.execute("SELECT name FROM sqlite_master WHERE type = 'table' and name != 'sqlite_sequence'").each do |result|
    table_name = result['name']
    connection.execute("DELETE FROM '#{table_name}'")
    connection.execute("DELETE from sqlite_sequence where name = '#{table_name}'")
  end
end


def within_environment(environment)
  original_env = ENV['ENV']

  begin
    ENV['ENV'] = environment
    load('db/initialize.rb')
    yield
  ensure
    ENV['ENV'] = original_env
    load('db/initialize.rb')
  end
end

def execute_rake(task_name, args={})
  Rake::Task.define_task(:environment)
  Rake.application.load_imports
  Rake.application[task_name].execute(Rake::TaskArguments.new(args.keys, args.values))
end

def expect_all_other_tables_to_be_empty(non_empty_models)
  expect((ActiveRecord::Base.subclasses - non_empty_models).map(&:all).flatten).to eq([])
end
