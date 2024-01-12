module QuickHealActor
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  BAD_STATES = [31, 2]    # 戦闘終了後も続くバッドステータス 治療優先順
  CURE = Hash[
  #ステートID => 治療可能スキル配列
    2 =>  [31, 32, 255, 257],
    31 => [32, 255, 257]
  ]
  ANOTHER_CURE = [32, 255, 257] # 複数の状態異常を直せるスキル
  
  BATTLE_BAD_STATES = [7, 4, 26, 31, 5, 6, 2, 3]    # 戦闘バッドステータス 治療優先順
  BBS_PRIORITY = Hash[
    2 => 20,
    3 => 20,
    4 => 45,
    5 => 30,
    6 => 30,
    7 => 50,
    26 => 40,
    31 => 30
  ]
  BATTLE_CURE = Hash[
  #ステートID => 治療可能スキル配列
    2 =>  [31, 32, 168, 174, 255, 257],
    3 =>  [32, 168, 174, 255, 257],
    4 =>  [32, 168, 174, 255, 257],
    5 =>  [32, 168, 174, 255, 257],
    6 =>  [32, 168, 174, 255, 257],
    7 =>  [31, 32, 168, 174, 255, 257],
    26 => [32, 168, 174, 255, 257],
    31 => [32, 255, 168, 174, 257]
  ]
  BATTLE_ANOTHER_CURE = [32, 168, 174, 255, 257] # 複数の状態異常を直せる戦闘スキル
  MAGIC_HEAL = 0.001
  #--------------------------------------------------------------------------
  # ○ 使用可能回復スキルのリスト
  #--------------------------------------------------------------------------
  def heal_skills
    @heal_skills ||= heal_skills_set
  end
  #--------------------------------------------------------------------------
  # ○ 使用可能回復スキルの設定
  #--------------------------------------------------------------------------
  def heal_skills_set
    list = []
    usable_skills.each do |skill|
      list.push(skill) if skill.damage.recover? && !skill.for_dead_friend? 
    end
    list
  end
  #--------------------------------------------------------------------------
  # ○ 使用可能回復スキルの中に全体回復があるか？ ※未使用
  #--------------------------------------------------------------------------
  def heal_all?
    heal_skills.any?{|skill| skill.for_all?}
  end
  #--------------------------------------------------------------------------
  # ○ 使用可能治療スキルのリスト
  #--------------------------------------------------------------------------
  def cure_skills
    @cure_skills = cure_skills_set
  end
  #--------------------------------------------------------------------------
  # ○ 使用可能治療スキルの設定
  #--------------------------------------------------------------------------
  def cure_skills_set
    list = []
    usable_skills.each do |skill|
      list.push(skill) if skill.cure?
    end
    list
  end
  #--------------------------------------------------------------------------
  # ○ 使用可能治療スキルの中に全体治療があるか？ ※未使用
  #--------------------------------------------------------------------------
  def cure_all?
    cure_skills.any? {|skill| skill.for_all? }
  end
  #--------------------------------------------------------------------------
  # ○ 回復スキルを持っているか？
  #--------------------------------------------------------------------------
  def healer?
    !heal_skills.empty?
  end
  #--------------------------------------------------------------------------
  # ○ 回復する必要があるか？
  #--------------------------------------------------------------------------
  def need_heal?
    @hp < mhp
  end
  #--------------------------------------------------------------------------
  # ○ ステータス異常を治す必要があるか？
  #--------------------------------------------------------------------------
  def need_cure?
    if $game_party.in_battle
      BATTLE_BAD_STATES.any? {|id| state?(id) }
    else
      BAD_STATES.any? {|id| state?(id) }
    end
  end
  #--------------------------------------------------------------------------
  # ○ ステータス異常にいくつかかっているか
  #--------------------------------------------------------------------------
  def bad_state_number
    if $game_party.in_battle
      BATTLE_BAD_STATES.inject(0) do |r, id|
        r += 1 if state?(id)
        r
      end
    else
      BAD_STATES.inject(0) do |r, id|
        r += 1 if state?(id)
        r
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ ステータス異常のID配列
  #--------------------------------------------------------------------------
  def bad_state_select
    BATTLE_BAD_STATES.inject([]) do |r, id|
      r.push(id) if state?(id)
      r
    end
  end
  #--------------------------------------------------------------------------
  # ○ 回復数値
  #--------------------------------------------------------------------------
  def heal_value(skill)
    (skill.base + skill.plus * (skill_lv(skill.id) - 1)) * (1.0 + mdf * MAGIC_HEAL) * atk_elements_rate(50)
  end
  #--------------------------------------------------------------------------
  # ○ コストパフォーマンスの高いスキルの選定基準
  #--------------------------------------------------------------------------
  def heal_conditions_score(skill)
    @conditions_score ||= {}
    @conditions_score[skill.id] = heal_conditions_score_set(skill) if !@conditions_score[skill.id]
    return @conditions_score[skill.id]
  end
  #--------------------------------------------------------------------------
  # ○ コストパフォーマンスの高いスキルの選定基準
  #--------------------------------------------------------------------------
  def heal_conditions_score_set(skill)
    #second = heal_skills.select {|s| heal_value(skill) > heal_value(s) }.max {|a, b| heal_value(a) <=> heal_value(b) }
    min_skills = heal_skills.select {|s| heal_value(skill) > heal_value(s) }
    min_skills.push(nil)
    if skill.for_one?
      score = real_score(skill, min_skills)
    else
      score = max_score(skill, min_skills)
    end
    score += 10000 if score > @mp #もしMP不足で全快出来ない場合は10000を足してスコアを調整
    return score
  end
  #--------------------------------------------------------------------------
  # ○ 回復スキルの選定
  #--------------------------------------------------------------------------
  def fit_heal_skill
    @fit_heal_skill ||= fit_heal_skill_set
  end
  #--------------------------------------------------------------------------
  # ○ 回復スキルの選定
  #--------------------------------------------------------------------------
  def fit_heal_skill_set
    #heal_skills.min {|a,b| heal_conditions_score(a) <=> heal_conditions_score(b) }
    heal_skills.sort_by {|skill| [heal_conditions_score(skill), -heal_value(skill)] }[0]
  end
  #--------------------------------------------------------------------------
  # ○ ダメージ値
  #--------------------------------------------------------------------------
  def life_damage
    mhp - @hp
  end
  #--------------------------------------------------------------------------
  # ○ ダメージを回復しきるまでにスキルを何回使用し、MPをどれだけ消費するか
  #--------------------------------------------------------------------------
  def skill_time(skill, damage, second)
    use = false
    cost = 0
    cost_rate = 1
    cost_rate *= 0.1 if $game_variables[Option::EASY_HEAL] >= 2 && (heal_value(skill) >= 9999 || (skill.for_all? && $game_party.damage_array.size >= 2)) # 回数緩和処置2
    cost_rate *= ($game_party.heal_count + 1) if $game_variables[Option::EASY_HEAL] >= 2 && skill.for_all? # 回数緩和処置2
    #cost_rate *= 0.5 if $game_variables[Option::EASY_HEAL] >= 2 && heal_value(skill) >= 9999 # 回数緩和処置2
    #cost_rate = cost_rate / $game_party.damage_array.size * ($game_party.heal_count + 1) if $game_variables[Option::EASY_HEAL] >= 2 && (skill.for_all? && $game_party.damage_array.size >= 2) # 回数緩和処置2
    if second && heal_value(second) > damage
      cost += skill_mp_cost(second)
    elsif heal_value(skill) > damage
      cost += skill_mp_cost(skill)
      cost *= cost_rate
      use = true
    elsif second && (heal_value(second) + heal_value(skill)) > damage
      cost += skill_mp_cost(second) + (skill_mp_cost(skill) * cost_rate)
      use = true
    else
      time = damage.to_i / heal_value(skill).to_i
      time += 1 if damage.to_i % heal_value(skill).to_i != 0
      cost += time * skill_mp_cost(skill)
      cost += 100 / ($game_party.heal_count + 1) if $game_variables[Option::EASY_HEAL] == 1 # 回数緩和処置
      cost += 1000 if time >= 5 && $game_variables[Option::EASY_HEAL] >= 1 # 回数緩和処置
      cost *= cost_rate
      use = true
    end
    return [cost, use]
  end
  #--------------------------------------------------------------------------
  # ○ 平均ダメージを回復する際のMPコスト
  #--------------------------------------------------------------------------
  def average_score(skill, min_skills = [])
    skill_time(skill, $game_party.damage_average, min_skills[0])[0]
  end
  #--------------------------------------------------------------------------
  # ○ 総和ダメージを回復する際のMPコスト
  #--------------------------------------------------------------------------
  def sum_score(skill, min_skills = [])
    skill_time(skill, $game_party.sum_damage, min_skills[0])[0]
  end
  #--------------------------------------------------------------------------
  # ○ 実際のダメージを回復する際のMPコスト
  #--------------------------------------------------------------------------
  def real_score(skill, min_skills = [])
    real_cost = []
    min_skills.each do |second|
      cost = 0
      cost_ary = []
      use = []
      $game_party.damage_array.each do |damage|
        cost_ary.push(skill_time(skill, damage, second))
      end
      cost_ary.each do |num|
        cost += num[0]
        use.push(num[1])
      end
      real_cost.push(cost) if use.any?
    end
    cost = real_cost.empty? ? skill_mp_cost(skill) : real_cost.min #skill_mp_cost(skill) if cost < skill_mp_cost(skill)
    return cost
  end
  #--------------------------------------------------------------------------
  # ○ マックスダメージを回復する際のMPコスト
  #--------------------------------------------------------------------------
  def max_score(skill, min_skills = [])
    real_cost = []
    min_skills.each do |second|
      ary = skill_time(skill, $game_party.max_damage, second)
      real_cost.push(ary[0]) if ary[1]
      #cost = ary[0] #* skill_mp_cost(skill)
      #cost = skill_mp_cost(skill) if cost < skill_mp_cost(skill)
      #cost += 1 if !ary[1]
    end
    cost = real_cost.empty? ? skill_mp_cost(skill) : real_cost.min
    return cost
  end
  #--------------------------------------------------------------------------
  # ○ 治療スキルの選定基準
  #--------------------------------------------------------------------------
  def cure_conditions_score(skill, state_id)
    @conditions_score ||= {}
    @conditions_score["#{skill.id},#{state_id}"] = cure_conditions_score_set(skill, state_id) if !@conditions_score["#{skill.id},#{state_id}"]
    return @conditions_score["#{skill.id},#{state_id}"]
  end
  #--------------------------------------------------------------------------
  # ○ 治療スキルの選定基準
  #--------------------------------------------------------------------------
  def cure_conditions_score_set(skill, state_id)
