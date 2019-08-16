# frozen_string_literal: true

require './app/onaka_bot/base'
require './app/lib/i18n_settings'

module OnakaBot
  module Config
    extend Base

    def self.help
      I18n.t(
        'modules.config.help.',
        available_locales: I18n.available_locales.join(', '),
      )
    end

    def self.exec(cmd, argv, user, _current_time, data)
      return false unless cmd == 'config'

      subcmd, val = argv.take(2)

      case subcmd
      when 'locale'
        locale(val, user, data)
      else
        post(
          I18n.t('modules.config.subcmd_not_found.', subcommand: subcmd),
          data,
        )
      end

      true
    end

    def self.locale(val, user, data)
      user.update!(locale: val)

      post(
        I18n.t(
          'modules.config.locale_changed.',
          set_locale: val,
          locale: user.locale,
        ),
        data,
      )
    rescue ActiveRecord::RecordInvalid
      post(
        I18n.t(
          'modules.config.unavailable_locale.',
          set_locale: val,
          locale: user.locale_before_last_save,
        ),
        data,
      )
    end
  end
end
