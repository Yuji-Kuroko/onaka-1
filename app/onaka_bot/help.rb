require './app/onaka_bot/base'

module OnakaBot
  module Help
    extend Base

    def self.help
      <<~MESSAGE
        *onaka help*
            おなかの使い方を表示します。
      MESSAGE
    end

    def self.exec(cmd, _argv, _user, _current_time, data)
      return false unless cmd == 'help'

      post(OnakaBot::BOT_MODULES.map(&:help).join("\n"), data)

      true
    end
  end
end
