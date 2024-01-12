#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 身代わりの適用
  #--------------------------------------------------------------------------
  alias full_s_apply_substitute apply_substitute
  def apply_substitute(target, item)
    fsb = target.friends_unit.full_substitute_battler
    if fsb && check_full_substitute(target, item)
      if fsb && target != fsb
        @log_window.display_substitute(fsb, target)
        return fsb
      end
      target
    else
      full_s_apply_substitute(target, item)
    end
    #if check_substitute(target, item)
      #substitute = target.friends_unit.substitute_battler
      #if substitute && target != substitute
        #@log_window.display_substitute(substitute, target)
        #return substitute
      #end
    #end
    #target
  end
  #--------------------------------------------------------------------------
  # ○ 全身代わり条件チェック
  #--------------------------------------------------------------------------
  def check_full_substitute(target, item)
    #target.hp < target.mhp / 4 && (!item || !item.certain?)
    (!item || !item.certain?)
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
  # ○ 全身代わりバトラーの取得
  #--------------------------------------------------------------------------
  def full_substitute_battler
    members.find {|member| member.full_substitute? }
  end
end

#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。主に能力値計算のメソッドを含んでいます。こ
# のクラスは Game_Battler クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ○ 全身代わりの判定
  #--------------------------------------------------------------------------
  def full_substitute?
    special_flag(FLAG_ID_SUBSTITUTE) && movable? && all_note_check("<身代わりフル>")
  end
end