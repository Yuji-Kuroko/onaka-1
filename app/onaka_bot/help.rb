# frozen_string_literal: true

require './app/onaka_bot/base'
require './app/lib/i18n_settings'

module OnakaBot
  module Help
    extend Base

    def self.help
      I18n.t('modules.help.help.')
    end

    def self.exec(cmd, _argv, _user, _current_time, data)
      return false unless cmd == 'help'

      post(OnakaBot::BOT_MODULES.map(&:help).join("\n"), data)

      true
    end
  end
end
