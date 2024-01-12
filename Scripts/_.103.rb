#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
=begin
  #--------------------------------------------------------------------------
  # ○ 戦闘終了後の回復率：召喚ユニットのみ
  #--------------------------------------------------------------------------
  def heal_rate
    return 0
  end
  #--------------------------------------------------------------------------
  # ○ 回復値の上昇　
  #--------------------------------------------------------------------------
  def heal_lv_rate(base)
    return 0
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの消滅
  #--------------------------------------------------------------------------
  def summon_remove
  end
  #--------------------------------------------------------------------------
  # ○ 割合回復　※改修時に追加
  #--------------------------------------------------------------------------
  def summon_heal(rate)
  end
=end
  #--------------------------------------------------------------------------
  # ○ 召喚スキルを使えるか
  #--------------------------------------------------------------------------
  def summon_enabled
    added_skill_types.include?(SummonSystem::S_S_ID) && !skill_type_sealed?(SummonSystem::S_S_ID)
  end
  #--------------------------------------------------------------------------
  # ○ 召喚可能枠の追加
  #--------------------------------------------------------------------------
  def summon_plus
    full_equip.inject(0) {|r, full_e| r += full_e.summon_plus }
  end
  #--------------------------------------------------------------------------
  # ● セットアップ　※エイリアス
  #--------------------------------------------------------------------------
  alias summon_skill_setup setup
  def setup(actor_id)
    summon_skill_setup(actor_id)
    equip_skill_set
    recover_all
  end
  #--------------------------------------------------------------------------
  # ● スキルを覚える
  #--------------------------------------------------------------------------
  alias summon_learn_skill learn_skill
  def learn_skill(skill_id)
    summon_learn_skill(skill_id)
=begin
    if $data_skills[skill_id].stype_id == 3 && main?
      a_id = SummonSystem.summon_id($data_skills[skill_id])
      #$game_actors.actor_reset(a_id)
      #$game_actors[a_id].setup(a_id)
      #LNX11.条件バトラーグラフィックリセット(a_id)
    end
=end
    $game_party.lss_init_flag = true if main?
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
  # ● 使用効果［コモンイベント］
  #--------------------------------------------------------------------------
  alias summon_item_effect_common_event item_effect_common_event
  def item_effect_common_event(user, item, effect)
    summon_item_effect_common_event(user, item, effect)
    summon_setup(user, item, effect) if item.summon_unit_id
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ○ 召喚準備
  #--------------------------------------------------------------------------
  def summon_setup(user, item, effect)
    #$game_variables[2] = user.level - 1
    #$game_variables[3] = item.summon_unit_id
    $game_temp.remove_reserve_reset
    $game_temp.remove_reserve = self if summon_type?
    $game_variables[SummonSystem::S_V_ID] = item.summon_unit_id
    $game_variables[SummonSystem::S_LV_ID] = user.level
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
  # ○ 召喚ユニットか
  #--------------------------------------------------------------------------
  def summon_type?
    false
  end
  #--------------------------------------------------------------------------
  # ○ 召喚可能か
  #--------------------------------------------------------------------------
  def summon_ok?(skill)
    #$game_party.members.size < $game_party.max_battle_members &&
     !$game_party.summon_actor?(skill.summon_unit_id) &&
     #$game_party.summon_members_size < $game_variables[SummonSystem::S_N_ID] &&
     $game_party.summon_able.include?(skill.summon_unit_id) && !$game_party.summon_prohibit
  end
  #--------------------------------------------------------------------------
  # ● スキルの使用可能条件チェック
  #--------------------------------------------------------------------------
  alias summon_skill_conditions_met? skill_conditions_met?
  def skill_conditions_met?(skill)
    if skill.summon_unit_id
      summon_skill_conditions_met?(skill) && summon_ok?(skill)
    else
      summon_skill_conditions_met?(skill)
    end
  end
end

#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 指定の召喚ユニットが存在するか
  #--------------------------------------------------------------------------
  def summon_actor?(actor_id)
    @actors.include?(actor_id)
  end
end

#==============================================================================
# ■ Window_BattleLog
#------------------------------------------------------------------------------
# 　戦闘の進行を実況表示するウィンドウです。枠は表示しませんが、便宜上ウィンド
# ウとして扱います。
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● ステート付加の表示　※エイリアス
  #--------------------------------------------------------------------------
  alias summon_display_added_states display_added_states
  def display_added_states(target)
    summon_display_added_states(target)
    target.summon_death if target.summon_type?
  end
end



class RPG::UsableItem < RPG::BaseItem
  def summon_unit_id
    return SummonSystem::ACTOR_BASE_ID + $1.to_i if self.note =~ /\<ユニット召喚:(\-?\+?\d+)\>/
    false
  end
end

class RPG::BaseItem
  def rune?
    return false
  end
