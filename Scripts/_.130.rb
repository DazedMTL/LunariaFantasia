module FAKEREAL
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  AUTO_DISABLE = 94   # 作戦設定禁止フラグスイッチ
end

class RPG::UsableItem < RPG::BaseItem
  def omit_skill?
    self.note =~ /\<オート除外\>/
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
  # ● 定数
  #--------------------------------------------------------------------------
  NO_MAGIC     = [:no_magic, :no_skill, :middle_technique]              # 
  NO_TECHNIQUE = [:no_technique, :no_skill, :middle_magic]
  AUTO_MIDDLE  = [:middle_battle, :middle_magic, :middle_technique]
  AUTO_HEAL    = [:heal_priority]
  M_SKILL      = [2, 3, 5] # 術系スキルタイプID
  T_SKILL      = [1, 4, 6] # 技系スキルタイプID
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :tactics_number                     # 選択中の作戦インデックス
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tactics_initialize initialize
  def initialize(actor_id)
    tactics_initialize(actor_id)
    @tactics = tactics_set
    @tactics_number = 0
  end
  #--------------------------------------------------------------------------
  # 〇 作戦の設定
  #--------------------------------------------------------------------------
  def tactics_set
    return tactics_preset(1) if [6,10].include?(@actor_id) #[:none, :middle_battle, :no_skill] if [6,10,11].include?(@actor_id) 
    return tactics_preset(2) if [2,7].include?(@actor_id) #[:none, :heal_priority, :middle_battle, :no_skill] if [2,7].include?(@actor_id) 
    return tactics_preset(3) if [3,8,15].include?(@actor_id) #[:none, :heal_priority, :middle_battle, :no_technique, :middle_magic, :no_magic, :middle_technique, :no_skill] if [3,8,15].include?(@actor_id) 
    tactics_preset #[:none, :middle_battle, :no_technique, :middle_magic, :no_magic, :middle_technique, :no_skill]
  end
  #--------------------------------------------------------------------------
  # 〇 作戦リストの取得
  #--------------------------------------------------------------------------
  def tactics
    @tactics ||= tactics_set
  end
  #--------------------------------------------------------------------------
  # 〇 作戦リストの再設定 ※体験版修正用
  #--------------------------------------------------------------------------
  def tactics_reset
    @tactics = tactics_set
  end
  #--------------------------------------------------------------------------
  # 〇 作戦リストの強制設定
  #--------------------------------------------------------------------------
  def tactics_force_set(type)
    sym = tactics[@tactics_number]
    @tactics = tactics_preset(type)
    num = tactics.index(sym) ? tactics.index(sym) : 0
    @tactics_number = num
  end
  #--------------------------------------------------------------------------
  # 〇 作戦のプリセット
  #--------------------------------------------------------------------------
  def tactics_preset(type = 0)
    case type
    when 1
      [:none, :middle_battle, :no_skill]
    when 2
      [:none, :heal_priority, :middle_battle, :no_skill]
    when 3
      [:none, :heal_priority, :middle_battle, :no_technique, :middle_magic, :no_magic, :middle_technique, :no_skill]
    else
      [:none, :middle_battle, :no_technique, :middle_magic, :no_magic, :middle_technique, :no_skill]
    end
  end
  #--------------------------------------------------------------------------
  # 〇 スキルの作戦行動での使用可能判定
  #--------------------------------------------------------------------------
  def tactics_usable?(skill)
    return !NO_TECHNIQUE.include?(tactics[@tactics_number]) if T_SKILL.include?(skill.stype_id)
    return !NO_MAGIC.include?(tactics[@tactics_number]) if M_SKILL.include?(skill.stype_id)
    return false#true
  end
  #--------------------------------------------------------------------------
  # 〇 現在使用できる作戦戦闘用スキルの配列取得
  #--------------------------------------------------------------------------
  def usable_auto_skills
    skills.select {|skill| usable?(skill) && tactics_usable?(skill) }
  end
  #--------------------------------------------------------------------------
  # 〇 作戦戦闘用の行動候補リストを作成
  #--------------------------------------------------------------------------
  def make_tactics_list
    list = []
    list.push(Game_Action.new(self).set_attack.evaluate)
    usable_auto_skills.each do |skill|
      if skill.damage.recover? || skill.battle_cure?
        list.push(Game_Action.new(self).set_skill(skill.id).evaluate_heal)
      else
        list.push(Game_Action.new(self).set_skill(skill.id).evaluate)
      end
    end
    list
  end
  #--------------------------------------------------------------------------
  # 〇 作戦戦闘用の行動候補リストを作成 rand変数無し
  #--------------------------------------------------------------------------
  def make_tactics_fix_list
    list = []
    #list.push(Game_Action.new(self).set_attack.evaluate_fix)
    usable_auto_skills.each do |skill|
      if skill.damage.recover? || skill.battle_cure?
        list.push(Game_Action.new(self).set_skill(skill.id).evaluate_heal)
      else
        list.push(Game_Action.new(self).set_skill(skill.id).evaluate_fix)
      end
    end
    list
  end
  #--------------------------------------------------------------------------
  # 〇 作戦戦闘時の戦闘行動を作成
  #--------------------------------------------------------------------------
  def make_tactics_battle_actions
    $game_party.qhp_flag_reset
    if AUTO_MIDDLE.include?(tactics[@tactics_number]) #tactics[@tactics_number] == :middle_magic || tactics[@tactics_number] == :middle_technique || tactics[@tactics_number] == :middle_battle
      mtl = make_tactics_fix_list.sort_by {|action| action.value }
      mtl2 = mtl.dup.delete_if {|action| action.value == 0}
      mtl2.delete_if {|action| action.item.damage.recover? } if rand < 0.7
      middle_score = !mtl.empty? ? mtl[-1].value / 2 : 0
      #p @name
      #mtl2.each{|a| p a.value}
      if mtl2.size > 3
        spare = mtl2[rand(mtl2.size - 1)].clone
        mtl2 = mtl2.delete_if {|action| action.value > middle_score }
        mtl2.push(spare) if mtl2.empty?
      elsif mtl2.size < 4
        mtl2.pop if mtl2.size > 1
      end
      mtl2.push(Game_Action.new(self).set_attack.evaluate_fix)
      @actions.size.times do |i|
        @actions[i] = mtl2.max_by {|action| action.value > 0 ? action.value + rand : action.value }
      end
    elsif AUTO_HEAL.include?(tactics[@tactics_number]) && $game_party.need_heal[0] && $game_party.need_heal[0].hp_rate < 0.7 #tactics[@tactics_number] == :heal_priority && $game_party.need_heal[0] && $game_party.need_heal[0].hp_rate < 0.8
      mtl = make_tactics_fix_list.sort_by {|action| action.value }
      mtl2 = mtl.dup.delete_if {|action| action.value == 0}
      mtl3 = mtl2.select {|action| action.item.battle_cure? && !action.item.damage.recover? }
      mtl2.delete_if {|action| !action.item.damage.recover? }
      #mtl2.each{|a| p "#{a.item.name} #{a.value}"} ###
      top = mtl2[-1]
      #mtla = mtl2.select {|action| action.item.for_all? }
      mtl2 = mtl2.select {|action| top.value * 0.9 <= action.value }
      if ($game_party.need_heal.size == 1) || ($game_party.need_heal.size > 1 && !($game_party.need_heal[1].hp_rate < 0.7) && !mtl2.empty?)
        spare = mtl2.clone
        mtl2.delete_if {|action| action.item.for_all? }
        mtl2 = spare if mtl2.empty?
      elsif $game_party.need_heal.size > 1 && !mtl2.empty?
        spare = mtl2.clone
        mtl2.delete_if {|action| action.item.for_one? }
        mtl2 = spare if mtl2.empty?
      end
      mtl2 += mtl3
      #mtl2.each{|a| p a.item.name} ###
      if mtl2.empty?
        @actions.size.times do |i|
          @actions[i] = make_tactics_list.max_by {|action| action.value }
        end
      else
        @actions.size.times do |i|
          @actions[i] = mtl2.max_by {|action| action.value }
          #@actions[i] = mtl2.min_by {|action| (action.item.mp_cost + action.item.tp_cost) }
        end
      end
    elsif AUTO_HEAL.include?(tactics[@tactics_number]) && $game_party.need_cure[0] #tactics[@tactics_number] == :heal_priority && $game_party.need_cure[0]
      mtl = make_tactics_fix_list.sort_by {|action| action.value }
      mtl2 = mtl.dup.delete_if {|action| action.value == 0}
      mtl2.delete_if {|action| !action.item.battle_cure? }
      if mtl2.empty?
        @actions.size.times do |i|
          @actions[i] = make_tactics_list.max_by {|action| action.value }
        end
      else
        @actions.size.times do |i|
          @actions[i] = mtl2.max_by {|action| action.value }
        end
      end
    else
      @actions.size.times do |i|
        @actions[i] = make_tactics_list.max_by {|action| action.value }
      end
    end
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
  # ● スキル／アイテムの評価（ターゲット指定）　※再定義
  #--------------------------------------------------------------------------
  def evaluate_item_with_target(target)
    target.result.clear
    target.make_damage_value(subject, item)
    if item.for_opponent?
      return target.result.hp_damage.to_f / [[target.hp, tactics_hp].min, 1].max
    else
      recovery = [-target.result.hp_damage, target.mhp - target.hp].min
      return recovery.to_f / target.mhp
    end
  end
  #--------------------------------------------------------------------------
  # 〇 スキル／アイテムの評価（ターゲット指定）
  #--------------------------------------------------------------------------
  def tactics_hp
    case subject.level
    when 1..30  ; return 15000
    when 31..50 ; return 20000
    when 51..75 ; return 25000
    when 76..99 ; return 35000
    else        ; return 40000
    end
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
  # 〇 行動の価値評価（自動戦闘用）rand変数なし
  #    @value および @target_index を自動的に設定する。
  #--------------------------------------------------------------------------
  def evaluate_fix
    @value = 0
    evaluate_item if valid?
    self
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの評価
  #--------------------------------------------------------------------------
  alias evaluate_item_random evaluate_item
  def evaluate_item
    evaluate_item_random
    if item.for_random? && !item.random_change
      @value *= (item.number_of_targets.to_f / item_target_candidates.size)
    end
    @value = -1 if item.omit_skill?
  end
  #--------------------------------------------------------------------------
  # 〇 回復スキル／アイテムの評価
  #--------------------------------------------------------------------------
  def evaluate_item_heal
    item_target_candidates.each do |target|
      value = evaluate_item_with_target(target)
      if item.for_all?
        @value = value if value > @value
      elsif value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # 〇 回復行動の価値評価（自動戦闘用）
  #    @value および @target_index を自動的に設定する。
  #--------------------------------------------------------------------------
  def evaluate_heal
    @value = 0
    evaluate_item_heal if valid?
    self
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの評価（ターゲット指定）
  #--------------------------------------------------------------------------
  alias cure_evaluate_item_with_target evaluate_item_with_target
  def evaluate_item_with_target(target)
    if item && item.battle_cure? #&& !item.damage.recover?
      target.result.clear
      target.make_damage_value(subject, item)
      v = 0
      if target.actor? && target.need_cure?
        v = target.bad_state_select.inject(v) do |r, id|
          r += (rand(QuickHealActor::BBS_PRIORITY[id]) + 1) * 0.01 if QuickHealActor::BATTLE_CURE[id].include?(item.id)
          r
        end
        #v = v + rand - rand if v > 0
      end
      if item.damage.recover?
        recovery = [-target.result.hp_damage, target.mhp - target.hp].min
        v += recovery.to_f / target.mhp
      end
      return v
    else
      cure_evaluate_item_with_target(target)
    end
  end
