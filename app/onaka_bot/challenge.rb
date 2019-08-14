require './app/onaka_bot/base'

module OnakaBot
  module Challenge
    extend Base

    def self.help
      <<~MESSAGE
        *onaka challenge [target [bet]]*
            現在のあなたのスタミナのうち、賭けスタミナ *bet* を目標スタミナ *target* にするチャレンジをおこないます。
            目標スタミナが賭けスタミナよりもかけ離れているほど成功率は低くなります。
            失敗した場合、賭けスタミナはゼロになります。
            なお、本機能は非推奨機能です。
      MESSAGE
    end

    def self.exec(cmd, argv, user, current_time, data)
      return false unless cmd == 'challenge'

      target, bet = argv.take(2).map(&:to_i)
      challenge(user, current_time, data, { target: target, bet: bet }.compact)

      true
    end

    def self.challenge(user, current_time, data, target: nil, bet: nil)
      result = ActiveRecord::Base.transaction {
        current_stamina = user.stamina(current_time)

        bet ||= current_stamina
        target ||= bet * 2

        prob = bet.fdiv(target) # チャレンジ成功率

        if bet <= 0 || target <= bet
          # 賭けスタミナが範囲外 (0 < 賭けスタミナ < 目標スタミナ が満たされていない)
          {
            status: :out_of_range_bet,
            bet: bet,
            target: target,
            current_stamina: current_stamina,
          }
        else
          user.decrease_stamina!(current_time, bet)
          status = if rand < prob
            # チャレンジ成功
            user.increase_stamina!(current_time, target)
            :challenge_succeed
          else
            # チャレンジ失敗
            :challenge_failed
          end

          {
            status: status,
            bet: bet,
            target: target,
            current_stamina: current_stamina,
            prob: prob,
            result: user.stamina(current_time),
          }
        end
      }

      case result[:status]
      when :out_of_range_bet
        post(<<~MESSAGE, data)
          :error: 賭けスタミナまたは目標スタミナの値が不正です
          賭けスタミナ (#{result[:bet]}) は、 *現在のスタミナ (#{result[:current_stamina]}) 以上* かつ *目標スタミナ (#{result[:target]}) 未満* である必要があります
        MESSAGE
      when :challenge_succeed, :challenge_failed
        [
          'チャレンジを開始します。',
          "現在、あなたのスタミナは #{result[:current_stamina]} です。",
          "今回のチャレンジでは、 #{'%d' % (result[:prob] * 100)} %の確率でスタミナが #{result[:current_stamina] - result[:bet] + result[:target]} になります。",
          "チャレンジに失敗するとスタミナが #{result[:current_stamina] - result[:bet]} になります。",
          'あなたのスタミナは・・・',
        ].each do |message|
          post(message, data)
          sleep(2)
        end
        sleep(6)
        case result[:status]
        when :challenge_succeed
          post(<<~MESSAGE, data)
            #{result[:result]} になりました。
            おめでとうございます！
          MESSAGE
        when :challenge_failed
          post(<<~MESSAGE, data)
            #{result[:result]} になりました。
            残念でした。^p^
          MESSAGE
        end
      end
    end
  end
end
