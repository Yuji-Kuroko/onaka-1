require 'bundler'
Bundler.require

require './app/lib/slack_client'
require './app/lib/connect_database'

class Onaka < ActiveRecord::Base
  has_many :users, through: :user_onakas
  has_many :user_onakas

  scope :order_by_frequency, -> { order(frequency: :desc) }

  def display_name
    custom_display_name || ":onaka: :#{name}:"
  end

  # Slack の emoji shortcode にマッチする正規表現
  EMOJI_PATTERN = /(?<=:)[^:;.,!?@#$%^&*(){}\[\]<>\/\\=\s]+(?=:)/.freeze

  def self.update_freqs(text)
    text.scan(EMOJI_PATTERN).group_by(&:itself).transform_values(&:size).each do |emoji, freq|
      Emoji.find_by(name: emoji)&.onaka&.then { |onaka| onaka.update!(frequency: onaka.frequency + freq) }
    end
  end

  HARMONY = Hash.new { |h, n| h[n] = (n.zero? ? 0.0 : h[n - 1] + 1.fdiv(n)) } # 調和数
  Onaka.count.times(&HARMONY.method(:[]))

  def self.draw(count = 1)
    onaka_size = Onaka.count

    Array.new(count) do
      rval = rand(0...HARMONY[onaka_size])

      index = (1..onaka_size).bsearch { |e|
        (HARMONY[e - 1]...HARMONY[e]).cover?(rval) ? 0 : rval <=> HARMONY[e - 1]
      }

      Onaka.order_by_frequency.offset(index).first
    end
  end
end
