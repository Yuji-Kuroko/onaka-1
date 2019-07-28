class User < ActiveRecord::Base
  has_many :emojis, through: :user_emojis
  has_many :user_emojis
end
