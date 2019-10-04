# frozen_string_literal: true

source "https://rubygems.org"

gem "activerecord", "~> 5.2"
gem "pg", "~> 1.1"
gem "standalone_migrations", "~> 5.2"
gem "i18n", "~> 1.6"

gem "slack-ruby-client", "~> 0.14.4"
gem "async-websocket", "~> 0.8.0"

group :development do
  gem "pry", "~> 0.12.2"
  gem "rubocop", "~> 0.75.0"
end

group :development, :test do
  gem "rspec", "~> 3.8"
end

group :test do
  gem "factory_bot", "~> 5.0"
  gem "database_cleaner", "~> 1.7"
end
