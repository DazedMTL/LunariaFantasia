#==============================================================================
# ■ Game_Unit
#------------------------------------------------------------------------------
# 　ユニットを扱うクラスです。このクラスは Game_Party クラスと Game_Troop クラ
# スのスーパークラスとして使用されます。
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # ○ 生存しているメンバーの配列取得
  #--------------------------------------------------------------------------
  def need_heal_members(per = 100)
    alive_members.select {|member| member.hp < (member.mhp * per / 100) }
  end
  #--------------------------------------------------------------------------
  # ○ HPの減っているターゲットのランダムな決定
  #--------------------------------------------------------------------------
  def random_heal_target
    tgr_rand = rand * tgr_sum
    nhm = need_heal_members(40)
    #need_heal_members(50).each do |member|
    nhm.each do |member|
      tgr_rand -= member.tgr
      return member if tgr_rand < 0
    end
    #need_heal_members.empty? ? alive_members[0] : need_heal_members.min{|a,b| b.hp <=> a.hp } #need_heal_members[0]
    nhm.empty? ? alive_members[0] : need_heal_members.min{|a,b| a.hp <=> b.hp } #need_heal_members[0]
  end
end


#星潟さん修正スクリプトの改造
class Game_Action
  #--------------------------------------------------------------------------
  # ● 味方に対するターゲット
  #--------------------------------------------------------------------------
  def targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        if @target_index < 0
          [friends_unit.random_dead_target]
        else
          [friends_unit.smooth_dead_target(@target_index)]
        end
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.note.include?(D_V_HEAL::WORD)
        if item.for_one?
          if @target_index < 0
            [friends_unit.random_target_void_all]
          else
            [friends_unit.smooth_target_void_all(@target_index)]
          end
        else
          friends_unit.exist_members
        end
      else
        if item.for_one? && item.damage.recover? && item.damage.to_hp? #追加↓
          if @target_index < 0
            [friends_unit.random_heal_target]
          else
            [friends_unit.smooth_target(@target_index)]
          end #追加ここまで
        elsif item.for_one?
          if @target_index < 0
            [friends_unit.random_target]
          else
            [friends_unit.smooth_target(@target_index)]
          end
        else
          friends_unit.alive_members
        end
      end
    end
  end
end