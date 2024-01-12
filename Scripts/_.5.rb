class RPG::UsableItem < RPG::BaseItem
  def for_fix?
    !fix_target.empty?
  end
  def fix_target
    @fix_target ||= fix_target_set
  end
  def fix_target_set
    fix = []
    fix = [$1, $2.to_i] if self.note =~ /\<ターゲット固定:(\w+),(\d+)\>/
    return fix
  end
end

#==============================================================================
# ■ Game_Action
#------------------------------------------------------------------------------
# 　戦闘行動を扱うクラスです。このクラスは Game_Battler クラスの内部で使用され
# ます。
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # ● 敵に対するターゲット　※エイリアス
  #--------------------------------------------------------------------------
  alias fix_targets_for_opponents targets_for_opponents
  def targets_for_opponents
    if item.for_fix?
      opponents_unit.fix_target(item.fix_target[0], item.fix_target[1], item.for_one?)
    else
      fix_targets_for_opponents
    end
  end
end

#==============================================================================
# ■ Game_Unit
#------------------------------------------------------------------------------
# 　ユニットを扱うクラスです。このクラスは Game_Party クラスと Game_Troop クラ
# スのスーパークラスとして使用されます。
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def fix_target(kind, id, one)
    case kind
    when "a"
      alive_members.each do |member|
        return [member] if member.actor_target(id)
      end
      []
    when "st"
      if one
        tgr_rand = rand * tgr_st_sum(id)
        state_members(id).each do |member|
          tgr_rand -= member.tgr
          return [member] if tgr_rand < 0
        end
        [state_members(id)[0]]
      else
        state_members(id)
      end
    else
      alive_members
    end
  end
  #--------------------------------------------------------------------------
  # 〇 狙われ率の合計を計算
  #--------------------------------------------------------------------------
  def tgr_st_sum(id)
    state_members(id).inject(0) {|r, member| r + member.tgr }
  end
  #--------------------------------------------------------------------------
  # 〇 特定ステートにかかっているメンバーの配列取得
  #--------------------------------------------------------------------------
  def state_members(id)
    members.select {|member| member.state?(id) }
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
  # 〇 
  #--------------------------------------------------------------------------
  def actor_target(id)
    return false if enemy?
    @actor_id == id
  end
end