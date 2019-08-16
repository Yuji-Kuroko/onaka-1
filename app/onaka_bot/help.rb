# frozen_string_literal: true

require './app/onaka_bot/base'
require './app/lib/i18n_settings'

module OnakaBot
  module Help
    extend Base

    def self.help(locale)
      I18n.t('modules.help.help.', locale: locale)
    end

    def self.exec(cmd, _argv, user, _current_time, data)
      return false unless cmd == 'help'

      post(OnakaBot::BOT_MODULES.map { |m| m.help(user.locale) }.join("\n"), data)

      true
    end
  end
end