end


class RPG::Armor < RPG::EquipItem
  def rune?
    #return atype_id == SummonSystem::RUNE_ID
    return SummonSystem::RUNE_ID.include?(atype_id)
  end
end

class RPG::BaseItem
  def heal_rate_plus
    return $1.to_i if self.note =~ /\<召喚回復率:(\-?\+?\d+)\>/
    return 0
  end
  def summon_plus
    @summon_plus ||= summon_plus_set
  end
  def summon_plus_set
    self.note =~ /\<召喚枠:(\-?\+?\d+)\>/ ? $1.to_i : 0
  end
end


#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================
=begin
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def summon_battle_end
    summon_remove if summon_type?
  end
end
=end
#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor   :lss_init_flag        #
  attr_reader     :summon_members       #戦闘開始時に召喚するメンバーの配列
  attr_reader     :summon_able          #召喚可能ユニットの配列
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias summon_member_initialize initialize
  def initialize
    summon_member_initialize
    @summon_members = [nil, nil, nil]
    @lss_init_flag = false
    #@summon_done = []
    summon_array_set
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットのID配列作成
  #--------------------------------------------------------------------------
  def summon_array_set
    @summon_able = []
    $game_temp.summon_skills.each_key{|key| @summon_able.push(key)}
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの離脱
  #--------------------------------------------------------------------------
  def summon_remove
    #members.each{|actor| actor.summon_battle_end}
    members.each{|actor| remove_actor(actor.id) if actor.summon_type?}
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの戦闘後処理
  #--------------------------------------------------------------------------
  def summon_reset
    summon_remove if !summon_no_remove # 召喚ユニットを離脱させ
    summon_array_set
    @summon_able.each {|id| $game_actors[id].summon_heal(0)}
    #@summon_done = [] # 召喚済みユニットの配列をリセット
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットを加える
  #--------------------------------------------------------------------------
  def summon_actor(actor_id, level = $game_actors[1].level)
    #$game_actors[actor_id].setup(actor_id)
    $game_actors[actor_id].summon_level_set(level)#$game_actors[1].level)
    $game_actors[actor_id].last_actor_command = 0 #XPスタイルバトルあわせ　召喚と同時にアクターコマンドのカーソル記憶をリセット
    @actors.push(actor_id) unless @actors.include?(actor_id)
    @summon_able.delete(actor_id) # 召喚可能ユニット配列のアクターIDを削除
    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットを加える ※スキル発動用
  #--------------------------------------------------------------------------
  def summon_actor_skill(actor_id, level = $game_actors[1].level)
    change = $game_temp.remove_reserve ? $game_temp.remove_reserve : summon_members_top
    summon_members_change(change) if summon_max? #($game_party.summon_members_size == $game_variables[SummonSystem::S_N_ID] || $game_party.members.size == $game_party.max_battle_members) && $game_variables[SummonSystem::S_N_ID] > 0
    $game_actors[actor_id].summon_level_set(level)#$game_actors[1].level)
    $game_actors[actor_id].last_actor_command = 0 #XPスタイルバトルあわせ　召喚と同時にアクターコマンドのカーソル記憶をリセット
    $game_actors[actor_id].on_battle_start # 戦闘開始時の処理
    @actors.push(actor_id) if !@actors.include?(actor_id) && $game_party.members.size < $game_party.max_battle_members
    @summon_able.delete(actor_id) # 召喚可能ユニット配列のアクターIDを削除
    $game_player.refresh
    $game_map.need_refresh = true
    $game_temp.remove_reserve_reset
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの戦闘前セット
  #--------------------------------------------------------------------------
  def summon_actor_set
    #summon_number_check
    @summon_members.each do |actor_id|
      summon_actor(actor_id) if actor_id && members.size < max_battle_members # ※補欠メンバーが入らないように設定
    end
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの事前セッティング
  #--------------------------------------------------------------------------
  def summon_members_add(index, actor)
    id = actor ? actor.id : nil
    @summon_members[index] = id
  end
  #--------------------------------------------------------------------------
  # ○ 召喚可能数を超えたユニットの削除
  #--------------------------------------------------------------------------
  def summon_number_check
    num = [(SummonSystem::SUMMON_SLOT - [summon_number, (max_battle_members - members.size)].min), 0].max
    #num.times {|i| @summon_members[-(i + 1)] = nil }
    num.times {|i| @summon_members[2 - i] = nil }
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの数
  #--------------------------------------------------------------------------
  def summon_members_size
    summon = 0
    all_members.each do |actor|
      summon += 1 if actor.summon_type?
    end
    return summon
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの先頭
  #--------------------------------------------------------------------------
  def summon_members_top
    members.each do |actor|
      return actor if actor.summon_type?
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの入れ替え
  #--------------------------------------------------------------------------
  def summon_members_change(actor)
    return unless actor
    actor.summon_remove if actor.summon_type?
  end
  #--------------------------------------------------------------------------
  # ○ 召喚可能か
  #--------------------------------------------------------------------------
  def summon_enabled
    members.any? {|actor| actor.summon_enabled} && !summon_prohibit
  end
  #--------------------------------------------------------------------------
  # ○ 召喚限界数か
  #--------------------------------------------------------------------------
  def summon_max?
    (summon_members_size == summon_number || members.size == max_battle_members) && summon_number > 0
  end
  #--------------------------------------------------------------------------
  # ○ 召喚可能数の取得
  #--------------------------------------------------------------------------
  def summon_number
    $game_variables[SummonSystem::S_N_ID] + summon_number_plus
  end
  #--------------------------------------------------------------------------
  # ○ 追加召喚可能数の取得
  #--------------------------------------------------------------------------
  def summon_number_plus
    members.inject(0) {|r, actor| r += actor.summon_plus }
  end
  #--------------------------------------------------------------------------
  # ○ 召喚禁止じゃないか
  #--------------------------------------------------------------------------
  def summon_prohibit
    $game_switches[SummonSystem::PROHIBIT]
  end
  #--------------------------------------------------------------------------
  # ○ メンバーの宿屋処理
  #--------------------------------------------------------------------------
  alias summon_inn inn
  def inn
    summon_inn
    @summon_able.each {|id| $game_actors[id].summon_heal(100)}
  end
  #--------------------------------------------------------------------------
  # ● パーティ能力判定　※エイリアス
  #　戦闘中は召喚ユニットの配列を無視
  #--------------------------------------------------------------------------
  alias party_ability_sumonn_plus party_ability
  def party_ability(ability_id)
    if in_battle
      party_ability_sumonn_plus(ability_id)
    else
      party_ability_sumonn_plus(ability_id) || summon_party_ability(ability_id)
    end
  end
  #--------------------------------------------------------------------------
  # ○ パーティ能力判定用召喚ユニット
  #--------------------------------------------------------------------------
  def summon_party_ability(ability_id)
    @summon_members.any? do |actor_id|
      $game_actors[actor_id].party_ability(ability_id) if actor_id
    end
  end
  
  
  
  #############################################################################
  #--------------------------------------------------------------------------
  # ○ スキルリストの取得
  #--------------------------------------------------------------------------
  def learning_summon_skills
    if @lss_init_flag || !@learning_summon_skills
      @learning_summon_skills = learning_summon_skills_set
      @lss_init_flag = false
    end
    @learning_summon_skills
  end
  #--------------------------------------------------------------------------
  # ○ スキルをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def skill_include?(item)
    return false if item == nil
    return item.stype_id == SummonSystem::S_S_ID
  end
  #--------------------------------------------------------------------------
  # ○ スキルリストの作成
  #--------------------------------------------------------------------------
  def learning_summon_skills_set
    $game_actors[1].skills.select {|item| skill_include?(item) }
  end
  #--------------------------------------------------------------------------
  # ○ アクターリストの取得
  #--------------------------------------------------------------------------
  def summon_members_actor
    learning_summon_skills.collect {|item| SummonSystem::summon_obj(item.id)}
  end
  #--------------------------------------------------------------------------
  # ○ 指定アイテムが召喚メンバーの装備品に含まれている数
  #--------------------------------------------------------------------------
  def members_equip_number(item)
    summon_members_actor.inject(0) do |r, actor| 
      r += 1 if actor.equips.include?(item)
      r
    end
  end
  
  #--------------------------------------------------------------------------
  # ○ セットしてるアクターリストの取得
  #--------------------------------------------------------------------------
  def summon_members_set_actor
    summon_members_actor.select {|actor| @summon_members.include?(actor.id) }
  end
  
  
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットのコピー
  #--------------------------------------------------------------------------
  def summon_copy(ary)
    @summon_members = ary
  end
