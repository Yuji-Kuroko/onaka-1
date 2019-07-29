ONAKA_ENV = ENV.fetch('ONAKA_ENV', 'development')
DB_CONFIG_PATH = 'db/config.yml'

db_config = YAML.load(ERB.new(File.read(DB_CONFIG_PATH)).result)[ONAKA_ENV]

ActiveRecord::Base.establish_connection(db_config)
