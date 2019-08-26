# frozen_string_literal: true

require 'yaml'
require 'erb'

rails_env = ENV.fetch('RAILS_ENV', 'development')
DB_CONFIG_PATH = 'db/config.yml'

db_config = YAML.safe_load(ERB.new(File.read(DB_CONFIG_PATH)).result)[rails_env]

ActiveRecord::Base.establish_connection(db_config)
