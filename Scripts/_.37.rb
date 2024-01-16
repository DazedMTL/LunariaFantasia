module FAKEREAL
  
  ADD_EVENT      = [] #追加イベントの実装番号  25=サカイ名主息子 41=メリス 43=オアシス眠姦 45=仲間との休日
  LEVELAP        = 5
  GOLD_NAME      = "Rebel"
  IDATEN      = 86
  E_RATE_UP   = "<エンカウント倍加>"
  E_AURA   = "<雑魚避け>"
  ENCOUNT_TYPE = 1 #0だとデフォルト、1だとオリジナル
  
  UNKNOWN_SWITCH = 14 # 敵HPのハテナ表示判定

  RANDOM = "Neighbor" # 
  
  # 特殊能力値
  def self.xparam(param_id)
    case param_id
    when 0 ;        "Hit"
    when 1 ;        "Evasion"
    when 2 ;        "Crit"
    else   ;        ""
    end
  end

  def self.bwhsize(id)
    case id
    when 0 ;        "Height:"
    when 1 ;        "B:"
    when 2 ;        "W:"
    when 3 ;        "H:"
    else   ;        ""
    end
  end
  
  def self.deep_copy(obj)
    Marshal.load(Marshal.dump(obj))
  end
end

class << Vocab
  alias max_tp_param param
  def param(param_id)
    if param_id < 8
      max_tp_param(param_id)
    else
      "Max SP"
    end
  end
end

#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
# 　用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#==============================================================================

module Vocab

  LevelAp     = "Level up achieved %s to %s acquisition!"
  
end


#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● パーティ能力判定　※再定義　控えメンバーの能力も考慮
  #--------------------------------------------------------------------------
  def party_ability(ability_id)
    all_members.any? {|actor| actor.party_ability(ability_id) }
  end
  #--------------------------------------------------------------------------
  # ○ エンカウント増加　※追加
  #--------------------------------------------------------------------------
  def encounter_rate_up?
    extra_equip_include?(FAKEREAL::E_RATE_UP)
  end
  #--------------------------------------------------------------------------
  # ○ 雑魚避け　※追加
  #--------------------------------------------------------------------------
  def encount_aura?
    extra_equip_include?(FAKEREAL::E_AURA)
  end
  #--------------------------------------------------------------------------
  # ● アイテムの最大所持数取得
  #--------------------------------------------------------------------------
  alias original_max_item_number max_item_number
  def max_item_number(item)
    if item && !item.costume.empty?
      return 1
    else
      return original_max_item_number(item)
    end
  end
  #--------------------------------------------------------------------------
  # 〇 パーティメンバーの平均レベルの取得
  #--------------------------------------------------------------------------
  def average_level
    members.inject(0) {|r, actor| r += actor.level } / members.size
  end
=begin
  #--------------------------------------------------------------------------
  # ○ 雑魚避け条件を満たしてるか　※追加
  #--------------------------------------------------------------------------
  def weak_no_encount?
    return false if battle_members.size == 0
    encount_aura? && ($game_map.no_encount_level <= leader.level)
  end
