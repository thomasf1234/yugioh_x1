ENV["ENV"] ||= 'test'
require 'rubygems'
require 'pry'
require 'timecop'
require 'time'
require File.expand_path("../../lib/yugioh_x1", __FILE__)
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |file| require file }

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
  end

  config.after(:each) do
    Timecop.return
  end
end