end
=begin
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理　※エイリアス　戦闘開始時に召喚ユニット加入
  #--------------------------------------------------------------------------
  alias summon_add_start start
  def start
    $game_party.summon_actor_set
    summon_add_start
  end
  #--------------------------------------------------------------------------
  # ● 終了処理　※エイリアス　戦闘終了時に召喚ユニット離脱
  #--------------------------------------------------------------------------
  alias summon_remove_terminate terminate
  def terminate
    summon_remove_terminate
    $game_party.summon_reset
    BattleManager.revive_battle_members # 戦闘終了時に戦闘不能者は復活
  end
end
=end
#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ○ 召喚スキル　※スキルのコモンイベントにこれを設定してユニットを召喚
  #--------------------------------------------------------------------------
  def summon
    $game_party.summon_actor_skill($game_variables[SummonSystem::S_V_ID], $game_variables[SummonSystem::S_LV_ID])
  end
  #--------------------------------------------------------------------------
  # ○ 召喚可能数の設定　※主にイベント後に使用
  #--------------------------------------------------------------------------
  def summon_number_set
    #if $game_variables[FAKEREAL::LIBERATE] >= SummonSystem::LIBERATE_SUMMON[1]
    if $game_actors[1].pp >= SummonSystem::LIBERATE_SUMMON[1]
      $game_variables[SummonSystem::S_N_ID] = 3
    elsif $game_actors[1].pp >= SummonSystem::LIBERATE_SUMMON[0]
      $game_variables[SummonSystem::S_N_ID] = 2
    else
      $game_variables[SummonSystem::S_N_ID] = 1
    end
    #$game_variables[SummonSystem::S_N_ID] = $game_variables[FAKEREAL::LIBERATE] / 50 + 1
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの強制装備
  #     ※アクターID指定で召喚ユニットをイベントコマンドからセット。主にOPで使用予定
  #　　 abcがそれぞれスロット１２３に対応。指定無しで強制解除
  #--------------------------------------------------------------------------
  def summon_set_forced(a = nil, b = nil, c = nil)
    $game_party.summon_members_add(0, SummonSystem::unit_search(a))
    $game_party.summon_members_add(1, SummonSystem::unit_search(b))
    $game_party.summon_members_add(2, SummonSystem::unit_search(c))
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの個別強制装備　※nでスロット番号(0,1,2)を指定
  #--------------------------------------------------------------------------
  def summon_set_slot(n, a = nil)
    $game_party.summon_members_add(n, SummonSystem::unit_search(a))
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの存在判定
  #--------------------------------------------------------------------------
  def summon_slot?(n)
    $game_party.summon_members[n]
  end
  #--------------------------------------------------------------------------
  # ○ 召喚セット画面のイベント中呼び出し
  #--------------------------------------------------------------------------
  def summon_call
    return if $game_party.in_battle
    SceneManager.call(Scene_SummonSet)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # 〇 メンバー調整
  #--------------------------------------------------------------------------
  def summon_adjust
    copy = $game_party.summon_members.compact
    case $game_party.members.size
    when 2
      until copy.size < 3
        copy.pop
      end
    when 3
      until copy.size < 2
        copy.pop
      end
    end
    copy.push(nil) until copy.size == 3
    $game_party.summon_copy(copy) unless $game_party.summon_members == copy
  end
