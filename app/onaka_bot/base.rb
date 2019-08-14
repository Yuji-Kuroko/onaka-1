module OnakaBot
  module Base
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
  end
end
