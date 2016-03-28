require 'yaml'

ENVIRONMENT_CONFIG = YAML.load_file('config/environment_config.yml')[ENV['ENV']]
