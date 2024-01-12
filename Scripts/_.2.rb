class RPG::BaseItem
  def par
    @par ||= par_set
  end
  def par_set
    return $1.to_i * 0.01 if self.note =~ /\<物理与ダメージ率:(\d+)\>/
    return 1.0
  end
  def mar
    @mar ||= mar_set
  end
  def mar_set
    return $1.to_i * 0.01 if self.note =~ /\<魔法与ダメージ率:(\d+)\>/
    return 1.0
  end
end

class RPG::UsableItem < RPG::BaseItem
  def damage_type
    return @hit_type if @hit_type != 0
    self.note =~ /\<魔法\>/ ? 2 : 1
  end
end

#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。主に能力値計算のメソッドを含んでいます。こ
# のクラスは Game_Battler クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_BattlerBase
  def par;  1.0;  end    # 物理与ダメージ率  Physical Attack Rate
  def mar;  1.0;  end    # 魔法与ダメージ率  Magical Attack Rate
end


#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　スプライトや行動に関するメソッドを追加したバトラーのクラスです。このクラス
# は Game_Actor クラスと Game_Enemy クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● ダメージ計算　※再定義
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    value *= item_element_rate(user, item)
    value *= pdr if extra_physical?(item)#item.physical?
    value *= mdr if extra_magical?(item)#item.magical?
    value *= attack_rate(user, item) unless item.damage.recover?
    value *= rec if item.damage.recover?
    value = apply_critical(value) if @result.critical
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    @result.make_damage(value.to_i, item)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def attack_rate(user, item)
    case item.damage_type
    when 1; user.par
    when 2; user.mar
    else  ; 1.0
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def extra_physical?(item)
    item.physical? || (item.certain? && item.damage_type == 1 && !item.damage.recover?)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def extra_magical?(item)
    item.magical? || (item.certain? && item.damage_type == 2 && !item.damage.recover?)
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
  # ○ 物理与ダメージ率の取得
  #--------------------------------------------------------------------------
  def par
    full_equip_plus_states.inject(super) {|r, obj| r *= obj.par} * last_par * difficulty_damage_rate
  end
  #--------------------------------------------------------------------------
  # ○ 魔法与ダメージ率の取得
  #--------------------------------------------------------------------------
  def mar
    full_equip_plus_states.inject(super) {|r, obj| r *= obj.mar} * last_mar * difficulty_damage_rate
  end
  #--------------------------------------------------------------------------
  # ○ 最終戦物理与ダメージ率の取得
  #--------------------------------------------------------------------------
  def last_par
    !main? && $game_variables[21] >= 81 ? 3.0 : 1.0
  end
  #--------------------------------------------------------------------------
  # ○ 最終戦魔法与ダメージ率の取得
  #--------------------------------------------------------------------------
  def last_mar
    !main? && $game_variables[21] >= 81 ? 3.0 : 1.0
  end
  #--------------------------------------------------------------------------
  # ○ 難易度による与ダメージ率の調整
  #--------------------------------------------------------------------------
  def difficulty_damage_rate
    case $game_system.difficulty
    when :easy;      1.2
    else ;           1.0
    end
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
  # ○ 物理与ダメージ率の取得
  #--------------------------------------------------------------------------
  def par
    #return $1.to_i * 0.01 if enemy.note =~ /\<物理与ダメージ率:(\d+)\>/
    feature_objects.inject(super) {|r, obj| r *= obj.par} * difficulty_damage_rate
    #states.inject(super) {|r, obj| r *= obj.par}
    #super
  end
  #--------------------------------------------------------------------------
  # ○ 魔法与ダメージ率の取得
  #--------------------------------------------------------------------------
  def mar
    #return $1.to_i * 0.01 if enemy.note =~ /\<魔法与ダメージ率:(\d+)\>/
    feature_objects.inject(super) {|r, obj| r *= obj.mar} * 0.5 * difficulty_damage_rate
    #states.inject(super) {|r, obj| r *= obj.mar} * 0.5
    #super * 0.5 # 魔法の威力はアクターの半分
  end
  #--------------------------------------------------------------------------
  # ○ 難易度による与ダメージ率の調整
  #--------------------------------------------------------------------------
  def difficulty_damage_rate
    case $game_system.difficulty
    when :easy;      0.8
    else ;           1.0
    end
  end
end