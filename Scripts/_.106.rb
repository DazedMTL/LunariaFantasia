#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  FEATURE_PARTY_ABILITY = 64              # パーティ能力
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias party_state_initialize initialize
  def initialize
    party_state_initialize
    clear_states
  end
  #--------------------------------------------------------------------------
  # ○ ステート情報をクリア
  #--------------------------------------------------------------------------
  def clear_states
    @states = []
    @state_turns = {}
    @state_steps = {}
    @removed = []
  end
  #--------------------------------------------------------------------------
  # ○ ステートの消去
  #--------------------------------------------------------------------------
  def erase_state(state_id)
    @states.delete(state_id)
    @state_turns.delete(state_id)
    @state_steps.delete(state_id)
  end
  #--------------------------------------------------------------------------
  # ○ ステートの検査
  #--------------------------------------------------------------------------
  def state?(state_id)
    @states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ○ 現在のステートをオブジェクトの配列で取得
  #--------------------------------------------------------------------------
  def states
    @states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # ○ 現在のステートをアイコン番号の配列で取得
  #--------------------------------------------------------------------------
  def state_icons
    icons = states.collect {|state| state.icon_index }
    icons.delete(0)
    icons
  end
  #--------------------------------------------------------------------------
  # ○ ステートの並び替え
  #    配列 @states の内容を表示優先度の大きい順に並び替える。
  #--------------------------------------------------------------------------
  def sort_states
    @states = @states.sort_by {|id| [-$data_states[id].priority, id] }
  end
  #--------------------------------------------------------------------------
  # ○ ステートの付加
  #--------------------------------------------------------------------------
  def add_state(state_id)
    if state_addable?(state_id)
      add_new_state(state_id) unless state?(state_id)
      reset_state_counts(state_id)
    end
  end
  #--------------------------------------------------------------------------
  # ○ ステートの付加可能判定
  #--------------------------------------------------------------------------
  def state_addable?(state_id)
    $data_states[state_id] && !state_removed?(state_id) && !state_restrict?(state_id)
  end
  #--------------------------------------------------------------------------
  # ○ 同一行動内で解除済みのステートを判定
  #--------------------------------------------------------------------------
  def state_removed?(state_id)
    @removed.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ○ 行動制約によって無効化されるステートを判定
  #--------------------------------------------------------------------------
  def state_restrict?(state_id)
    $data_states[state_id].remove_by_restriction && restriction > 0
  end
  #--------------------------------------------------------------------------
  # ○ 新しいステートの付加
  #--------------------------------------------------------------------------
  def add_new_state(state_id)
    @states.push(state_id)
    on_restrict if restriction > 0
    sort_states
  end
  #--------------------------------------------------------------------------
  # ○ 行動制約が生じたときの処理
  #--------------------------------------------------------------------------
  def on_restrict
    states.each do |state|
      remove_state(state.id) if state.remove_by_restriction
    end
  end
  #--------------------------------------------------------------------------
  # ○ 制約の取得
  #    現在付加されているステートから最大の restriction を取得する。
  #--------------------------------------------------------------------------
  def restriction
    states.collect {|state| state.restriction }.push(0).max
  end
  #--------------------------------------------------------------------------
  # ○ ステートのカウント（ターン数および歩数）をリセット
  #--------------------------------------------------------------------------
  def reset_state_counts(state_id)
    state = $data_states[state_id]
    variance = 1 + [state.max_turns - state.min_turns, 0].max
    @state_turns[state_id] = state.min_turns + rand(variance)
    @state_steps[state_id] = state.steps_to_remove
  end
  #--------------------------------------------------------------------------
  # ○ ステートの解除
  #--------------------------------------------------------------------------
  def remove_state(state_id)
    if state?(state_id)
      erase_state(state_id)
      @removed.push(state_id).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムによるステートの解除
  #--------------------------------------------------------------------------
  def item_remove_state(state_id)
    if state?(state_id)
      erase_state(state_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーが 1 歩動いたときの処理　※エイリアス
  #--------------------------------------------------------------------------
  alias party_on_player_walk on_player_walk
  def on_player_walk
    party_on_player_walk
    on_party_walk
  end
  #--------------------------------------------------------------------------
  # ○ パーティが 1 歩動いたときの処理
  #--------------------------------------------------------------------------
  def on_party_walk
    if $game_player.normal_walk?
      states.each {|state| update_state_steps(state) }
      show_added_states
      show_removed_states
    end
  end
  #--------------------------------------------------------------------------
  # ○ ステートの歩数カウントを更新
  #--------------------------------------------------------------------------
  def update_state_steps(state)
    if state.remove_by_walking
      @state_steps[state.id] -= 1 if @state_steps[state.id] > 0
      remove_state(state.id) if @state_steps[state.id] == 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ 付加されたステートの表示
  #--------------------------------------------------------------------------
  def show_added_states
  end
  #--------------------------------------------------------------------------
  # ○ 解除されたステートの表示
  #--------------------------------------------------------------------------
  def show_removed_states
    @removed.each do |state_id|
      $game_message.add($data_states[state_id].message4) unless $data_states[state_id].message4.empty?
    end
    @removed= []
  end
  #--------------------------------------------------------------------------
  # ○ 特定の装備品やスキルを装備しているか？　※追加のエイリアス
  #--------------------------------------------------------------------------
  alias party_state_extra_equip_include? extra_equip_include?
  def extra_equip_include?(str)
    party_state_extra_equip_include?(str) || state_check(str)
  end
  #--------------------------------------------------------------------------
  # ○ ノートに特定の文字列等が記されているかをチェック。
  #    nil対策として対象がnilの場合は参照前にfalseを返す
  #    flag：特定の文字列等    value：アイテム等
  #--------------------------------------------------------------------------
  def note_check(value, flag)
    return false if !value
    value.note.include?(flag)
  end
  #--------------------------------------------------------------------------
  # ○ 特定のステータス状態かの判定　文字列指定により色々応用可能
  #--------------------------------------------------------------------------
  def state_check(str)
    states.any?{|state| note_check(state, str)}
  end
  #--------------------------------------------------------------------------
  # ○ 特徴を保持する全オブジェクトの配列取得
  #--------------------------------------------------------------------------
  def feature_objects
    states
  end
  #--------------------------------------------------------------------------
  # ○ 全ての特徴オブジェクトの配列取得
  #--------------------------------------------------------------------------
  def all_features
    feature_objects.inject([]) {|r, obj| r + obj.features }
  end
  #--------------------------------------------------------------------------
  # ○ 特徴オブジェクトの配列取得（特徴コードを限定）
  #--------------------------------------------------------------------------
  def features(code)
    all_features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # ○ パーティ能力ステータス判定
  #--------------------------------------------------------------------------
  def states_ability(ability_id)
    features(FEATURE_PARTY_ABILITY).any? {|ft| ft.data_id == ability_id }
  end
  #--------------------------------------------------------------------------
  # ● パーティ能力判定　※エイリアス
  #--------------------------------------------------------------------------
  alias party_states_party_ability party_ability
  def party_ability(ability_id)
    party_states_party_ability(ability_id) || states_ability(ability_id)
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
  # ● 使用効果のテスト　※エイリアス
  #--------------------------------------------------------------------------
  alias party_state_item_effect_test item_effect_test
  def item_effect_test(user, item, effect)
    if item.party_effect?
      case effect.code
      when EFFECT_ADD_STATE
        !$game_party.state?(effect.data_id)
      when EFFECT_REMOVE_STATE
        $game_party.state?(effect.data_id)
      else
        true
      end
    else
      party_state_item_effect_test(user, item, effect)
    end
=begin
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
=end
  end
  #--------------------------------------------------------------------------
  # ● 使用効果［ステート付加］
  #--------------------------------------------------------------------------
  alias party_state_item_effect_add_state item_effect_add_state
  def item_effect_add_state(user, item, effect)
    if item.party_effect?
      $game_party.add_state(effect.data_id)
    else
      party_state_item_effect_add_state(user, item, effect)
    end
  end
  #--------------------------------------------------------------------------
  # ● 使用効果［ステート解除］
  #--------------------------------------------------------------------------
  alias party_state_item_effect_remove_state item_effect_remove_state
  def item_effect_remove_state(user, item, effect)
    if item.party_effect? && !item.cooking?
      chance = effect.value1
      if rand < chance
        $game_party.item_remove_state(effect.data_id)
        #@result.success = true
      end
    else
      party_state_item_effect_remove_state(user, item, effect)
    end
  end
end

#==============================================================================
# ■ Window_MenuStatus
#------------------------------------------------------------------------------
# 　メニュー画面でパーティメンバーのステータスを表示するウィンドウです。
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ ステートおよび強化／弱体のアイコンを描画
  #--------------------------------------------------------------------------
  def draw_party_icons(x, y, width = 72)
    icons = ($game_party.state_icons)[0, width / 24 * 2]
    icons.each_with_index {|n, i| draw_icon(n, x - 24 * (i % (width / 24)), y + 24 * (i / (width / 24))) }
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ　※オーバーライド
  #--------------------------------------------------------------------------
  def refresh
    super
    draw_party_icons(contents_width - 24, 0)
  end
end

class RPG::UsableItem < RPG::BaseItem
  def party_effect?
    self.note =~ /\<パーティ効果\>/
  end
end