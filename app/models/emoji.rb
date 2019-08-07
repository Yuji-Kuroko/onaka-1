require 'bundler'
Bundler.require

require './app/lib/slack_client'
require './app/lib/connect_database'

require_relative './onaka'

class Emoji < ActiveRecord::Base
  has_many :onakas

  UNAVAILABLE_EMOJIS = %w[
    onaka
  ].freeze

  def self.update_emoji_list
    emoji_list = SLACK_CLIENT.web_client.emoji_list

    return false unless emoji_list['ok']

    # OPTIMIZE: timestamp 使って古いの消そう？
    ActiveRecord::Base.transaction do
      emoji_list['emoji'].each do |emoji_name, url|
        next if UNAVAILABLE_EMOJIS.include?(emoji_name)

        onaka_name = url.start_with?('alias:') ? url.split(':')[1] : emoji_name

        onaka = Onaka.find_or_initialize_by(name: onaka_name)
        onaka.update!(url: url) if url.start_with?('http')

        emoji = Emoji.find_or_initialize_by(name: emoji_name)
        emoji.update!(onaka_id: onaka.id)
      end
    end
  end
end
