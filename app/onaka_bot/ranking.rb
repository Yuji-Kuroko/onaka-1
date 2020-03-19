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
          "#{rank_format(rank)}. #{u.name.nil? ? "_#{u.slack_id}_" : "*#{u.name}*"}   #{score_format(u.score)}pts"
        }.join("\n"),
        data,
      )

      true
    end

    private

    def self.rank_format(num)
      # 1st, 2nd, 3rd, 4th, ...
      if num == 1; "1st"
      elsif num == 2; "2nd"
      elsif num == 3; "3rd"
      else sprintf('%2dth', num)
      end
    end

    def self.score_format(score)
      # refs http://ruby.takayukikoyama.com/variable-constant-object/numeric-3-number-comma/
      score.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    end
  end
end
