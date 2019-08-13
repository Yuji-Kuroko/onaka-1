# frozen_string_literal: true

require './app/lib/connect_database'
require './app/models/onaka'
require './app/models/user_onaka'

# Slack ユーザに対応するクラス
class User < ActiveRecord::Base
  has_many :user_onakas
  has_many :onakas, through: :user_onakas

  def stamina(current_time)
    # 12 分で 1 スタミナが貯まる
    basic_income = (current_time.to_i - stamina_updated_at.to_i).fdiv(12 * 60).floor

    # capacity を超えない分が現在の stamina (ただし元本割れしないことは保証)
    [[basic_income + last_stamina, stamina_capacity].min, last_stamina].max
  end

  def rank
    User.where.not(score: 0..score).count + 1
  end

  def increase_stamina(current_time, soft_inc = 0, hard_inc = 0)
    update!(
      last_stamina: [
        [
          stamina(current_time) + soft_inc,
          stamina_capacity
        ].min,
        0
      ].max + hard_inc,
      stamina_updated_at: current_time
    )
  end
end
