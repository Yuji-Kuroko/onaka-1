# frozen_string_literal: true

require './app/lib/i18n_settings'

module OnakaBot
  module Ranking
    def self.help(locale)
      I18n.t('modules.ranking.help.', locale: locale)
    end

    def self.exec(cmd, _argv, _user, _current_time, data)
      return false unless cmd == 'ranking'

      post(
        User.order_by_score.take(10).map.with_index(1) { |u, rank|
          "#{rank.ordinalize}. #{u.name.nil? ? "_#{u.slack_id}_" : "*#{u.name}*"}   #{u.score.to_s(:delimited)}pts"
        }.join("\n"),
        data,
      )

      true
    end
  end
end
