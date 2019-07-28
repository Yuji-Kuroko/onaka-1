require './app/slack_client'
require './app/connect_database'

class Emoji < ActiveRecord::Base
  UNAVAILABLE_EMOJIS = %w[
    onaka
  ].freeze

  def display_name
    custom_display_name || ":onaka: :#{name}:"
  end

  def self.fetch_and_update
    emoji_list = SLACK_CLIENT.web_client.emoji_list

    return false unless emoji_list['ok']

    emoji_list['emoji'].each do |name, url|
      next if url.start_with?('alias:')

      Emoji.find_or_create_by!(name: name) do |emoji|
        emoji.url = url
        emoji.available = !UNAVAILABLE_EMOJIS.include?(name)
      end
    end

    # TODO: アップデートされなかった絵文字は Slack から削除されているので削除
  end
end
