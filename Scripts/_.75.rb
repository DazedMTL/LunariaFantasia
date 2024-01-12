module FAKEREAL
  LER = 0.0025 # 運による有効度の影響数値
end

class RPG::UsableItem < RPG::BaseItem
  def debuff_rate
    @debuff_rate ||= set_debuff_rate
  end
  def set_debuff_rate
    return $1.to_i * 0.01 if self.note =~ /\<弱体成功率\:(\d+)\>/
    return 1.0
  end
end

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　スプライトや行動に関するメソッドを追加したバトラーのクラスです。このクラス
# は Game_Actor クラスと Game_Enemy クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 使用効果［ステート付加］：通常
  #--------------------------------------------------------------------------
  def item_effect_add_state_normal(user, item, effect)
    chance = effect.value1
    chance *= state_rate(effect.data_id) if opposite?(user)
    chance *= luk_effect_rate(user, item)      if opposite?(user)
    #p chance
    if rand < chance
      add_state(effect.data_id)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 使用効果［能力弱体］
  #--------------------------------------------------------------------------
  def item_effect_add_debuff(user, item, effect)
    chance = debuff_rate(effect.data_id) * luk_effect_rate(user, item) * item.debuff_rate
    #p chance
    if rand < chance
      add_debuff(effect.data_id, effect.value1)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 運による有効度変化率の取得　※再定義
  #　　運を抵抗力に変更
  #--------------------------------------------------------------------------
  def luk_effect_rate(user, item = nil)
    #[1.0 - (luk * 0.01 - user.luk * 0.01), 0.0].max
    #[1.0 - ((luk - user.luk * 0.5) * 0.01), 0.0].max
    #luk > user.luk ? 1.0 - ((luk - user.luk) * 0.01) : 1.0
    if item == nil
      [1.0 - (luk * FAKEREAL::LER - user.luk * FAKEREAL::LER), 0.0].max
    elsif item.magical?
      [1.0 - ((luk + mdf / 2) * FAKEREAL::LER - (user.luk + user.mat / 2) * FAKEREAL::LER), 0.0].max
    else
      [1.0 - (luk * FAKEREAL::LER - user.luk * FAKEREAL::LER), 0.0].max
    end
=begin
    a = luk / 2
    b = user.luk / 2
    [1.0 - ((a + rand(a) + 1) - (b + rand(b) + 1)) * 0.01, 1.0].min
=end
  end
end