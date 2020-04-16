# frozen_string_literal: true

require './app/lib/i18n_settings'

module OnakaBot
  module Burst
    def self.help(locale)
      I18n.t('modules.burst.help.', locale: locale)
    end

    def self.exec(cmd, argv, user, current_time, data)
      return false unless cmd == 'burst'

      target_stamina = argv.take(1).map(&:to_i).first
      burst(user, current_time, data, target_stamina: target_stamina)

      true
    end

    def self.burst(user, current_time, data, target_stamina: nil)
      target_stamina ||= user.stamina(current_time)
      target_stamina = 0 if target_stamina.negative?
      target_stamina = user.stamina(current_time) if target_stamina > user.stamina(current_time)

      if user.stamina(current_time).zero?
        post(
          I18n.t('modules.burst.failed.'),
          data
        )
        return
      end

      # 処理が若干重複気味ではある
      ActiveRecord::Base.transaction(isolation: :serializable) do
        # 端数がある場合、確率で1回分回せる
        count = (target_stamina.fdiv(OnakaBot::Uranai::URANAI_COST) + Random.rand).to_i
        user.decrease_stamina!(current_time, target_stamina)

        drawed_onakas = Onaka.draw(count)
        got_score = drawed_onakas.sum { |o| 2**(o.rarity_level + 4) }
        user.update!(score: user.score + got_score)

        result_message = drawed_onakas.group_by(&:rarity_level).sort_by { |k, v| k }.reverse.map { |rarity_level, items|
          "#{Onaka::RARITY[rarity_level]} #{items.length}"
        }.join("\n")

        post(":boom::boom::boom:\n:boom::onaka::boom:\n:boom::boom::boom:", data)
        sleep 2
        post(result_message + "\n-----\n*#{got_score}pts*", data)
      end
    end
  end
end
