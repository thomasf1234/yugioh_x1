ENV['ENV'] ||= 'development'
# require 'gosu'
# require 'gl'
# require 'glu'
# require 'glut'

require 'active_record'
require_relative 'config/config_loader'
require_relative 'db/initialize'
['app', 'lib'].each do |dir|
  Dir["#{dir}/**/*.rb"].each { |file| require_relative file }
end

