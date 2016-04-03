ENV['ENV'] ||= 'development'
# require 'gosu'
# require 'gl'
# require 'glu'
# require 'glut'

FileUtils.mkdir('tmp') unless File.directory?('tmp')
require 'active_record'
require_relative 'config/config_loader'
require_relative 'db/initialize'
require_relative 'db/sync_card_data'
['app', 'lib'].each do |dir|
  Dir["#{dir}/**/*.rb"].each { |file| require_relative file }
end

