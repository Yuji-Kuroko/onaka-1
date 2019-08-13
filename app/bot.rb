# frozen_string_literal: true

require './app/lib/slack_client'
require './app/lib/connect_database'
require './app/models/user'
require './app/models/emoji'

# Slack からの入力のパースと bot の振る舞い
class Bot
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
    when 'help'
      help(data)
    end
  end

  URANAI_COST = 15

  def uranai(count, user, current_time, data)
    result = nil

    ActiveRecord::Base.transaction do
      if user.stamina(current_time) < URANAI_COST * count
        result = {
          status: :lack_of_stamina,
          current_stamina: user.stamina(current_time),
          stamina_capacity: user.stamina_capacity,
          required_stamina: URANAI_COST * count,
        }
      else
        user.increase_stamina(current_time, -URANAI_COST * count)
        drawed_onakas = Onaka.draw(count)
        user.onakas.push(drawed_onakas)
        user.update!(score: user.score + drawed_onakas.sum { |o| 2**(o.rarity_level + 4) })

        result = {
          status: :succeed,
          drawed_onakas: drawed_onakas.map { |onaka| [onaka, onaka.rarity_level] },
        }
      end
    end

    case result[:status]
    when :lack_of_stamina
      post(<<~MESSAGE, data)
        :error: スタミナが足りません
        スタミナ #{progress_bar(result[:current_stamina], result[:stamina_capacity])}
        (おなかうらないを#{count}回するにはスタミナが#{result[:required_stamina]}必要です
      MESSAGE
    when :succeed
      result[:drawed_onakas].each_with_index do |(onaka, rarity_level), index|
        sleep 2 unless index.zero?

        post("*[#{Onaka::RARITY[rarity_level]}]* #{onaka.display_name}", data)
      end
    end
  end

  def status(user, current_time, data)
    score = rank = bar = nil
    ActiveRecord::Base.transaction do
      score = user.score
      rank = user.rank
      bar = progress_bar(user.stamina(current_time), user.stamina_capacity)
    end

    post(<<~MESSAGE, data)
      :sports_medal: #{rank}th (#{score}pts)
      :blue_heart: #{bar}
    MESSAGE
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
    MESSAGE
  end
end

bot = Bot.new
bot.start!
