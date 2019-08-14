require './app/onaka_bot/base'

module OnakaBot
  module Uranai
    extend Base

    URANAI_COST = 15

    def self.help
      <<~MESSAGE
        *onaka ?*
            あなたのおなかの現在または未来の状態をうらないます。
            一回おなかうらないをおこなうと、スタミナを #{URANAI_COST} 消費します。
            また、 `onaka ??' のように ? を連ねることで、連続でうらなうことができます。
      MESSAGE
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
        post(<<~MESSAGE, data)
          :error: スタミナが足りません
          :blue_heart: #{progress_bar(result[:current_stamina], result[:stamina_capacity])}
          (おなかうらないを#{count}回するにはスタミナが#{result[:required_stamina]}必要です
        MESSAGE
      when :succeed
        result[:drawed_onakas].each_with_index do |(onaka, rarity_level), index|
          sleep 2 unless index.zero?

          post("#{Onaka::RARITY[rarity_level]}    #{onaka.display_name}", data)
        end
      end
    end
  end
end