=begin
    b_state = []
    b_skill = {}
    b_skill_cost = []
    one = skill.for_one?
    another = ANOTHER_CURE.include?(skill.id)
    if another
      b_state = BAD_STATES - [state_id]
      b_state.each do |id|
        second = state_cure_skill_temp(id, skill)
        if second
          next if second.for_all?
          b_skill[id] = [second, $game_party.state_actor(id).size - $game_party.multi_state] 
        end
      end
      b_skill.each do |id, ary|
        b_skill_cost.push(skill_mp_cost(ary[0]) * ary[1]) if ary[0] && ary[1] > 0
      end
    end
    if one
      cure_time = (another && b_skill_cost.empty?) ? $game_party.need_cure.size : $game_party.state_actor(state_id).size
    else
      cure_time = 1
    end
    b_skill_cost.push(0) if b_skill_cost.empty?
    if !one && another
      total_cost = skill_mp_cost(skill) * cure_time
    else
      total_cost = skill_mp_cost(skill) * cure_time + b_skill_cost.min
    end
    total_cost += 1000 if one && ($game_party.need_cure.size > 1) && (@mp < total_cost)
    return total_cost
=end
    one = skill.for_one?
    size = $game_party.state_actor(state_id).size
    if one
      cure_time = size #another ? $game_party.need_cure.size : $game_party.state_actor(state_id).size
    else
      cure_time = 1
    end
    total_cost = skill_mp_cost(skill) * cure_time
    total_cost += 1000 if one && (size > 1) && (@mp < total_cost)
    return total_cost
  end
  #--------------------------------------------------------------------------
  # ○ 特定の治療スキル
  #--------------------------------------------------------------------------
  def state_cure_skill(state_id)
    @state_cure_skill ||= {}
    @state_cure_skill[state_id] = state_cure_skill_set(state_id) if !@state_cure_skill[state_id]
    return @state_cure_skill[state_id]
  end
  #--------------------------------------------------------------------------
  # ○ 特定の治療スキルの設定
  #--------------------------------------------------------------------------
  def state_cure_skill_set(state_id)
    c = state_cure_skills(state_id)
    c.min{|a,b| cure_conditions_score(a, state_id) <=> cure_conditions_score(b, state_id)}
  end
  #--------------------------------------------------------------------------
  # ○ 特定の治療スキル　内部用
  #--------------------------------------------------------------------------
  def state_cure_skill_temp(state_id, skill)
    c = state_cure_skills(state_id)
    c.delete(skill)
    c.min{|a,b| skill_mp_cost(a) <=> skill_mp_cost(b) }
  end
  #--------------------------------------------------------------------------
  # ○ 特定治療の使用可能スキルをもっているか？
  #--------------------------------------------------------------------------
  def cure_has?(state_id)
    !state_cure_skills(state_id).empty?
  end
  #--------------------------------------------------------------------------
  # ○ 特定の治療スキルの配列
  #--------------------------------------------------------------------------
  def state_cure_skills(state_id)
    cure_skills.select{|skill| CURE[state_id].include?(skill.id)}
  end
  #--------------------------------------------------------------------------
  # ○ 選定基準
  #--------------------------------------------------------------------------
  def priority_score(skill, state_id = nil)
    #p @conditions_score
    return cure_conditions_score(skill, state_id) if state_id
    return heal_conditions_score(skill)
  end
  #--------------------------------------------------------------------------
  # ○ 現在のバッドステートをアイコン番号の配列で取得
  #--------------------------------------------------------------------------
  def bad_state_icons
    icons = states.select {|state| BAD_STATES.include?(state.id) }.collect {|state| state.icon_index }
    icons.delete(0)
    icons
  end
  #--------------------------------------------------------------------------
  # ○ クイックヒール関連の変数を初期化
  #--------------------------------------------------------------------------
  def quick_heal_flag_reset
    @heal_skills = nil
    @cure_skills = nil
    @fit_heal_skill = nil
    @conditions_score = {}
    @state_cure_skill = {}
  end
  #--------------------------------------------------------------------------
  # ○ スキルの使用回数リセット
  #--------------------------------------------------------------------------
  def heal_count_reset
    @heal_count = {}
  end
  #--------------------------------------------------------------------------
  # ○ スキルの使用回数を加算
  #--------------------------------------------------------------------------
  def heal_count_plus(skill, count = 1)
    @heal_count[skill.id] = 0 if !@heal_count[skill.id]
    @heal_count[skill.id] += count
  end
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :heal_count                     # 
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  include QuickHealActor
end

