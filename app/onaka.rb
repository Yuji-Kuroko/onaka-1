require 'bundler'
Bundler.require

require './app/connect_database'
require './app/slack_client'
require './app/user'
require './app/emoji'

class Onaka
  def initialize
    SLACK_CLIENT.on :message do |data|
      execute(data) if data.text.strip =~ /^onaka/
    end
  end

  def start!
    SLACK_CLIENT.start!
  end

  private

  def execute(data)
    text = Slack::Messages::Formatting.unescape(data.text).strip
    case text
    when /^onaka (\?+)$/
    when /^onaka status$/
    when /^onaka stamina$/
    when /^onaka collection$/
    when /^onaka score$/
    when /^onaka challenge ?([0-9]*)$/
    when /^onaka help$/
    else
    end
  end
end

onaka = Onaka.new
onaka.start!
