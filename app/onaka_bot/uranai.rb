# frozen_string_literal: true

require './app/onaka_bot/base'
require './app/lib/i18n_settings'

module OnakaBot
  module Uranai
    extend Base

    URANAI_COST = 15

    def self.help
      I18n.t('modules.uranai.help.', cost: URANAI_COST)
    end

    def self.exec(cmd, _argv, user, current_time, data)
      return false unless cmd =~ /\?+/

      uranai(cmd.size, user, current_time, data)

      true
    end

    def self.uranai(count, user, current_time, data)
      result = ActiveRecord::Base.transaction {
        if user.stamina(current_time) < URANAI_COST * count
          {
            status: :lack_of_stamina,
            current_stamina: user.stamina(current_time),
            stamina_capacity: user.stamina_capacity,
            required_stamina: URANAI_COST * count,
          }
        else
          user.decrease_stamina!(current_time, URANAI_COST * count)
          drawed_onakas = Onaka.draw(count)
          user.onakas.push(drawed_onakas)
          user.update!(score: user.score + drawed_onakas.sum { |o| 2**(o.rarity_level + 4) })

          {
            status: :succeed,
            drawed_onakas: drawed_onakas.map { |onaka| [onaka, onaka.rarity_level] },
          }
        end
      }

      case result[:status]
      when :lack_of_stamina
        post(
          I18n.t(
            'modules.uranai.lack_of_stamina.',
            stamina_bar: progress_bar(result[:current_stamina], result[:stamina_capacity]),
            count: count,
            required_stamina: result[:required_stamina],
          ),
          data,
        )
      when :succeed
        result[:drawed_onakas].each_with_index do |(onaka, rarity_level), index|
          sleep 2 unless index.zero?

          post("#{Onaka::RARITY[rarity_level]}    #{onaka.display_name}", data)
        end
      end
    end
  end
end
