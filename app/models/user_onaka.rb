# frozen_string_literal: true

require './app/lib/connect_database'
require './app/models/onaka'
require './app/models/user'

# 中間テーブル
class UserOnaka < ActiveRecord::Base
  belongs_to :user
  belongs_to :onaka
end