=begin
  #--------------------------------------------------------------------------
  # ● 行動の価値評価（自動戦闘用）
  #    @value および @target_index を自動的に設定する。
  #--------------------------------------------------------------------------
  def evaluate
    @value = 0
    evaluate_item if valid?
    @value += (opponents_unit.avr_hp >= 50000 ? rand * 0.1 : rand) if @value > 0
    p "#{item.name} #{@value}"
    self
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの評価
  #--------------------------------------------------------------------------
  def evaluate_item
    item_target_candidates.each do |target|
      value = evaluate_item_with_target(target)
      if item.for_all?
        @value += value
      elsif value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用対象候補を取得
  #--------------------------------------------------------------------------
  def item_target_candidates
    if item.for_opponent?
      opponents_unit.alive_members
    elsif item.for_user?
      [subject]
    elsif item.for_dead_friend?
      friends_unit.dead_members
    else
      friends_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの評価（ターゲット指定）
  #--------------------------------------------------------------------------
  def evaluate_item_with_target(target)
    target.result.clear
    target.make_damage_value(subject, item)
    if item.for_opponent?
      return target.result.hp_damage.to_f / [target.hp, 1].max
    else
      recovery = [-target.result.hp_damage, target.mhp - target.hp].min
      return recovery.to_f / target.mhp
    end
  end
