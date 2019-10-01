# frozen_string_literal: true

require './app/lib/i18n_settings'

module OnakaBot
  module Boost
    def self.help(locale)
      I18n.t('modules.boost.help.', locale: locale)
    end

    def self.exec(cmd, argv, user, current_time, data)
      return false unless cmd == 'boost'

      boost(user, current_time, data)

      true
    end

    def self.boost(user, current_time, data)
      unless user.can_boost_stamina?
        post(
          I18n.t('modules.boost.failed.'),
          data
        )
        return
      end

      ActiveRecord::Base.transaction(isolation: :serializable) do
        plus_stamina = user.boost_stamina!(current_time)
        post(
          I18n.t(
            'modules.boost.success.',
            increase_stamina: plus_stamina,
            current_stamina: user.stamina(current_time)
          ),
          data
        )
      end
    end
  end
end
