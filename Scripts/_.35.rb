#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。主に能力値計算のメソッドを含んでいます。こ
# のクラスは Game_Battler クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● スキルの使用可能条件チェック
  #--------------------------------------------------------------------------
  alias state_skill_conditions_met? skill_conditions_met?
  def skill_conditions_met?(skill)
    state_skill_conditions_met?(skill) && state_skill?(skill)
  end
  #--------------------------------------------------------------------------
  # ○ 前提ステートのチェック
  #--------------------------------------------------------------------------
  def state_skill?(skill)
    skill.conditions_state ? @states.include?(skill.conditions_state) : true
  end
end

class RPG::Skill < RPG::UsableItem
  def conditions_state
    return $1.to_i if self.note =~ /\<前提ステート:(\d+)\>/
    return nil
  end
  def activate_priority
    return $1.to_i if self.note =~ /\<行動順補正:(\-?\+?\d+)\>/
    return 0
  end
end

#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　敵キャラを扱うクラスです。このクラスは Game_Troop クラス（$game_troop）の
# 内部で使用されます。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 戦闘行動の作成
  #--------------------------------------------------------------------------
  alias priority_make_actions make_actions
  def make_actions
    priority_make_actions
    #@actions.sort! {|a, b| b.item.activate_priority <=> a.item.activate_priority }
    #p name
    # 配列内のアクションがnilクラスの場合通常攻撃をセットする
    @actions.each do |a|
      #p a.item
      if !a.item
        a.set_attack
      end
    end
    @actions.sort! {|a, b| b.item.activate_priority <=> a.item.activate_priority }
  end
end


