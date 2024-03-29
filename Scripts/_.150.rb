module FAKEREAL
  
  ALTIMET_WEAPON = Hash[
    18  => [[0,134,1],[0,67,5],[0,137,5],[0,195,2],[0,338,2],[0,49,2]],
    105 => [[0,134,2],[0,49,2],[0,305,2],[0,308,3],],
    33  => [[0,49,2],[0,338,2],[0,72,2],[0,307,1],[0,302,1]],
    52  => [[0,48,2],[0,49,2],[0,339,2],[0,340,2]]
  ]
  
  ALTIMET_ARMOR = Hash[
    365  => [[0,49,1],[0,338,2]]
  ]
  
  AW_LP_PLICE = Hash[
    18  => [10000,1],
    105 => [10000,1],
    33  => [10000,2],
    52  => [10000,3],
  ]
  
  AA_LP_PLICE = Hash[
    365  => [2500,1],
  ]
  
end

#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def has_material?(id, type = "w")
    case type
    when "w" ; FAKEREAL::ALTIMET_WEAPON[id].all? {|a| item_number(material_change(a)) >= a[2] }
    when "a" ; FAKEREAL::ALTIMET_ARMOR[id].all? {|a| item_number(material_change(a)) >= a[2] }
    else     ; false
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def material_change(ary)
    case ary[0]
    when 0 ; $data_items[ary[1]]
    when 1 ; $data_weapons[ary[1]]
    when 2 ; $data_armors[ary[1]]
    else   ; nil
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def has_lp?(id, type = "w")
    case type
    when "w" ; item = FAKEREAL::AW_LP_PLICE[id]
    when "a" ; item = FAKEREAL::AA_LP_PLICE[id]
    else     ; return false
    end
    return $game_actors[item[1]].ap >= item[0]
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def has_altimet?(id, type = "w")
    case type
    when "w" ; has_item?($data_weapons[id], true)
    when "a" ; has_item?($data_armors[id], true)
    else     ; return false
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def altimet_cost_pay(id, type = "w")
    case type
    when "w" 
      item = FAKEREAL::AW_LP_PLICE[id]
      FAKEREAL::ALTIMET_WEAPON[id].each {|a|
        lose_item(material_change(a), a[2])
      }
    when "a" 
      item = FAKEREAL::AA_LP_PLICE[id]
      FAKEREAL::ALTIMET_ARMOR[id].each {|a|
        lose_item(material_change(a), a[2])
      }
    end
    $game_actors[item[1]].ap -= item[0]
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def altimet_gain(id, type = "w")
    case type
    when "w" ; gain_item($data_weapons[id], 1)
    when "a" ; gain_item($data_armors[id], 1)
    end
  end
  
  
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def material_lp?(id, type = "w")
    $game_party.has_material?(id, type) && $game_party.has_lp?(id, type)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def has_altimet?(id, type = "w")
    $game_party.has_altimet?(id, type)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def altimet_cost_pay(id, type = "w")
    $game_party.altimet_cost_pay(id, type)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def altimet_gain(id, type = "w")
    $game_party.altimet_gain(id, type)
  end
end

module FRCM
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def self.has_aw_all?
    FAKEREAL::ALTIMET_WEAPON.keys.all? {|k| $game_party.has_altimet?(k, "w") }
  end
end