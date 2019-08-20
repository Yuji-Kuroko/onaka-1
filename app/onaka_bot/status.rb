# frozen_string_literal: true

require './app/lib/i18n_settings'

module OnakaBot
  module Status
    def self.help(locale)
      I18n.t('modules.status.help.', locale: locale)
    end

    def self.exec(cmd, _argv, user, current_time, data)
      return false unless cmd == 'status'

      status(user, current_time, data)

      true
    end

    def self.status(user, current_time, data)
      score, rank, bar = ActiveRecord::Base.transaction(isolation: :serializable) {
        [
          user.score,
          user.rank,
          Helper.progress_bar(user.stamina(current_time), user.stamina_capacity),
        ]
      }

      post(<<~MESSAGE, data)
        :sports_medal: #{rank}th (#{score}pts)
        :blue_heart: #{bar}
      MESSAGE
    end
  end
end