=end
  #--------------------------------------------------------------------------
  # ○ 雑魚避け条件を満たしてるか　※追加　リージョンID対応
  #--------------------------------------------------------------------------
  def weak_no_encount?
    return false if battle_members.size == 0
    encount_aura? && ($game_map.no_encount_level($game_player.region_id) <= average_level)#leader.level)
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
  # ○ 特徴値の総差計算（データ ID を指定）
  #--------------------------------------------------------------------------
  def features_diff(code, id)
    features_with_id(code, id).inject(1.0) {|r, ft| r -= (1.0 - ft.value)} 
  end
  #--------------------------------------------------------------------------
  # ● ステート有効度の取得　※再定義
  #    ステートはそれぞれの装備品等の防御率を積ではなく差で求める
  #    例：有効度90%の装備品は防御率10%
  #        防御率10%と40%を装備すると防御率は50%
  #--------------------------------------------------------------------------
  def state_rate(state_id)
    [features_diff(FEATURE_STATE_RATE, state_id), 0.0].max
  end
  #--------------------------------------------------------------------------
  # ○ 女性か
  #--------------------------------------------------------------------------
  def woman?
    false
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
  # ● 使用効果のテスト　※再定義
  #--------------------------------------------------------------------------
  def item_effect_test(user, item, effect)
    case effect.code
    when EFFECT_RECOVER_HP
      hp < mhp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_RECOVER_MP
      mp < mmp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_GAIN_TP #追加
      tp < max_tp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_ADD_STATE
      !state?(effect.data_id)
    when EFFECT_REMOVE_STATE
      state?(effect.data_id)
    when EFFECT_ADD_BUFF
      !buff_max?(effect.data_id)
    when EFFECT_ADD_DEBUFF
      !debuff_max?(effect.data_id)
    when EFFECT_REMOVE_BUFF
      buff?(effect.data_id)
    when EFFECT_REMOVE_DEBUFF
      debuff?(effect.data_id)
    when EFFECT_LEARN_SKILL
      actor? && !skills.include?($data_skills[effect.data_id])
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # ● 使用効果［TP 増加］※再定義
  #--------------------------------------------------------------------------
  def item_effect_gain_tp(user, item, effect)
    if item.note =~ /\<TP回復:全回復\>/
      value = max_tp
    elsif item.note =~ /\<TPダメージ:(\d+)\>/
      value = effect.value1.to_i * -1
      value -= $1.to_i #if item.note =~ /\<TPダメージ:(\d+)\>/ #追加
    elsif item.note =~ /\<TPダメージ率:(\d+)\>/
      value = effect.value1.to_i * -1
      value -= (max_tp * $1.to_i * 0.01).to_i
    elsif item.note =~ /\<TP回復率:(\d+)\>/
      value = max_tp * $1.to_i / 100
    else
      value = effect.value1.to_i
      value += $1.to_i if item.note =~ /\<TP回復:(\d+)\>/ #追加
    end
    @result.tp_damage -= value
    @result.success = true if value != 0
    self.tp += value
  end
  #--------------------------------------------------------------------------
  # ● TP の再生　※再定義
  #--------------------------------------------------------------------------
  def regenerate_tp
    self.tp += max_tp * trg if $game_party.in_battle
  end
  #--------------------------------------------------------------------------
  # ● HP の再生　※エイリアス
  #    HP回復は戦闘中のみ
  #--------------------------------------------------------------------------
  alias battle_only_regenerate_hp regenerate_hp
  def regenerate_hp
    return if hrg > 0 && !$game_party.in_battle
    battle_only_regenerate_hp
  end
  #--------------------------------------------------------------------------
  # ● MP の再生　※エイリアス
  #--------------------------------------------------------------------------
  alias battle_only_regenerate_mp regenerate_mp
  def regenerate_mp
    return if mrg > 0 && !$game_party.in_battle
    battle_only_regenerate_mp
  end
  #--------------------------------------------------------------------------
  # ● クリティカルの適用　※再定義
  #--------------------------------------------------------------------------
  def apply_critical(damage)
    damage * 2
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
  # ○ 主人公か
  #--------------------------------------------------------------------------
  def main?
    actor.note.include?("<主人公>")
  end
  #--------------------------------------------------------------------------
  # ○ 女性か
  #--------------------------------------------------------------------------
  def woman?
    !actor.note.include?("<男性>")
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def sex_name
    woman? ? "Female" : (actor.note =~ /<性別:(\D+)>/ ? $1 : "Male")
  end
  #--------------------------------------------------------------------------
  # ● 経験値の変更　※エイリアス
  #     show : レベルアップ表示フラグ
  #--------------------------------------------------------------------------
  alias ap_disp_change_exp change_exp
  def change_exp(exp, show)
    #@exp[@class_id] = [exp, 0].max
    #last_level = @level
    #last_skills = skills
    #level_up while !max_level? && self.exp >= next_level_exp
    #level_down while self.exp < current_level_exp
    #display_level_up(skills - last_skills) if show && @level > last_level
    #refresh
    last_level = @level
    ap_disp_change_exp(exp, show)
    display_levelap_gain(last_level + 1, @level) if show && @level > last_level
  end
  #--------------------------------------------------------------------------
  # ○ レベルアップによる獲得APメッセージの表示
  #--------------------------------------------------------------------------
  def display_levelap_gain(start, finish)
    gain = (start..finish).inject(0) {|r, i| r += i * FAKEREAL::LEVELAP}
    $game_message.add(sprintf(Vocab::LevelAp, Vocab::ap_ex, gain)) if gain > 0
  end
  #--------------------------------------------------------------------------
  # ● レベルアップ　※エイリアス
  #--------------------------------------------------------------------------
  alias fr_s_level_up level_up
  def level_up
    hr = hp_rate
    mr = mp_rate
    tr = tp_rate
    fr_s_level_up
    @hp = (mhp * hr).to_i
    @mp = (mmp * mr).to_i
    @tp = (max_tp * tr).to_i
    self.ap += @level * FAKEREAL::LEVELAP
    #recover_all
  end
  #--------------------------------------------------------------------------
  # ● 床ダメージの基本値を取得　※再定義
  #--------------------------------------------------------------------------
  def basic_floor_damage(rate = 0.05)
    return (mhp * rate).to_i
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットの配列を取得　※再定義
  #--------------------------------------------------------------------------
  #def equip_slots
    #return [0,0,2,3,4] if dual_wield?       # 二刀流
    #return [0,1,2,3,4]                      # 通常
  #end
  #--------------------------------------------------------------------------
  # ● 経験獲得率      EXperience Rate　※オーバーライド
  #--------------------------------------------------------------------------
  def exr
    [[super, exr_skill].max, 1.25].min
  end
  #--------------------------------------------------------------------------
  # ○ スキルによる経験値獲得率
  #--------------------------------------------------------------------------
  def exr_skill
    equip_class.compact.inject(1.0) {|rate, job| rate + (job.exp_skill_rate) * skill_lv(job.skill_ni[1])}#ECSystem.skill_id(job.id))}
  end
  #--------------------------------------------------------------------------
  # ○ 属性アニメの取得
  #--------------------------------------------------------------------------
  def element_animation(elements)
    elements.delete(1)
    return 0 if elements.empty?
    return elements[-1] - 2
  end
  #--------------------------------------------------------------------------
  # ○ 属性アニメの取得(光と闇有り)
  #--------------------------------------------------------------------------
  def ld_element_animation(elements)
    elements.delete(1)
    return 0 if elements.empty?
    return elements[-1] + 341 if [9,10].include?(elements[-1])
    return elements[-1] + 345 if [7].include?(elements[-1])
    return elements[-1] - 2
  end
  #--------------------------------------------------------------------------
  # ○ 通常攻撃アニメかどうか
  #--------------------------------------------------------------------------
  def normal_atk?(id)
    natk_id.include?(id)
  end
  #--------------------------------------------------------------------------
  # ○ 通常斬撃アニメかどうか
  #--------------------------------------------------------------------------
  def slash_atk?(id)
    id == 7
  end
  #--------------------------------------------------------------------------
  # ○ 通常攻撃アニメの配列
  #--------------------------------------------------------------------------
  def natk_id
    [1, 7, 13, 19, 82]
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 アニメーション ID の取得　※エイリアス
  #　　属性が付加された場合そのエフェクトアニメに変更
  #　　但しもともと属性アニメだった場合は変更なし
  #--------------------------------------------------------------------------
  alias element_atk_animation_id1 atk_animation_id1
  def atk_animation_id1
    a_id = element_atk_animation_id1
    return a_id if extra_equipped?(DUAL_WTYPE_ID) # 二刀流(ソニア)の場合そのままのアニメを返す
    if slash_atk?(a_id)
      a_id += ld_element_animation(atk_elements)
    elsif normal_atk?(a_id)
      a_id += element_animation(atk_elements)
    end
    #a_id += element_animation(atk_elements) if normal_atk?(a_id) #a_id % 6 == 1 && a_id < 29
    return a_id
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 アニメーション ID の取得（二刀流：武器２）　※エイリアス
  #    二刀流対応
  #--------------------------------------------------------------------------
  alias element_atk_animation_id2 atk_animation_id2
  def atk_animation_id2
    a_id = element_atk_animation_id2
    return a_id if extra_equipped?(DUAL_WTYPE_ID) # 二刀流(ソニア)の場合そのままのアニメを返す
    unless a_id == 0
      if slash_atk?(a_id)
        a_id += ld_element_animation(atk_elements)
      elsif normal_atk?(a_id)
        a_id += element_animation(atk_elements)
      end
      #a_id += element_animation(atk_elements) if normal_atk?(a_id) #a_id % 6 == 1
    end
    return a_id
  end
  #--------------------------------------------------------------------------
  # ● 装備を全て外す　※再定義
  #--------------------------------------------------------------------------
  def clear_equipments
    equip_slots.size.times do |i|
      next if equip_slots[i] == 4 # 装飾品は除外
      change_equip(i, nil) if equip_change_ok?(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 最強装備　※再定義
  #--------------------------------------------------------------------------
  def optimize_equipments(pattern = :atk)
    #clear_equipments
    equip_slots.size.times do |i|
      next if !equip_change_ok?(i) || equip_slots[i] == 4 # 装飾品除外追加
      items = $game_party.equip_items.select do |item|
        item.etype_id == equip_slots[i] &&
        equippable?(item) && item.performance >= 0
      end
      optimize_change_equip(i, items.max_by {|item| temp_equip(item, i, pattern) + item.performance }, pattern)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 最強装備の変更
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  def optimize_change_equip(slot_id, item, pattern)
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
    return if item && equip_slots[slot_id] != item.etype_id
    @equips[slot_id].object = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 仮装備
  #--------------------------------------------------------------------------
  def temp_equip(item, slot_id, pattern)
    te_actor = Marshal.load(Marshal.dump(self))
    te_actor.force_change_equip(slot_id, item)
    te_actor.temp_performance(pattern, slot_id)
  end
  #--------------------------------------------------------------------------
  # ○ 仮装備時のパラメータ
  #--------------------------------------------------------------------------
  def temp_performance(pattern, slot_id)
    if slot_id == 0 || (slot_id == 1 && @actor_id == 2)
      case pattern
      when :atk ; atk
      when :mat ; mat
      when :mdf ; mdf
      when :def ; self.def
      when :agi ; agi
      when :eva ; eva * 100 + self.def * 0.0001
      else ; atk + self.def + mat + mdf
      end
    else
      v = 0
      case pattern
      when :atk ; v = atk * 0.1 + mdf
      when :mat ; v = mat * 0.1 + mdf
      when :mdf ; v = mdf * 0.1
      when :def ; v = mdf * 0.01
      when :agi ; v = agi * 0.1 + mdf
      when :eva ; v = eva
      else ; v = mdf
      end
      self.def + v
    end
  end
  #--------------------------------------------------------------------------
  # ○ 個々の最適パターン
  #--------------------------------------------------------------------------
  def optimize_pattern
    actor.optimize_pattern
  end
  #--------------------------------------------------------------------------
  # ○ 個々の最適パターンセット
  #--------------------------------------------------------------------------
=begin
  def optimize_pattern_set
    pat = {}
    actor.note.each_line do |line|
      case line
      when /\<最適パターン:(\w+)\,(\D+)\>/
        pat[$2] = $1.to_sym
      end
    end
    pat["Attack"] = :atk if pat.empty?
    return pat
    #@optimize_pattern ||= opt_pattern_set
    #return actor.note =~ /\<最適パターン:(\d+)\>/ ? $1.to_i : 1
  end
=end
end

class RPG::Actor < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ 個々の最適パターン
  #--------------------------------------------------------------------------
  def optimize_pattern
    @optimize_pattern ||= optimize_pattern_set
  end
  #--------------------------------------------------------------------------
  # ○ 個々の最適パターンセット
  #--------------------------------------------------------------------------
  def optimize_pattern_set
    pat = {}
    self.note.each_line do |line|
      case line
      when /\<最適パターン:(\w+)\,(\D+)\>/
        pat[$2] = $1.to_sym
      end
    end
    pat["Attack"] = :atk if pat.empty?
    return pat
  end
end

class RPG::Class < RPG::BaseItem
  def exp_skill_rate
    rate = 0
    self.note.each_line do |line|
      case line
      when /<経験値倍率加算:(\d+)>/
        rate = $1.to_i
      end
    end
    return rate * 0.01
  end
end

class RPG::Armor < RPG::EquipItem
  # 再定義
  def performance
    params[3] + params[5]
  end
end

class RPG::Weapon < RPG::EquipItem
  # 再定義
  def performance
    wtype_id == 4 ? params[2] + params[5] : params[2] + params[4]
  end
end

class RPG::EquipItem < RPG::BaseItem
  def full_performance
    params.inject(0) {|r, v| r += v }
  end
end

#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================

#=begin
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● ダッシュ状態判定
  #--------------------------------------------------------------------------
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return false if vehicle
    return not_press? #Input.press?(:A)
  end
  #--------------------------------------------------------------------------
  # ● 移動速度の取得（ダッシュを考慮）　※オーバーライド
  #--------------------------------------------------------------------------
  def real_move_speed
    @move_speed + dash_speed #+ idaten_speed #(dash? ? 0 : 1)
  end
  #--------------------------------------------------------------------------
  # ○ 移動速度の設定
  #--------------------------------------------------------------------------
  def not_press?
    !Input.press?(:A)
  end
  #--------------------------------------------------------------------------
  # ○ 移動速度の設定
  #--------------------------------------------------------------------------
  def dash_speed
    #return dash? ? 2 : 1 if idaten?
    #return dash? ? 0 : 1
    #return dash? ? 1 : 2 if idaten?
    return dash? ? 1 : 0
  end
  #--------------------------------------------------------------------------
  # ○ 韋駄天
  #--------------------------------------------------------------------------
  def idaten?
    $game_switches[FAKEREAL::IDATEN]
    #$game_party.extra_equip_include?(FAKEREAL::IDATEN) #&& false
  end
  #--------------------------------------------------------------------------
  # ○ 韋駄天
  #--------------------------------------------------------------------------
  def idaten_speed
    #(idaten? && !@move_route_forcing && Input.press?(:A)) ? 2 : 0
    #(idaten? && !@move_route_forcing && Input.press?(:A)) ? 0.03125 * 5 : 0 #0.0625 * 2 : 0
    #(idaten? && !@move_route_forcing && Input.press?(:A)) ? 0.015625 * 9 : 0 #0.0625 * 2 : 0
    (idaten? && !@move_route_forcing && Input.press?(:A)) ? 0.015625 * 8 : 0 #0.0625 * 2 : 0
  end
  #--------------------------------------------------------------------------
  # ● 1 フレームあたりの移動距離を計算
  #--------------------------------------------------------------------------
  def distance_per_frame
    super + idaten_speed
  end
end

class Game_Follower
  #--------------------------------------------------------------------------
  # ○ 1 フレームあたりの移動距離を計算
  #--------------------------------------------------------------------------
  def distance_per_frame
    @preceding_character.distance_per_frame
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
  # ○ 女性か
  #--------------------------------------------------------------------------
  def woman?
    enemy.note.include?("<女性>")
  end
end

#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :menu_parallel          # 並列処理のメニュー禁止対策
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias parallel_initialize initialize
  def initialize
    parallel_initialize
    @menu_parallel = false
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
  # ● 実行
  #--------------------------------------------------------------------------
  alias parallel_run run
  def run
    menu_reset if $game_temp.menu_parallel && @trigger_type != 4
    parallel_run
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def menu_reset
    $game_temp.menu_parallel = false
    $game_system.menu_disabled = false
  end
end

class RPG::State < RPG::BaseItem
  def element_erase
    @element_erase ||= element_erase_set
  end
  def element_erase_set
    ee = []
    self.note.each_line do |line|
      case line
      when /\<属性消去:(\d+)\>/
        ee.push($1.to_i)
      end
    end
    return ee
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
  # 〇 
  #--------------------------------------------------------------------------
  def elements_erase_state
    #if 
    #set = ee_atk_elements
  end
  #--------------------------------------------------------------------------
  # ● 攻撃時属性の取得
  #--------------------------------------------------------------------------
  alias ee_atk_elements atk_elements
  def atk_elements
    set = ee_atk_elements
    if state_check("<属性消去:")
      ee = []
      states.each {|st| ee += st.element_erase if !st.element_erase.empty? }
      set -= ee
    end
    return set
  end
end

#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================

=begin
class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● キャンセルボタンによるメニュー呼び出し判定　※再定義
  #     移動中はメニュー判定をONにできないように
  #--------------------------------------------------------------------------
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running?
      @menu_calling = false
    else
      return if $game_player.moving? && !$game_player.slip_straight
      @menu_calling ||= Input.trigger?(:B)
      call_menu if @menu_calling && !$game_player.moving?
    end
  end
end

=end

#=end

=begin

#==============================================================================
# ■ Game_Action
#------------------------------------------------------------------------------
# 　戦闘行動を扱うクラスです。このクラスは Game_Battler クラスの内部で使用され
# ます。
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # ● 行動速度の計算　※再定義　TP反映
  #--------------------------------------------------------------------------
  def speed
    tp_agi = subject.agi * (1 + subject.tp_rate * 0.25) #(100 + subject.tp) / 100
    speed = tp_agi + rand(5 + tp_agi / 4)
    speed += item.speed if item
    speed += subject.atk_speed if attack?
    speed
  end
end


#------------------------------------------------------------------------------
# □ 全バトル敗北可能
#------------------------------------------------------------------------------


module FAKEREAL
  
  LOSE_SWITCH   = 1 # 敗北判定スイッチID
  LOSE_TROOP    = 1 # 敗北時の敵トループID格納変数
  
end

#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　敵グループおよび戦闘に関するデータを扱うクラスです。バトルイベントの処理も
# 行います。このクラスのインスタンスは $game_troop で参照されます。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :troop_id                   # トループID
end

#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは $game_system で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :all_can_lose            # 通常戦闘での敗北の可否
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias all_can_lose_initialize initialize
  def initialize
    all_can_lose_initialize
    @all_can_lose = true
  end
end

#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　戦闘の進行を管理するモジュールです。
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # ● 敗北の処理
  #--------------------------------------------------------------------------
  class << self
    alias :all_can_lose_process_defeat :process_defeat unless method_defined?(:all_can_lose_process_defeat)
    def process_defeat
      if $game_system.all_can_lose
        $game_message.add(sprintf(Vocab::Defeat, $game_party.name))
        wait_for_message
        if @can_lose
          revive_battle_members
          replay_bgm_and_bgs
          SceneManager.return
        else
          $game_switches[FAKEREAL::LOSE_SWITCH] = true
          $game_variables[FAKEREAL::LOSE_TROOP] = $game_troop.troop_id
          revive_battle_members
          replay_bgm_and_bgs
          SceneManager.return
        end
        battle_end(2)
        return true
      else
        all_can_lose_process_defeat
      end
    end
  end
end

=end
