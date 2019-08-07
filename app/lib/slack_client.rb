require 'bundler'
Bundler.require

SLACK_CLIENT = Slack::RealTime::Client.new(
  token: ENV.fetch('HUBOT_SLACK_TOKEN')
)