=end
end

#==============================================================================
# ■ Game_Unit
#------------------------------------------------------------------------------
# 　ユニットを扱うクラスです。このクラスは Game_Party クラスと Game_Troop クラ
# スのスーパークラスとして使用されます。
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # 〇 生存者の平均HPの平均値を計算
  #--------------------------------------------------------------------------
  def avr_hp
    return 1 if alive_members.size == 0
    hp_sum / alive_members.size
  end
  #--------------------------------------------------------------------------
  # 〇 生存者のHPの合計を計算
  #--------------------------------------------------------------------------
  def hp_sum
    alive_members.inject(0) {|r, member| r + member.hp }
  end
end

#以下　PTオート・リピート(tomoakyさん)の再定義
#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle
  #--------------------------------------------------------------------------
  # ○ コマンド［オート］　※再定義
  #--------------------------------------------------------------------------
  def command_auto
    $game_party.members.each do |actor|
      actor.make_tactics_battle_actions if actor.inputable?
    end
    @party_command_window.deactivate
    turn_start
  end
end
#再定義ここまで

#==============================================================================
# □ Window_TacticsActor
#------------------------------------------------------------------------------
# 　メニュー画面で表示するコマンドウィンドウです。
#==============================================================================

class Window_TacticsActor < Window_Command
  #--------------------------------------------------------------------------
  # 〇 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :tactics_window
  #--------------------------------------------------------------------------
  # 〇 オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # 〇 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    [4, [item_max, 16].min].max
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_main_members
    add_servant_members if !SceneManager.scene_is?(Scene_Battle)
  end
  #--------------------------------------------------------------------------
  # 〇 主要コマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_main_members
    $game_party.battle_members.each {|member| add_command(member.name,   :ok, true, member) }
  end
  #--------------------------------------------------------------------------
  # 〇 主要コマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_servant_members
    servant_list.each {|servant| add_command(servant.name,   :ok, true, servant) }
  end
  #--------------------------------------------------------------------------
  # ○ アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false unless item.is_a?(RPG::Skill)
    return item.stype_id == SummonSystem::S_S_ID
  end
  #--------------------------------------------------------------------------
  # ○ アイテムリストの作成
  #--------------------------------------------------------------------------
  def servant_list
    $game_actors[1].skills.select {|item| include?(item) }.collect {|skill| SummonSystem::summon_obj(skill.id)}
  end
  #--------------------------------------------------------------------------
  # 〇 スキルウィンドウの設定
  #--------------------------------------------------------------------------
  def tactics_window=(tactics_window)
    @tactics_window = tactics_window
    update
  end
  #--------------------------------------------------------------------------
  # 〇 フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @tactics_window.actor = current_ext if @tactics_window
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    #if SceneManager.scene_is?(Scene_Battle)
      #change_color(normal_color, command_enabled?(index))
    #elsif $game_party.summon_members.include?(@list[index][:ext].id) || $game_party.members.include?(@list[index][:ext])
      #change_color(important_color, command_enabled?(index))
    #else
      #change_color(normal_color, command_enabled?(index))
    #end
    change_color(battle_member?(index) ? important_color : normal_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def battle_member?(index)
    return false if SceneManager.scene_is?(Scene_Battle)
    return $game_party.summon_members.include?(@list[index][:ext].id) || $game_party.members.include?(@list[index][:ext])
  end
end

#==============================================================================
# ■ Window_Tactics
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_Tactics < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
    deactivate
    @actor = nil
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    select_last
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def tactics_number_set(number)
    @actor.tactics_number = number
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 240
  end
  #--------------------------------------------------------------------------
  # ● 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return 8
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    add_tactics_command
  end
  #--------------------------------------------------------------------------
  # 〇 作戦コマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_tactics_command
    @actor.tactics.each {|ta| add_command(tactics_name(ta), :ok) }
  end
  #--------------------------------------------------------------------------
  # 〇 作戦コマンドをリストに追加
  #--------------------------------------------------------------------------
  def tactics_name(ta)
    case ta
    when :none ; "None"
    when :heal_priority ; "Prioritize healing"
    when :middle_battle ; "Fight moderately"
    when :middle_technique ; "Fight with moderate techniques"
    when :middle_magic ; "Fight with moderate magic"
    when :no_technique ; "Fight with magic"
    when :no_magic ; "Fight with techniques"
    when :no_skill ; "Do not use techniques or magic"
    else ; ""
    end
  end
  #--------------------------------------------------------------------------
  # 〇 リフレッシュ
  #--------------------------------------------------------------------------
  #def refresh
    #clear_command_list
    #make_command_list
  #end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    select(@actor.tactics_number) if @actor
  end
end

#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　メニュー画面の処理を行うクラスです。
#==============================================================================

class Scene_Tactics < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    @help_window.set_text("You can set a simple strategy for auto-battle. If \"None\" is selected, \nyou will fight without any restrictions on the use of skills or spells.\e}\e}\n※In auto mode,\eHP recovery and status treatment actions will be taken, but no other support actions will be performed\e{\e{")
    create_command_window
    create_tactics_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    y = @help_window.height
    x = Graphics.width / 2 - (160 + 240) / 2
    @command_window = Window_TacticsActor.new(x, y)
    @command_window.set_handler(:ok,      method(:command_tactics))
    @command_window.set_handler(:cancel,    method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● タクティクスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_tactics_window
    y = @command_window.y
    x = @command_window.x + @command_window.width
    @tactics_window = Window_Tactics.new(x, y)
    @tactics_window.set_handler(:ok,      method(:on_tactics_ok))
    @tactics_window.set_handler(:cancel,    method(:on_tactics_cancel))
    @command_window.tactics_window = @tactics_window
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［作戦］
  #--------------------------------------------------------------------------
  def command_tactics
    @tactics_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 作戦［決定］
  #--------------------------------------------------------------------------
  def on_tactics_ok
    @tactics_window.tactics_number_set(@tactics_window.index)
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 難易度［キャンセル］
  #--------------------------------------------------------------------------
  def on_tactics_cancel
    @tactics_window.select_last
    @tactics_window.deactivate
    @command_window.activate
  end
end

#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　メニュー画面で表示するコマンドウィンドウです。
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● 独自コマンドの追加用　※エイリアス
  #--------------------------------------------------------------------------
  alias tactics_add_original_commands add_original_commands
  def add_original_commands
    tactics_add_original_commands
    add_command("Tactics",  :tactics, !$game_switches[FAKEREAL::AUTO_DISABLE])
  end
end

#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　メニュー画面の処理を行うクラスです。
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias tactics_create_command_window create_command_window
  def create_command_window
    tactics_create_command_window
    @command_window.set_handler(:tactics,     method(:on_tactics))
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def on_tactics
    SceneManager.call(Scene_Tactics)
  end
end

#==============================================================================
# ■ Window_PartyCommand
#==============================================================================
class Window_PartyCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  alias tactics_make_command_list make_command_list
  def make_command_list
    tactics_make_command_list
    add_command("Tactics",   :tactics)
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成
  #--------------------------------------------------------------------------
  alias tactics_create_all_windows create_all_windows
  def create_all_windows
    tactics_create_all_windows
    create_tactics_actor_window
    create_tactics_window
  end
  #--------------------------------------------------------------------------
  # ● パーティコマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias tactics_create_party_command_window create_party_command_window
  def create_party_command_window
    tactics_create_party_command_window
    @party_command_window.set_handler(:tactics,   method(:command_tactics))
  end
  #--------------------------------------------------------------------------
  # 〇 タクティクスアクターウィンドウの作成
  #--------------------------------------------------------------------------
  def create_tactics_actor_window
    x = Graphics.width / 2 - (160 + 240) / 2
    y = @party_command_window.height
    @tactics_actor_window = Window_TacticsActor.new(x, y)
    @tactics_actor_window.set_handler(:ok,  method(:tactics_select))
    @tactics_actor_window.set_handler(:cancel, method(:return_pc))
    @tactics_actor_window.deactivate
    @tactics_actor_window.hide
  end
  #--------------------------------------------------------------------------
  # 〇 タクティクスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_tactics_window
    y = @tactics_actor_window.y
    x = @tactics_actor_window.x + @tactics_actor_window.width
    @tactics_window = Window_Tactics.new(x, y)
    @tactics_window.set_handler(:ok,  method(:on_tactics_ok))
    @tactics_window.set_handler(:cancel, method(:on_tactics_cancel))
    @tactics_window.hide
    @tactics_actor_window.tactics_window = @tactics_window
  end
  #--------------------------------------------------------------------------
  # 〇 作戦選択開始
  #--------------------------------------------------------------------------
  def command_tactics
    @tactics_window.show
    @tactics_actor_window.refresh
    @tactics_actor_window.show.activate
    @tactics_actor_window.select(0)
  end
  #--------------------------------------------------------------------------
  # 〇 作戦変更キャラ選択
  #--------------------------------------------------------------------------
  def tactics_select
    @tactics_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 パーティコマンド選択へ戻る
  #--------------------------------------------------------------------------
  def return_pc
    @tactics_window.hide
    @tactics_actor_window.hide
    @tactics_actor_window.unselect
    @party_command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 作戦［決定］
  #--------------------------------------------------------------------------
  def on_tactics_ok
    @tactics_window.tactics_number_set(@tactics_window.index)
    @tactics_actor_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 作戦［キャンセル］
  #--------------------------------------------------------------------------
  def on_tactics_cancel
    @tactics_window.select_last
    @tactics_window.deactivate
    @tactics_actor_window.activate
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
  # 〇 作戦リストの強制設定
  #--------------------------------------------------------------------------
  def tactics_force_set(actor_id, type)
    $game_actors[actor_id].tactics_force_set(type)
  end
end