module QuickHealParty
  #--------------------------------------------------------------------------
  # ○ 要回復者の配列取得
  #--------------------------------------------------------------------------
  def need_heal
    @need_heal ||= need_heal_set
  end
  #--------------------------------------------------------------------------
  # ○ 要回復者のセット　ダメージ値の大きい順
  #--------------------------------------------------------------------------
  def need_heal_set
    (members.select {|actor| actor.need_heal? }).sort {|a, b| b.life_damage - a.life_damage}
  end
  #--------------------------------------------------------------------------
  # ○ ダメージの最高値
  #--------------------------------------------------------------------------
  def max_damage
    need_heal[0] ? need_heal[0].life_damage : 0
  end
  #--------------------------------------------------------------------------
  # ○ ダメージの総和
  #--------------------------------------------------------------------------
  def sum_damage
    need_heal.inject(0) {|r, a| r += a.life_damage }
  end
  #--------------------------------------------------------------------------
  # ○ ダメージの平均値
  #--------------------------------------------------------------------------
  def damage_average
    sum_damage / need_heal.size rescue 0
  end
  #--------------------------------------------------------------------------
  # ○ ダメージの配列
  #--------------------------------------------------------------------------
  def damage_array
    need_heal.inject([]) {|r, a| r.push(a.life_damage) }
  end
  #--------------------------------------------------------------------------
  # ○ 要治療者の配列取得
  #--------------------------------------------------------------------------
  def need_cure
    @need_cure ||= need_cure_set
  end
  #--------------------------------------------------------------------------
  # ○ 要治療者の配列取得
  #--------------------------------------------------------------------------
  def need_cure_set
    members.select {|actor| actor.need_cure? }
  end
  #--------------------------------------------------------------------------
  # ○ 特定状態異常アクターの選別
  #--------------------------------------------------------------------------
  def state_actor(state_id)
    need_cure.select{|actor| actor.state?(state_id)}
  end
  #--------------------------------------------------------------------------
  # ○ 複数のバッドステータスにかかっている人数
  #--------------------------------------------------------------------------
  def multi_state
    need_cure.inject(0) do |r, actor|
      r += 1 if actor.bad_state_number >= 2
      r
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def healer
    @healer ||= healer_set
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def healer_set
    list = []
    members.each do |actor|
      list.push(actor) if actor.healer?
    end
    list.sort_by! {|actor| [actor.priority_score(actor.fit_heal_skill), -actor.mp,]}
    list
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def curer(state_id)
    @curer ||= {}
    @curer[state_id] = curer_set(state_id) if !@curer[state_id]
    return @curer[state_id]
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def curer_set(state_id)
    list = []
    members.each do |actor|
      list.push(actor) if actor.cure_has?(state_id)
    end
    list.sort_by!{|actor| [actor.priority_score(actor.state_cure_skill(state_id), state_id), -actor.mp,]}
    list
  end
  #--------------------------------------------------------------------------
  # ○ クイックヒール関連のパーティ変数を初期化
  #--------------------------------------------------------------------------
  def qhp_flag_reset
    #p "PFリセット"
    @need_heal = nil
    @need_cure = nil
    @healer = nil
    @curer = {}
  end
  #--------------------------------------------------------------------------
  # ○ クイックヒール関連のパーティ変数を初期化
  #--------------------------------------------------------------------------
  def qhp_flag_reset_map
    #p "PFリセット"
    @need_heal = nil
    @need_cure = nil
    @healer = nil
    @curer = {}
    members.each {|actor| actor.quick_heal_flag_reset}
    heal_count_reset
  end
  #--------------------------------------------------------------------------
  # ○ スキルの使用回数リセット
  #--------------------------------------------------------------------------
  def heal_count_reset
    @heal_count = 0
  end
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor   :heal_count                     # 
end

