# frozen_string_literal: true

require './app/lib/i18n_settings'

module OnakaBot
  module Config
    def self.help(locale)
      I18n.t(
        'modules.config.help.',
        available_locales: I18n.available_locales.join(', '),
        locale: locale,
      )
    end

    def self.exec(cmd, argv, user, _current_time, data)
      return false unless cmd == 'config'

      subcmd, val = argv.take(2)

      case subcmd
      when 'locale'
        if val.nil?
          check_locale(user, data)
        else
          locale(val, user, data)
        end
      else
        if subcmd.nil?
          post(
            I18n.t('modules.config.subcmd_not_given.', locale: user.locale),
            data,
          )
        else
          post(
            I18n.t('modules.config.subcmd_not_found.', subcommand: subcmd, locale: user.locale),
            data,
          )
        end
      end

      true
    end

    def self.check_locale(user, data)
      post(
        I18n.t(
          'modules.config.check_locale.',
          current_locale: user.locale,
          locale: user.locale,
        ),
        data,
      )
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
