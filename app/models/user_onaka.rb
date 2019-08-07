require 'bundler'
Bundler.require

require './app/lib/connect_database'
require './app/models/onaka'
require './app/models/user'

class UserOnaka < ActiveRecord::Base
  belongs_to :user
  belongs_to :onaka
end
