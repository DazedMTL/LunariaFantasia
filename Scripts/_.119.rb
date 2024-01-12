#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● アイテムオブジェクトの配列取得 
  #--------------------------------------------------------------------------
  #alias sort_items items
  def items
    #@items.keys.sort.collect {|id| $data_items[id] }
    #sort_items
=begin
    @items = Hash[
      @items.sort do |(k1, v1), (k2, v2)|
        if $data_items[k1].category_id == $data_items[k2].category_id
          k1 - k2
        else
          $data_items[k1].category_id - $data_items[k2].category_id
        end
      end
                   ]
    @items.keys.collect {|id| $data_items[id] }
=end
    @items.keys.sort_by {|id| [$data_items[id].category_id, id] }.collect {|id| $data_items[id] }
    #@items = Hash[@items.keys.sort {|a, b| $data_items[a].category_id <=> $data_items[b].category_id}]
  end
  #--------------------------------------------------------------------------
  # ● 武器オブジェクトの配列取得 
  #--------------------------------------------------------------------------
  def weapons
=begin
    @weapons = Hash[
      @weapons.sort do |(k1, v1), (k2, v2)|
        if $data_weapons[k1].category_id == $data_weapons[k2].category_id
          k1 - k2
        else
          $data_weapons[k1].category_id - $data_weapons[k2].category_id
        end
      end
                   ]
    @weapons.keys.collect {|id| $data_weapons[id] }
=end
    @weapons.keys.sort_by {|id| [$data_weapons[id].category_id, id] }.collect {|id| $data_weapons[id] }
    #@weapons.keys.sort.collect {|id| $data_weapons[id] }
  end
  #--------------------------------------------------------------------------
  # ● 防具オブジェクトの配列取得 
  #--------------------------------------------------------------------------
  def armors
=begin
    @armors = Hash[
      @armors.sort do |(k1, v1), (k2, v2)|
        if $data_armors[k1].category_id == $data_armors[k2].category_id
          k1 - k2
        else
          $data_armors[k1].category_id - $data_armors[k2].category_id
        end
      end
                   ]
    @armors.keys.collect {|id| $data_armors[id] }
=end
    @armors.keys.sort_by {|id| [$data_armors[id].category_id, id] } .collect {|id| $data_armors[id] }
    #@armors.keys.sort.collect {|id| $data_armors[id] }
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
  # ● スキルオブジェクトの配列取得　※再定義
  #--------------------------------------------------------------------------
  def skills
    (@skills | added_skills).sort_by {|id| [$data_skills[id].category_id, id] }.collect {|id| $data_skills[id] }
  end
end

class RPG::BaseItem
  def category_id
    #self.note =~ /\<カテゴリID\:(\d+)\>/ ? $1.to_i : 5
    self.note =~ /\<カテゴリID\:(\d*?\.?\d+?)\>/ ? $1.to_f : 5.0
  end
end
