require 'spec_helper'

RSpec.describe User do
  describe '時間経過に伴うスタミナ増加' do
    before(:each) do
      @current_time = Time.now
      @user = create(:user, last_stamina: 30, stamina_updated_at: @current_time)
    end

    example '12 分経過する前にはスタミナは回復しないこと' do
      twelve_secs_later = @current_time + 12 * 60
      before_stamina = @user.stamina(@current_time)

      expect(@user.stamina(@current_time + 1)).to eq(before_stamina)
      expect(@user.stamina(twelve_secs_later - 1)).to eq(before_stamina)
    end

    example '12 分経過するとスタミナが回復すること' do
      twelve_secs_later = @current_time + 12 * 60
      before_stamina = @user.stamina(@current_time)

      expect(@user.stamina(twelve_secs_later)).to eq(before_stamina + 1)
    end
  end

  describe 'スタミナ増減に関する操作' do
    before(:each) do
      @current_time = Time.now
      @user = create(:user, last_stamina: 30, stamina_updated_at: @current_time)
    end

    example '上限を超えずソフトインクリメントをするとその数だけスタミナが増加すること' do
      before_stamina = @user.stamina(@current_time)
      @user.increase_stamina(@current_time, 20)
      after_stamina = @user.stamina(@current_time)

      expect(after_stamina).to eq(before_stamina + 20)
    end

    example '上限を超えてソフトインクリメントをすると 60 になること' do
      @user.increase_stamina(@current_time, 40)
      after_stamina = @user.stamina(@current_time)

      expect(after_stamina).to eq(60)
    end

    example 'スタミナの数未満のソフトデクリメントをするとその数だけスタミナが減少すること' do
      before_stamina = @user.stamina(@current_time)
      @user.decrease_stamina(@current_time, 20)
      after_stamina = @user.stamina(@current_time)

      expect(after_stamina).to eq(before_stamina - 20)
    end

    example 'スタミナの数以上のソフトデクリメントをすると 0 になること' do
      @user.decrease_stamina(@current_time, 40)
      after_stamina = @user.stamina(@current_time)

      expect(after_stamina).to eq(0)
    end

    example 'ハードインクリメントするとその数だけスタミナが増加すること' do
      before_stamina = @user.stamina(@current_time)
      @user.increase_stamina!(@current_time, 40)
      after_stamina = @user.stamina(@current_time)

      expect(after_stamina).to eq(before_stamina + 40)
    end

    example 'ハードデクリメントをするとその数だけスタミナが減少すること' do
      before_stamina = @user.stamina(@current_time)
      @user.decrease_stamina!(@current_time, 40)
      after_stamina = @user.stamina(@current_time)

      expect(after_stamina).to eq(before_stamina - 40)
    end
  end

  describe 'ランキング' do
    before(:each) do
      @user_1st = create(:user, score: 10000)
      @user_2nd = create(:user, score: 1000)
      @user_3rd = create(:user, score: 100)
      @user_4th = create(:user, score: 10)
      @user_5th = create(:user, score: 0)
    end

    example '正しい順位が返されること' do
      expect(@user_1st.rank).to eq(1)
      expect(@user_2nd.rank).to eq(2)
      expect(@user_3rd.rank).to eq(3)
      expect(@user_4th.rank).to eq(4)
      expect(@user_5th.rank).to eq(5)
    end
  end
end
