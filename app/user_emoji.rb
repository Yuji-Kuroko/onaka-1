class UserEmoji < ActiveRecord::Base
  belongs_to :user
  belongs_to :emoji
end
