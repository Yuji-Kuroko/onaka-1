# frozen_string_literal: true

require './app/lib/slack_client'
require './app/lib/connect_database'
require './app/models/user'
require './app/models/emoji'

module OnakaBot
  # Slack からの入力のパースと bot の振る舞い
  class SlackBot
    def initialize
      SLACK_CLIENT.on :message do |data|
        next if data.text.nil?

        text = Slack::Messages::Formatting.unescape(data.text)

        Onaka.update_frequency(text)

        if text.start_with?('onaka ')
          user = User.find_or_create_by!(slack_id: data.user)
          current_time = Time.at(data.ts.to_f)
          _, cmd, *argv = text.split

          execute(cmd, argv, user, current_time, data)
        end
      end
    end

    def start!
      SLACK_CLIENT.start!
    end

    private

    def post(text, data, thread: true)
      SLACK_CLIENT.message(
        {
          channel: data.channel,
          text: text,
          as_user: true,
        }.tap { |hash|
          break hash.merge(thread_ts: data.thread_ts || data.ts) if thread
        }
      )
    end

    def progress_bar(val, max)
      chars = 60
      filled = ([val, max].min * chars / max).round
      empty = chars - filled
      "[#{'|' * filled}#{'.' * empty}] #{val}/#{max}"
    end

    def execute(cmd, argv, user, current_time, data)
      case cmd
      when /\?+/
        uranai(cmd.size, user, current_time, data)
      when 'status'
        status(user, current_time, data)
      when 'challenge'
        target, bet = argv.take(2).map(&:to_i)
        challenge(user, current_time, data, { target: target, bet: bet }.compact)
      when 'help'
        help(data)
      else
        error(cmd, data)
      end
    end

    URANAI_COST = 15

    def uranai(count, user, current_time, data)
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

    def status(user, current_time, data)
      score, rank, bar = ActiveRecord::Base.transaction {
        [
          user.score,
          user.rank,
          progress_bar(user.stamina(current_time), user.stamina_capacity),
        ]
      }

      post(<<~MESSAGE, data)
        :sports_medal: #{rank}th (#{score}pts)
        :blue_heart: #{bar}
      MESSAGE
    end

    def challenge(user, current_time, data, target: nil, bet: nil)
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

    def help(data)
      post(<<~MESSAGE, data)
        *onaka help*
            おなかの使い方を表示します。

        *onaka ?*
            あなたのおなかの現在または未来の状態をうらないます。
            一回おなかうらないをおこなうと、スタミナを #{URANAI_COST} 消費します。
            また、 `onaka ??' のように ? を連ねることで、連続でうらなうことができます。

        *onaka status*
            現在のあなたのスタミナやスコア、ランクなどを表示します。

        *onaka challenge [target [bet]]*
            現在のあなたのスタミナのうち、賭けスタミナ *bet* を目標スタミナ *target* にするチャレンジをおこないます。
            目標スタミナが賭けスタミナよりもかけ離れているほど成功率は低くなります。
            失敗した場合、賭けスタミナはゼロになります。
            なお、本機能は非推奨機能です。
      MESSAGE
    end

    def error(cmd, data)
      post(":error: コマンド *#{cmd}* は見つかりません", data)
    end
  end
end
