class RPG::UsableItem < RPG::BaseItem
  def random_change
    @randaom_change ||= random_change_set
  end
  def random_change_set
    self.note =~ /\<ランダム最適化\>/ ? true : false
  end
  alias plus_number_of_targets number_of_targets
  def number_of_targets
    plus_number_of_targets + random_plus
  end
  def random_plus
    @random_plus ||= random_plus_set
  end
  def random_plus_set
    self.note =~ /\<ランダム追加攻撃\:(\d+)\>/ ? $1.to_i : 0
  end
  alias random_need_selection? need_selection?
  def need_selection?
    random_need_selection? || random_change
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
  alias random_extra_targets_for_opponents targets_for_opponents
  def targets_for_opponents
    if item.for_random? && item.random_change
      opponents_unit.random_target_extra(item.number_of_targets, @target_index)
    else
      random_extra_targets_for_opponents
    end
=begin
    if item.for_random?
      #Array.new(item.number_of_targets) { opponents_unit.random_target }
      #↓に変更
      opponents_unit.random_target_extra(item.number_of_targets)
    elsif item.for_one?
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      if @target_index < 0
        [opponents_unit.random_target] * num
      else
        [opponents_unit.smooth_target(@target_index)] * num
      end
    else
      opponents_unit.alive_members
    end
=end
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
  # ○ 同じ敵を選択しない複数ターゲットのランダムな決定　※狙われ率気持ち反映
  #　　※上記から変更し、ランダムではなく対象を右隣に変更し範囲魔法とする
  #--------------------------------------------------------------------------
  def random_target_extra(size, index)
    return alive_members if alive_members.size <= size
    if index == -1
      select = [random_target]
      target = alive_members
      index = target.index(select[0])
      while select.size < size
        index = index + 1 >= target.size ? 0 : index + 1
        select << target[index]
      end
      return select
=begin
      target = alive_members
      while target.size > size
        a = target[rand(target.size)]
        b = target[rand(target.size)]
        target.delete(a.tgr > b.tgr ? b : a)
      end
      return target
=end
    else
      select = [smooth_target(index)]
      if select[0].enemy?
        target = alive_members.sort {|a,b| a.screen_x <=> b.screen_x}
        index = target.index(select[0])
      else
        target = alive_members
      end
      while select.size < size
        index = index + 1 >= target.size ? 0 : index + 1
        select << target[index]
      end
      return select
=begin
      select = [smooth_target(index)]
      target = alive_members - select
      while (select.size + target.size) > size
        a = target[rand(target.size)]
        b = target[rand(target.size)]
        target.delete(a.tgr > b.tgr ? b : a)
        #target.delete_at(rand(target.size))
      end
      return select + target
=end
    end
  end
end