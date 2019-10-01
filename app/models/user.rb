# frozen_string_literal: true

require './app/lib/connect_database'
require './app/lib/i18n_settings'
require './app/models/onaka'
require './app/models/user_onaka'

# Slack ユーザに対応するクラス
class User < ActiveRecord::Base
  has_many :user_onakas
  has_many :onakas, through: :user_onakas

  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }

  scope :order_by_score, -> { order(score: :desc) }

  def stamina(current_time)
    # 12 分で 1 スタミナが貯まる
    basic_income = (current_time.to_i - stamina_updated_at.to_i).fdiv(12 * 60).floor

    # capacity を超えない分が現在の stamina (ただし元本割れしないことは保証)
    [[basic_income + last_stamina, stamina_capacity].min, last_stamina].max
  end

  def rank
    User.where.not(score: 0..score).count + 1
  end

  def increase_stamina(current_time, soft_inc)
    update!(
      last_stamina: [
        [
          stamina(current_time) + soft_inc,
          stamina_capacity,
        ].min,
        0,
      ].max,
      stamina_updated_at: current_time,
    )
  end

  def decrease_stamina(current_time, soft_inc)
    increase_stamina(current_time, -soft_inc)
  end

  def increase_stamina!(current_time, hard_inc)
    update!(
      last_stamina: stamina(current_time) + hard_inc,
      stamina_updated_at: current_time,
    )
  end

  def decrease_stamina!(current_time, hard_inc)
    increase_stamina!(current_time, -hard_inc)
  end

  def can_boost_stamina?
    # ブースト可能になる時刻を調整可能にするため、時刻も一応拾ってる
    boosted_stamina_at&.to_date != Date.today
  end

  def boost_stamina!(current_time)
    return unless can_boost_stamina?
    plus_stamina = boosting_stamina
    increase_stamina!(current_time, plus_stamina)
    update!(boosted_stamina_at: current_time)
    plus_stamina
  end

  def boosting_stamina
    # ランキングとスコアによりブースト値が異なる
    boosting_coefficient = [*([1] * 17), *([1.5] * 2), *([2] * 1)].sample
    ((rank * 15) + ((User.first_rank_score - score) * 15 / 2000)) * boosting_coefficient
  end

  # 1位のスコアを参照すること多そうなので
  def self.first_rank_score
    User.order_by_score.first&.score || 0
  end

  def self.update_user_name
    SLACK_CLIENT.web_client.users_list['members'].each do |user_data|
      name = user_data['profile'].then { |pr| pr['display_name'].empty? ? pr['real_name'] : pr['display_name'] }
      user = User.find_by(slack_id: user_data['id'])
      user&.update!(name: name)
    end
  end
end
