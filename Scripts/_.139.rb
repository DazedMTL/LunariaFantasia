#=begin
#==============================================================================
# ■ Window_EquipItem
#------------------------------------------------------------------------------
# 　装備画面で、装備変更の候補となるアイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか　※エイリアス
  #--------------------------------------------------------------------------
  alias ex_dual_include? include?
  def include?(item)
    if dual?(@actor, @slot_id)
      return true if item == nil
      return false unless item.is_a?(RPG::EquipItem)
      return false if @slot_id < 0
      return false if item.etype_id > 1
      return @actor.equippable?(item)
    else
      ex_dual_include?(item)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 二刀流の左手スロットか
  #--------------------------------------------------------------------------
  def dual?(actor, slot_id)
    return false if !actor
    return false unless slot_id == 1
    return actor.dual_wield?
  end
end


#==============================================================================
# ■ Window_EquipSlot
#------------------------------------------------------------------------------
# 　装備画面で、アクターが現在装備しているアイテムを表示するウィンドウです。
#==============================================================================

class Window_EquipSlot < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 装備スロットの名前を取得　※エイリアス
  #--------------------------------------------------------------------------
  alias ex_dual_slot_name slot_name
  def slot_name(index)
    if @actor && @actor.dual_wield?
      case index
      when 0 ; "右手"
      when 1 ; "左手"
      else ; Vocab::etype(@actor.equip_slots[index])
      end
    else
      ex_dual_slot_name(index)
    end
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
  # ○ 定数
  #--------------------------------------------------------------------------
  DUAL_WTYPE_ID  = 10              # 二刀流の武器タイプID
  SHIELD_WTYPE_ID  = 11              # 盾の武器タイプID
  EX_TYPES = [10, 11]
  #--------------------------------------------------------------------------
  # ○ 左手武器の攻撃力がフルか
  #--------------------------------------------------------------------------
  def full_atk_dual_wield?
    all_note_check("<二刀流極み>")
  end
  #--------------------------------------------------------------------------
  # ● 特定のタイプの武器を装備しているか　※二刀流対応
  #--------------------------------------------------------------------------
  alias ex_dual_wtype_equipped? wtype_equipped?
  def wtype_equipped?(wtype_id)
    EX_TYPES.include?(wtype_id) ? extra_equipped?(wtype_id) : ex_dual_wtype_equipped?(wtype_id)
    #wtype_id == DUAL_WTYPE_ID ? weapons.size == 2 : ex_dual_wtype_equipped?(wtype_id)
    #weapons.any? {|weapon| weapon.wtype_id == wtype_id }
  end
  #--------------------------------------------------------------------------
  # ○ 特定のタイプの武器を装備しているか　※二刀流対応
  #--------------------------------------------------------------------------
  def extra_equipped?(id)
    case id
    when DUAL_WTYPE_ID;   weapons.size == 2
    when SHIELD_WTYPE_ID; armors.any? {|armor| armor.etype_id == 1 }
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備の変更　※エイリアス
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  alias ex_dual_change_equip change_equip
  def change_equip(slot_id, item)
    @active_change = true
    if dual_wield? && slot_id == 1
      return unless trade_item_with_party(item, equips[slot_id])
      return if item && item.etype_id > 1
      @equips[slot_id].object = item
      refresh
    else
      ex_dual_change_equip(slot_id, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備できない装備品を外す　※エイリアス
  #     item_gain : 外した装備品をパーティに戻す
  #--------------------------------------------------------------------------
  alias ex_dual_release_unequippable_items release_unequippable_items
  def release_unequippable_items(item_gain = true)
    if dual_wield?
      loop do
        last_equips = equips.dup
        @equips.each_with_index do |item, i|
          if !equippable?(item.object) || item.object.etype_id != equip_slots[i] #&& i != 1 )
            next if item.object && i == 1 && equippable?(item.object) && item.object.etype_id == 1
            trade_item_with_party(nil, item.object) if item_gain
            item.object = nil
          end
        end
        return if equips == last_equips
      end
    else
      ex_dual_release_unequippable_items(item_gain)
    end
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の加算値取得　※エイリアス
  #--------------------------------------------------------------------------
  alias ex_dual_param_plus param_plus
  def param_plus(param_id)
    if dual_wield? && param_id == 2 && @equips[1].object && @equips[1].object.etype_id == 0
      ex_dual_param_plus(param_id) - (full_atk_dual_wield? ? 0 : @equips[1].object.params[param_id] / 2)
    else
      ex_dual_param_plus(param_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 最強装備　※エイリアス
  #--------------------------------------------------------------------------
  alias ex_dual_optimize_equipments optimize_equipments
  def optimize_equipments(pattern = :atk)
    if dual_wield?
      equip_slots.size.times do |i|
        next if !equip_change_ok?(i) || equip_slots[i] == 4 # 装飾品除外追加
        items = $game_party.equip_items.select do |item|
          item.etype_id == equip_slots[i] &&
          equippable?(item) && item.performance >= 0
        end
=begin
        if i == 0 || (i == 1 && items.empty? && (@equips[1].object ? @equips[1].object.etype_id != 0 : true))
          dual_optimize(i, items.max_by {|item| item.params[2] })
        elsif i == 1 && (@equips[1].object ? @equips[1].object.etype_id != 0 : true)
          shields = $game_party.equip_items.select do |item|
            item.etype_id == 1 && equippable?(item) && item.performance >= 0
          end
          shield = shields.max_by {|item| temp_equip(item, i, pattern) + item.performance }
          if !shield && !@equips[1].object
            dual_optimize_change_equip(i, items.max_by {|item| temp_equip(item, i, pattern) + item.performance }, pattern)
          else
            dual_optimize_change_equip(i, shield, pattern)
          end
=end
        if i == 0
          dual_optimize(i, items.max_by {|item| item.params[2] })
        elsif i == 1
          shield_optimize(i, items, pattern)
        else
          optimize_change_equip(i, items.max_by {|item| temp_equip(item, i, pattern) + item.performance }, pattern)
        end
      end
    else
      ex_dual_optimize_equipments(pattern)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 最強装備　二刀流用
  #--------------------------------------------------------------------------
  def dual_optimize(i, item)
    @active_change = true
    #if i == 0
    now_right = @equips[0].object
    now_left = @equips[1].object
    v1 = item ? temp_equip(item, i, :atk) : 0
    v2 = now_right ? temp_equip(now_right, i, :atk) : 0
    v3 = now_left ? temp_equip(now_left, i, :atk) : 0
    if v1 == v2 && v1 == v3 && v1 == 999
      v1 += item.full_performance
      v2 += now_right.full_performance
      v3 += now_left.full_performance
    end
    ary = []
    ary.push([v1,item])
    ary.push([v2,now_right])
    ary.push([v3,now_left]) if now_left && now_left.etype_id == 0
    new = ary.max_by {|a| a[0]}[1]
    return if new == now_right || !new
    if $game_party.has_item?(new)
      dual_force_change_equip(0, new)
    else
      dual_force_change_equip(1, nil) if new == now_left
      dual_force_change_equip(0, new)
    end
    #else
      #if !item
        #shields = $game_party.equip_items.select do |item|
          #item.etype_id == 1 && equippable?(item) && item.performance >= 0
        #end
        #shield = shields.max_by {|item| temp_equip(item, i, :atk) + item.performance }
        #change_equip(i, shield) if shield
        #dual_optimize_change_equip(i, shield) if shield
      #end
    #end
  end
  #--------------------------------------------------------------------------
  # 〇 二刀流装備の変更
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  def dual_force_change_equip(slot_id, item)
    @active_change = true
    return unless trade_item_with_party(item, equips[slot_id])
    return if item && item.etype_id > 1
    @equips[slot_id].object = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 最強装備　二刀流・左手用
  #--------------------------------------------------------------------------
  def shield_optimize(i, items, pattern)
    @active_change = true
    item = items.max_by {|item| temp_equip(item, i, pattern) + item.performance }
    if pattern == :atk && !items.empty?
      dual_optimize_change_equip(i, item, pattern)
    else
      shields = $game_party.equip_items.select do |item|
        item.etype_id == 1 && equippable?(item) && item.performance >= 0
      end
      shield = shields.max_by {|item| temp_equip(item, i, pattern) }
      new = ([shield] + [item]).compact.max_by {|item| temp_equip(item, i, pattern) }
      dual_optimize_change_equip(i, new, pattern) if new
    end
  end
  #--------------------------------------------------------------------------
  # ○ 最強装備の変更
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  def dual_optimize_change_equip(slot_id, item, pattern)
    @active_change = true
    now = @equips[slot_id].object
    if now
      return unless item
      #return if now == item || now.performance >= item.performance
      return if now == item
      return if temp_equip(now, slot_id, pattern) > temp_equip(item, slot_id, pattern)
      return if temp_equip(now, slot_id, pattern) == temp_equip(item, slot_id, pattern) && now.performance > item.performance
    end
    return unless trade_item_with_party(item, equips[slot_id])
    return if item && item.etype_id > 1
    @equips[slot_id].object = item
    refresh
  end
end
#=end
