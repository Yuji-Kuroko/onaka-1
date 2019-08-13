# frozen_string_literal: true

require './app/lib/slack_client'
require './app/lib/connect_database'

require_relative './onaka'

# Slack の emoji やエイリアスと一対一対応するクラス
class Emoji < ActiveRecord::Base
  belongs_to :onaka

  def self.update_emoji_list
    emoji_list = SLACK_CLIENT.web_client.emoji_list

    return false unless emoji_list['ok']

    # OPTIMIZE: timestamp 使って古いの消そう？
    ActiveRecord::Base.transaction do
      emoji_list['emoji'].each do |emoji_name, url|
        onaka_name = url.start_with?('alias:') ? url.split(':')[1] : emoji_name

        onaka = Onaka.find_or_initialize_by(name: onaka_name)
        onaka.update!(url: url) if url.start_with?('http')

        emoji = Emoji.find_or_initialize_by(name: emoji_name)
        emoji.update!(onaka_id: onaka.id)
      end
    end
  end
end
