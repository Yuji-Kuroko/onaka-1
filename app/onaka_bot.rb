# frozen_string_literal: true

require './app/lib/slack_client'
require './app/lib/connect_database'
require './app/lib/utilities'
require './app/lib/helper'
require './app/models/user'
require './app/models/emoji'
require './app/lib/i18n_settings'

Dir.glob('./app/onaka_bot/*.rb').each(&method(:require))

# Slack からの入力のパースと bot の振る舞い
module OnakaBot
  BOT_MODULES = [
    Config,
    Uranai,
    Status,
    Challenge,
    Ranking,
    Help,
  ].freeze

  def self.start!
    SLACK_CLIENT.on :message do |data|
      Thread.new(data) do
        next if data.text.nil?

        Slack::Messages::Formatting.unescape(data.text).each_line do |text|
          Onaka.update_frequency(text)

          next unless text.start_with?('onaka ')

          user = User.find_or_create_by!(slack_id: data.user)
          current_time = Time.at(data.ts.to_f)
          _, cmd, *argv = text.split

          execute(cmd, argv, user, current_time, data)
        end
      end
    end

    SLACK_CLIENT.on :emoji_changed do |data|
      # 絵文字追加 / 削除
      case data.subtype
      when 'add'
        Emoji.add_emoji(data.name, data.value)
      when 'remove'
        # data.names.each(&Emoji.method(:remove_emoji))
      end
    end

    SLACK_CLIENT.start!
  end

  def self.execute(cmd, argv, user, current_time, data)
    BOT_MODULES.any? { |m| m.exec(cmd, argv, user, current_time, data) } || error(cmd, user, data)
  end

  def self.error(cmd, user, data)
    post(I18n.t('basic.error.', command: cmd, locale: user.locale), data)
  end
end
