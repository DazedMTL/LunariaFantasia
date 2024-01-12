#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。主に能力値計算のメソッドを含んでいます。こ
# のクラスは Game_Battler クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ○ 装備スキルによるステート有効度の取得
  #--------------------------------------------------------------------------
  def skill_state_rate(state_id)
    return 1.0
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルによる弱体有効度の取得
  #--------------------------------------------------------------------------
  def skill_debuff_rate(param_id)
    return 1.0
  end
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● ステート有効度の取得　※オーバーライド
  #--------------------------------------------------------------------------
  def state_rate(state_id)
    super * [skill_state_rate(state_id), 0.0].max
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルによるステート有効度の取得
  #--------------------------------------------------------------------------
  def skill_state_rate(state_id)
    return (equip_class + weapon_skill).compact.inject(1.0) {|r, s_class| r -= s_class.state_rate(state_id) * skill_lv(s_class.skill_ni[1])}
  end
  #--------------------------------------------------------------------------
  # ● 弱体有効度の取得　※オーバーライド
  #--------------------------------------------------------------------------
  def debuff_rate(param_id)
    super * [skill_debuff_rate(param_id), 0.0].max
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルによる弱体有効度の取得
  #--------------------------------------------------------------------------
  def skill_debuff_rate(param_id)
    return (equip_class + weapon_skill).compact.inject(1.0) {|r, s_class| r -= s_class.debuff_rate(param_id) * skill_lv(s_class.skill_ni[1])}
  end
end

class RPG::Class < RPG::BaseItem
  def state_rate(state_id)
    rate = 0.0
    state = state_change(state_id)
    if self.note =~ /<#{state}防御:(\d+)>/
      rate = $1.to_i * 0.01
    end
    return rate
  end
  
  def state_change(state_id)
    case state_id
    when 1
      return "戦闘不能"
    when 2
      return "毒"
    when 3
      return "暗闇"
    when 4
      return "沈黙"
    when 5
      return "混乱"
    when 6
      return "睡眠"
    when 7
      return "麻痺"
    when 8
      return "スタン"
    else
      return "閉門"
    end
  end
  
  def debuff_rate(param_id)
    rate = 0.0
    param = param_change(param_id)
    if self.note =~ /<#{param}弱体防御:(\d+)>/
      rate = $1.to_i * 0.01
    end
    return rate
  end
  
  def param_change(param_id)
    case param_id
    when 0
      return "ＨＰ"
    when 1
      return "ＭＰ"
    when 2
      return "攻撃力"
    when 3
      return "防御力"
    when 4
      return "魔力"
    when 5
      return "法力"
    when 6
      return "敏捷性"
    else
      return "心力"
    end
  end
end