#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  include QuickHealParty
end

module HealCheck
  #--------------------------------------------------------------------------
  # ○ 回復スキル所持者のリスト
  #--------------------------------------------------------------------------
  def healer_list
    $game_party.healer
  end
  #--------------------------------------------------------------------------
  # ○ 治療スキル所持者のリスト
  #--------------------------------------------------------------------------
  def curer_list(state_id)
    $game_party.curer(state_id)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def need_recover?
    need_healing? || need_curing?
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def cure_check(state_ary)
    state_ary.any?{|state_id| !curer_list(state_id).empty? && !$game_party.state_actor(state_id).empty?}
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def need_healing?
    (!healer_list.empty? && !$game_party.need_heal.empty?)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def need_curing?
    (cure_check(QuickHealActor::BAD_STATES))
  end
end

module QuickHeal
  #--------------------------------------------------------------------------
  # ○ 回復スキル
  #--------------------------------------------------------------------------
  def item
    @item
  end
  #--------------------------------------------------------------------------
  # ○ 回復スキル使用者
  #--------------------------------------------------------------------------
  def user
    @user
  end
  #--------------------------------------------------------------------------
  # ○ 回復対象となるアクターを配列で取得
  #--------------------------------------------------------------------------
  def item_target_actors
    @targets.compact
  end
  #--------------------------------------------------------------------------
  # ○ アイテムの効果が有効かを判定
  #--------------------------------------------------------------------------
  def item_effects_valid?
    item_target_actors.any? do |target|
      target.item_test(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムをアクターに対して使用
  #--------------------------------------------------------------------------
  def use_item_to_actors
    item_target_actors.each do |target|
      item.repeats.times { target.item_apply(user, item) }
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムの使用
  #--------------------------------------------------------------------------
  def use_item
    user.use_item(item)
    use_item_to_actors
    user.heal_count_plus(item)
    $game_party.members.each {|actor| actor.quick_heal_flag_reset }
    $game_party.heal_count += 1
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def quick_heal
    return if $game_party.need_heal.empty?
    flag_heal_set
    use_item if user && item
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def flag_init
    @item = nil
    @user = nil
    @targets = []
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def flag_heal_set
    flag_init
    @user = healer_list[0]
    return if !@user
    @item = @user.fit_heal_skill
    @targets = @item.for_all? ? $game_party.need_heal : [$game_party.need_heal[0]]
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def quick_cure
    QuickHealActor::BAD_STATES.each do |state_id|
      next if $game_party.state_actor(state_id).empty?
      flag_cure_set(state_id)
      use_item if user && item
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def flag_cure_set(state_id)
    flag_init
    @user = curer_list(state_id)[0]
    return if !@user
    @item = @user.state_cure_skill(state_id)
    @targets = @item.for_all? ? $game_party.need_cure : [$game_party.state_actor(state_id)[0]]
  end
end

class RPG::Skill < RPG::UsableItem
  def cure?
    self.note =~ /\<QH対象\>/
  end
  def battle_cure?
    self.note =~ /\<治療スキル\>/
  end
end

#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================

class Scene_Map < Scene_Base
  include HealCheck
  #--------------------------------------------------------------------------
  # ● シーン遷移に関連する更新
  #--------------------------------------------------------------------------
  alias quick_heal_update_scene update_scene
  def update_scene
    quick_heal_update_scene
    update_call_heal unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # ○ 特定ボタンによるクイックヒール判定
  #--------------------------------------------------------------------------
  def update_call_heal
    return if call_disabled
    call_heal if Input.trigger?(:L)
  end
  #--------------------------------------------------------------------------
  # ○ ショートカット呼び出し禁止条件
  #  移動不可能・イベント実行中・方向ボタン押されてる・スリップ中・メニュー呼び出し禁止
  #　上記いずれかの場合はショートカット呼び出し禁止
  #--------------------------------------------------------------------------
  def call_disabled
    !$game_player.movable? || $game_map.interpreter.running? || Input.dir4 != 0 || $game_player.slip_straight || $game_system.menu_disabled
  end
  #--------------------------------------------------------------------------
  # ○ クイックヒールの実行
  #--------------------------------------------------------------------------
  def call_heal
    $game_party.qhp_flag_reset_map
    if need_recover?
      Sound.play_recovery
      SceneManager.call(Scene_Healing)
    else
      Sound.play_buzzer
    end
  end
end

#==============================================================================
# □ Window_Healing
#------------------------------------------------------------------------------
# 　回復中情報を表示するウィンドウです。
#==============================================================================

class Window_Healing < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    x = Graphics.width / 2 - window_width / 2
    y = Graphics.height / 2 - window_height #/ 2
    super(x, y, window_width, window_height)
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 450
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ○ 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    item_max + 1
  end
  #--------------------------------------------------------------------------
  # ○ 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    $game_party.members.size #1
  end
  #--------------------------------------------------------------------------
  # ○ ステータスの描画
  #--------------------------------------------------------------------------
  def draw_actor_quick_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_hp(actor, x + 112, y)# + line_height * 1)
    draw_actor_mp(actor, x + 240, y)# + line_height * 2)
    draw_actor_icons(actor, x + 368, y, QuickHealActor::BAD_STATES.size * 24)# + line_height * 2)
  end
  #--------------------------------------------------------------------------
  # ○ ステートおよび強化／弱体のアイコンを描画　※オーバーライド
  #--------------------------------------------------------------------------
  def draw_actor_icons(actor, x, y, width = 96)
    icons = actor.bad_state_icons[0, width / 24]
    icons.each_with_index {|n, i| draw_icon(n, x + 24 * i, y) }
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh(finish = false)
    contents.clear
    text = finish ? "決定orキャンセルで終了" : "クイックヒール中"
    @finish = finish
    draw_text(0, 0, contents_width, line_height, text, 1)
    $game_party.members.each_with_index do |actor, i|
      draw_actor_quick_status(actor, 4, line_height * (i + 1))
    end
  end
  #--------------------------------------------------------------------------
  # ○ 進捗更新
  #--------------------------------------------------------------------------
  def progress(finish)
    return if @finish
    refresh(finish)
  end
end

#==============================================================================
# □ Scene_Healing
#------------------------------------------------------------------------------
# 　クイックヒールの処理を行うクラスです。
#==============================================================================

class Scene_Healing < Scene_Base
  include HealCheck
  include QuickHeal
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_background
    create_healing_window
    create_healingskill_window
    count_reset
  end
  #--------------------------------------------------------------------------
  # ○ スキル実行内容のリセット
  #--------------------------------------------------------------------------
  def count_reset
    $game_party.members.each {|actor| actor.heal_count_reset }
  end
  #--------------------------------------------------------------------------
  # ○ 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_background
    heal_reset
  end
  #--------------------------------------------------------------------------
  # ○ ヒーリングウィンドウの作成
  #--------------------------------------------------------------------------
  def create_healing_window
    @healing_window = Window_Healing.new
  end
  #--------------------------------------------------------------------------
  # ○ ヒーリングスキルウィンドウの作成
  #--------------------------------------------------------------------------
  def create_healingskill_window
    @healingskill_window = Window_HealingSkill.new(@healing_window.y + @healing_window.height)
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    cure = need_curing?
    heal = need_healing?
    process_recover(cure, heal)
    $game_party.qhp_flag_reset if (cure || heal)
  end
  #--------------------------------------------------------------------------
  # ○ 回復と更新
  #--------------------------------------------------------------------------
  def process_recover(cure, heal)
    perform_recover(cure, heal)
    perform_result(!(cure || heal))
  end
  #--------------------------------------------------------------------------
  # ○ トランジション速度の取得
  #--------------------------------------------------------------------------
  def transition_speed
    return 1
  end
  #--------------------------------------------------------------------------
  # ○ 背景の作成
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
  end
  #--------------------------------------------------------------------------
  # ○ 背景の解放
  #--------------------------------------------------------------------------
  def dispose_background
    @background_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ○ 回復処理の実行
  #--------------------------------------------------------------------------
  def perform_recover(cure, heal)
    #heal_reset if (cure || heal)
    quick_cure if cure
    quick_heal if !cure && heal
  end
  #--------------------------------------------------------------------------
  # ○ スキル実行内容のリセット
  #--------------------------------------------------------------------------
  def heal_reset
    $game_party.members.each {|actor| actor.quick_heal_flag_reset }
  end
  #--------------------------------------------------------------------------
  # ○ 進捗とリザルトウィンドウの更新
  #--------------------------------------------------------------------------
  def perform_result(finish)
    @healing_window.progress(finish)
    @healingskill_window.result(finish)
    return_scene if finish && (Input.trigger?(:C) || Input.trigger?(:B))
  end
end

#==============================================================================
# □ Window_HealingSkill
#------------------------------------------------------------------------------
# 　回復に使用したスキル情報を表示するウィンドウです。
#==============================================================================

class Window_HealingSkill < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(hy)
    x = Graphics.width / 2 - window_width / 2
    super(x, hy, window_width, window_height)
    @actors = []
    @page_index = 0
    @result = false
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 288
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ○ 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    7
  end
  #--------------------------------------------------------------------------
  # ○ 最大ページ数
  #--------------------------------------------------------------------------
  def page_max
    @actors.size
  end
  #--------------------------------------------------------------------------
  # ○ アクターのセット
  #--------------------------------------------------------------------------
  def actors_set
    @actors = $game_party.members.select {|actor| actor.heal_count != {} }
    #$game_party.members.each {|actor| @actors.push(actor) if actor.heal_count != {} }
  end
  #--------------------------------------------------------------------------
  # ○ アクター名とスキルの描画
  #--------------------------------------------------------------------------
  def draw_actor_skills(actor, x, y)
    change_color(normal_color)
    draw_actor_name(actor, x, y)
    skill_id = actor.heal_count.keys
    skill_id.sort.each_with_index {|id, i| draw_skill(x + 4, y + line_height * (i + 1), id, actor) }
  end
  #--------------------------------------------------------------------------
  # ○ スキルの描画
  #--------------------------------------------------------------------------
  def draw_skill(x, y, id, actor)
    skill = $data_skills[id]
    time = actor.heal_count[id]
    cost = actor.skill_mp_cost(skill) * time
    change_color(normal_color)
    draw_item_name(skill, x, y, true, 142)
    draw_text(x + 152, y, 48, line_height, "#{time}回", 2)
    change_color(mp_cost_color)
    draw_text(x + 196, y, 52, line_height, "-#{cost}", 2)
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    text = "使用スキル 　page #{@page_index + 1}/#{page_max}"
    draw_text(0, 0, contents_width, line_height, text, 1)
    actor = @actors[@page_index]
    draw_actor_skills(actor, 4, line_height) if actor
  end
  #--------------------------------------------------------------------------
  # ○ 結果
  #--------------------------------------------------------------------------
  def result(result)
    return if @result
    @result = result
    actors_set if @result
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_page
  end
  #--------------------------------------------------------------------------
  # ○ ページの更新
  #--------------------------------------------------------------------------
  def update_page
    if Input.trigger?(:RIGHT) && page_max > 1
      Sound.play_cursor
      @page_index = (@page_index + 1) % page_max
      refresh
    elsif Input.trigger?(:LEFT) && page_max > 1
      Sound.play_cursor
      @page_index = (@page_index - 1) % page_max
      refresh
    end
  end
end