end


class RPG::Actor < RPG::BaseItem
  def init_equip_skill
    skill = []
    self.note.each_line do |line|
      case line
      when /\<初期装備スキル:(\d+)\>/
        skill.push($1.to_i)
      end
    end
    return skill
  end
end

class RPG::BaseItem
  def slv_plus
    @slv_plus ||= slv_set
  end
  def slv_set
    self.note =~ /\<スキルLvプラス\:(\d+)\>/ ? $1.to_i : 0
  end
end

#==============================================================================
# ■ Window_SkillList
#------------------------------------------------------------------------------
# 　スキル画面で、使用できるスキルの一覧を表示するウィンドウです。
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● スキルを許可状態で表示するかどうか　※召喚のみ独自判定
  #--------------------------------------------------------------------------
  alias summon_type_enable? enable?
  def enable?(item)
    return false if !item
    if item.stype_id == SummonSystem::S_S_ID
      summon_type_enable?(item) && !$game_party.summon_actor?(item.summon_unit_id) &&
      $game_party.summon_able.include?(item.summon_unit_id) &&
      !$game_party.summon_prohibit && $game_party.in_battle
    else
      summon_type_enable?(item)
    end
  end
end

#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　戦闘の進行を管理するモジュールです。
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # ● 戦闘開始　※再定義　開始時に召喚メッセージを表示
  #--------------------------------------------------------------------------
  def self.battle_start
    $game_system.battle_count += 1
    $game_party.on_battle_start
    $game_troop.on_battle_start
    $game_troop.enemy_names.each do |name|
      $game_message.add(sprintf(Vocab::Emerge, name))
    end
    # ここから
    if $game_party.summon_members.any? && !$game_party.summon_prohibit
      text = ""
      $game_party.all_members.each do |actor|
        text += "、" if !text.empty? && actor.summon_type?
        text += actor.name if actor.summon_type?
        #$game_message.add(sprintf(SummonSystem::Message, actor.name)) if actor.summon_type?
      end
      $game_message.add(sprintf(SummonSystem::Message, text)) if !text.empty?
    end
    # ここまで
    if @preemptive
      $game_message.add(sprintf(Vocab::Preemptive, $game_party.name))
    elsif @surprise
      $game_message.add(sprintf(Vocab::Surprise, $game_party.name))
    end
    wait_for_message
  end
end

#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 終了前処理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    $game_party.summon_number_check
  end
end