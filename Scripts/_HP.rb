#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　敵キャラを扱うクラスです。このクラスは Game_Troop クラス（$game_troop）の
# 内部で使用されます。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 通常能力値の基本値取得
  #--------------------------------------------------------------------------
  alias param_plus_param_base param_base
  def param_base(param_id)
    param_plus_param_base(param_id) + enemy.param_plus[param_id]
  end
end

class RPG::Enemy < RPG::BaseItem
  def param_plus
    @param_plus ||= param_plus_set
  end
  def param_plus_set
    pp = Array.new(9, 0)
    self.note.each_line do |line|
      case line
      when /\<能力値プラス:(\d+),(\d+)\>/
        pp[$1.to_i] = $2.to_i
      end
    end
    return pp
  end
end

