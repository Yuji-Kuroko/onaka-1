# frozen_string_literal: true

require_relative './slack_client'

module Kernel
  def post(text, data, thread: true)
    SLACK_CLIENT.message(
      {
        channel: data.channel,
        text: text,
        as_user: true,
      }.tap { |hash|
        break hash.merge(thread_ts: data.thread_ts || data.ts) if thread
      },
    )
  end
end
