# frozen_string_literal: true

require './app/onaka_bot/base'
require './app/lib/i18n_settings'

module OnakaBot
  module Status
    extend Base

    def self.help
      I18n.t('modules.status.help.')
    end

    def self.exec(cmd, _argv, user, current_time, data)
      return false unless cmd == 'status'

      status(user, current_time, data)

      true
    end

    def self.status(user, current_time, data)
      score, rank, bar = ActiveRecord::Base.transaction {
        [
          user.score,
          user.rank,
          progress_bar(user.stamina(current_time), user.stamina_capacity),
        ]
      }

      post(<<~MESSAGE, data)
        :sports_medal: #{rank}th (#{score}pts)
        :blue_heart: #{bar}
      MESSAGE
    end
  end
end
