# frozen_string_literal: true

require './app/lib/slack_client'
require './app/lib/connect_database'
require './app/models/user'
require './app/models/emoji'

Dir.glob('./app/onaka_bot/*.rb').each(&method(:require))

# Slack からの入力のパースと bot の振る舞い
module OnakaBot
  extend OnakaBot::Base

  BOT_MODULES = [
    Uranai,
    Status,
    Challenge,
    Help,
  ].freeze

  def self.start!
    SLACK_CLIENT.on :message do |data|
      next if data.text.nil?

      text = Slack::Messages::Formatting.unescape(data.text)

      Onaka.update_frequency(text)

      if text.start_with?('onaka ')
        user = User.find_or_create_by!(slack_id: data.user)
        current_time = Time.at(data.ts.to_f)
        _, cmd, *argv = text.split

        execute(cmd, argv, user, current_time, data)
      end
    end

    SLACK_CLIENT.start!
  end

  def self.execute(cmd, argv, user, current_time, data)
    BOT_MODULES.any? { |m| m.exec(cmd, argv, user, current_time, data) } || error(cmd, data)
  end

  def self.error(cmd, data)
    post(":error: コマンド *#{cmd}* は見つかりません", data)
  end
end
