# frozen_string_literal: true

require './app/lib/i18n_settings'

module OnakaBot
  module Challenge
    def self.help(locale)
      I18n.t('modules.challenge.help.', locale: locale)
    end

    def self.exec(cmd, argv, user, current_time, data)
      return false unless cmd == 'challenge'

      target, bet = argv.take(2).map(&:to_i)
      challenge(user, current_time, data, { target: target, bet: bet }.compact)

      true
    end

    def self.challenge(user, current_time, data, target: nil, bet: nil)
      result = ActiveRecord::Base.transaction(isolation: :serializable) {
        current_stamina = user.stamina(current_time)

        bet ||= current_stamina
        target ||= bet * 2

        prob = bet.fdiv(target) # チャレンジ成功率

        if bet.positive? && bet < target && bet <= current_stamina
          # 賭けスタミナ < 目標スタミナ && 賭けスタミナ <= 現在のスタミナ
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
        else
          {
            status: :out_of_range_bet,
            bet: bet,
            target: target,
            current_stamina: current_stamina,
          }
        end
      }

      case result[:status]
      when :out_of_range_bet
        post(
          I18n.t(
            'modules.challenge.out_of_range_bet.',
            bet: result[:bet],
            current_stamina: result[:current_stamina],
            target: result[:target],
            locale: user.locale,
          ),
          data,
        )
      when :challenge_succeed, :challenge_failed
        I18n.t(
          'modules.challenge.inciting_words.',
          current_stamina: result[:current_stamina],
          prob_percentage: '%d' % (result[:prob] * 100),
          stamina_succeed: result[:current_stamina] - result[:bet] + result[:target],
          stamina_failed: result[:current_stamina] - result[:bet],
          locale: user.locale,
        ).each do |message|
          post(message, data)
          sleep(2)
        end
        sleep(6)
        case result[:status]
        when :challenge_succeed
          post(I18n.t('modules.challenge.succeed.', result: result[:result], locale: user.locale), data)
        when :challenge_failed
          post(I18n.t('modules.challenge.failed.', result: result[:result], locale: user.locale), data)
        end
      end
    end
  end
end
