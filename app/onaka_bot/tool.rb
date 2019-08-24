# frozen_string_literal: true

require './app/lib/i18n_settings'

module OnakaBot
  module Tool
    def self.help(locale)
      I18n.t('modules.tool.help.', locale: locale)
    end

    def self.exec(cmd, argv, user, _current_time, data)
      return false unless cmd == 'tool'

      subcmd, *sargv = argv

      case subcmd
      when 'roll'
        dice, = sargv
        roll(dice, user, data)
      else
        if subcmd.nil?
          post(
            I18n.t('modules.tool.subcmd_not_given.', locale: user.locale),
            data,
          )
        else
          post(
            I18n.t('modules.tool.subcmd_not_found.', subcommand: subcmd, locale: user.locale),
            data,
          )
        end
      end

      true
    end

    def self.roll(dice, user, data)
      count, kind = dice.match(/(\d+)[dD](\d+)/)&.values_at(1, 2)&.map(&:to_i)
      if [count, kind].none?(&:nil?) && count.positive? && kind >= 2
        value = count.times.sum { rand(1..kind) }
        post(
          [
            value,
            if [count, kind] == [1, 100]
              case value
              when 1..5
                "*#{I18n.t('modules.tool.critical.', locale: user.locale)}*"
              when 96..100
                "*#{I18n.t('modules.tool.fumble.', locale: user.locale)}*"
              end
            end,
          ].join('   '),
          data,
        )
      else
        post(I18n.t('modules.tool.invalid_argument.', locale: user.locale), data)
      end
    end
  end
end
