module FAKEREAL
  
  NO_EAT = 99 # 食事禁止スイッチ

end

module FRSHIFT
  #--------------------------------------------------------------------------
  # ○ の有効状態を取得
  #--------------------------------------------------------------------------
  def shift_enabled?
    handle?(:shift_change)
  end
  #--------------------------------------------------------------------------
  # ○ ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_shift
    if ex_current_item_enabled?
      Sound.play_ok
      Input.update
      deactivate
      call_shift_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ○ ハンドラの呼び出し
  #--------------------------------------------------------------------------
  def call_shift_handler
    call_handler(:shift_change)
  end
end



#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  FEATURE_PARTY_ABILITY = 64              # パーティ能力
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :eat                   # 満腹状態かの判定
  attr_accessor :battle_eat            # 戦闘勝利時に食べるアイテム
  attr_accessor :battle_eat_id         # 戦闘勝利時に食べるアイテムID
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias cooking_initialize initialize
  def initialize
    cooking_initialize
    clear_eating
    clear_battle_eat
  end
  #--------------------------------------------------------------------------
  # ○ 食べ物情報をクリア
  #--------------------------------------------------------------------------
  def clear_eating
    @eat = false
  end
  #--------------------------------------------------------------------------
  # ○ 勝利時食べ物情報をクリア
  #--------------------------------------------------------------------------
  def clear_battle_eat
    @battle_eat = nil
    @battle_eat_id = 0
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def eating?
    has_item?(battle_eat) && eat_heal?(battle_eat)
  end
  
  
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def eat_heal?(item)
    return false unless item
    heal_member = $game_party.members.select {|actor| !actor.summon_type? }
    heal_member.any? {|actor| eat_heal_conditions_met?(actor, item)}
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def eat_heal_conditions_met?(actor, item)
    item.effects.each do |ef|
      return true if ef.code == 11 && actor.hp < actor.mhp
      return true if ef.code == 12 && actor.mp < actor.mmp
      return true if ef.code == 13 && actor.tp < actor.max_tp
    end
    return true if item.effects.any? {|ef| ef.code == 22 && actor.bad_state_select.include?(ef.data_id) }
    return item.effects.any? {|ef| (ef.code == 21 && ef.data_id != 71) }
  end
  
  
  #--------------------------------------------------------------------------
  # ○ ステートの解除
  #--------------------------------------------------------------------------
  def remove_food_state(state_id)
    if state?(state_id)
      erase_state(state_id)
      #@removed.push(state_id).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # 〇 戦闘終了時ステートの解除
  #--------------------------------------------------------------------------
  def remove_battle_states
    states.each do |state|
      remove_food_state(state.id) if state.remove_at_battle_end
    end
  end
  #--------------------------------------------------------------------------
  # 〇 戦闘終了処理
  #--------------------------------------------------------------------------
  def on_battle_end
    super
    remove_battle_states
    #clear_eating
  end

  #--------------------------------------------------------------------------
  # ○ 戦闘開始時ステートのセット
  #--------------------------------------------------------------------------
  def start_state_set
    states.each do |p_state|
      next if p_state.food_state.empty? && p_state.food_buff.empty?
      p_state.food_state.each do |state|
        all_members.each do |actor|
          actor.add_state(state)
        end
      end
      p_state.food_buff.each do |id, turn|
        all_members.each do |actor|
          actor.add_buff(id, turn)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘開始時ステートの解除
  #--------------------------------------------------------------------------
  def remove_start_state
    states.each do |state|
      remove_food_state(state.id) if state.remove_at_battle_start
    end
    clear_eating #同時に食事済みフラグを解除
  end

  #--------------------------------------------------------------------------
  # ● アイテムの減少
  #     include_equip : 装備品も含める
  #--------------------------------------------------------------------------
  alias cooking_lose_item lose_item
  def lose_item(item, amount, include_equip = false)
    item_id = item ? item.id : 0
    cooking_lose_item(item, amount, include_equip)
    clear_battle_eat if item_id > 0 && item_id == battle_eat_id && !has_item?(item)
  end

end

#==============================================================================
# ■ Game_Unit
#------------------------------------------------------------------------------
# 　ユニットを扱うクラスです。このクラスは Game_Party クラスと Game_Troop クラ
# スのスーパークラスとして使用されます。
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # ● 戦闘開始処理　
  #--------------------------------------------------------------------------
  alias state_on_battle_start on_battle_start
  def on_battle_start
    state_on_battle_start
    start_state_set
    remove_start_state
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘開始時ステートのセット
  #--------------------------------------------------------------------------
  def start_state_set
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘開始時ステートの解除
  #--------------------------------------------------------------------------
  def remove_start_state
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
  alias food_state_item_effect_test item_effect_test
  def item_effect_test(user, item, effect)
    if item.cooking?
      return false if $game_party.eat
      case effect.code
      when EFFECT_ADD_STATE
        !$game_party.state?(effect.data_id)
      when EFFECT_RECOVER_HP
        hp < mhp || effect.value1 < 0 || effect.value2 < 0
      when EFFECT_RECOVER_MP
        mp < mmp || effect.value1 < 0 || effect.value2 < 0
      when EFFECT_GAIN_TP
        tp < max_tp || effect.value1 < 0 || effect.value2 < 0
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
    else
      food_state_item_effect_test(user, item, effect)
    end
  end
end

#==============================================================================
# ■ Scene_ItemBase
#------------------------------------------------------------------------------
# 　アイテム画面とスキル画面の共通処理を行うクラスです。
#==============================================================================

class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● アイテムの使用
  #--------------------------------------------------------------------------
  alias food_use_item use_item
  def use_item
    food_use_item
    $game_party.eat = true if item.cooking?
  end
end

class RPG::State < RPG::BaseItem
  def food_state
    @food_state ||= food_state_set
  end
  def food_buff
    @food_buff ||= food_buff_set
  end
  def remove_at_battle_start
    @remove_at_battle_start ||= remove_at_battle_start_set
  end
  def food_state_set
    s = []
    self.note.each_line do |line|
      case line
      when /\<食べ物ステート\:(\d+)\>/
        s.push($1.to_i)
      end
    end
    return s
  end
  def food_buff_set
    buff = {}
    self.note.each_line do |line|
      case line
      when /\<食べ物強化:(\d+)\,(\d+)\>/
        buff[$1.to_i] = $2.to_i
      end
    end
    return buff
  end
  def remove_at_battle_start_set
    self.note =~ /\<開始後解除\>/
  end
end


#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#　※どうしてもこの処理のみXPスタイルバトルの下に記述する必要あり
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ○ 料理をアクターに対して使用
  #--------------------------------------------------------------------------
  def eat_to_actors(user, item)
    $game_party.members.each do |target|
      item.repeats.times { target.item_apply(user, item) }
    end
  end
  #--------------------------------------------------------------------------
  # ○ 食事
  #--------------------------------------------------------------------------
  def end_eating(user, item)
    user.use_item(item)
    eat_to_actors(user, item)
    $game_party.eat = true
    $game_party.clear_battle_eat if !$game_party.has_item?(item)
  end
  #--------------------------------------------------------------------------
  # ○ 食事するかの確認
  #--------------------------------------------------------------------------
  def eating?
    $game_party.eating? && $game_temp.battle_end == 0 && !$game_switches[FAKEREAL::NO_EAT]
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
  attr_accessor :battle_end                # 戦闘終了時の勝敗判定
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias bet_initialize initialize
  def initialize
    bet_initialize
    @battle_end = 0
  end
end

class << BattleManager
  #--------------------------------------------------------------------------
  # ● 戦闘終了
  #     result : 結果（0:勝利 1:逃走 2:敗北）
  #--------------------------------------------------------------------------
  alias eating_battle_end battle_end
  def battle_end(result)
    $game_temp.battle_end = result
    eating_battle_end(result)
  end
end

=begin
 シーンアイテムベース
  #--------------------------------------------------------------------------
  # ● アイテムをアクターに対して使用
  #--------------------------------------------------------------------------
  def use_item_to_actors
    item_target_actors.each do |target|
      item.repeats.times { target.item_apply(user, item) }
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムの使用
  #--------------------------------------------------------------------------
  def use_item
    play_se_for_item
    user.use_item(item)
    use_item_to_actors
    check_common_event
    check_gameover
    @actor_window.refresh
  end





 ゲームバトラー
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用
  #    行動側に対して呼び出され、使用対象以外に対する効果を適用する。
  #--------------------------------------------------------------------------
  def use_item(item)
    pay_skill_cost(item) if item.is_a?(RPG::Skill)
    consume_item(item)   if item.is_a?(RPG::Item)
    item.effects.each {|effect| item_global_effect_apply(effect) }
  end
  #--------------------------------------------------------------------------
  # ● アイテムの消耗
  #--------------------------------------------------------------------------
  def consume_item(item)
    $game_party.consume_item(item)
  end
  #--------------------------------------------------------------------------
  # ● 使用対象以外に対する使用効果の適用
  #--------------------------------------------------------------------------
  def item_global_effect_apply(effect)
    if effect.code == EFFECT_COMMON_EVENT
      $game_temp.reserve_common_event(effect.data_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの適用テスト
  #    使用対象が全快しているときの回復禁止などを判定する。
  #--------------------------------------------------------------------------
  def item_test(user, item)
    return false if item.for_dead_friend? != dead?
    return true if $game_party.in_battle
    return true if item.for_opponent?
    return true if item.damage.recover? && item.damage.to_hp? && hp < mhp
    return true if item.damage.recover? && item.damage.to_mp? && mp < mmp
    return true if item_has_any_valid_effects?(user, item)
    return false
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムに有効な使用効果が一つでもあるかを判定
  #--------------------------------------------------------------------------
  def item_has_any_valid_effects?(user, item)
    item.effects.any? {|effect| item_effect_test(user, item, effect) }
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの反撃率計算
  #--------------------------------------------------------------------------
  def item_cnt(user, item)
    return 0 unless item.physical?          # 命中タイプが物理ではない
    return 0 unless opposite?(user)         # 味方には反撃しない
    return cnt                              # 反撃率を返す
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの反射率計算
  #--------------------------------------------------------------------------
  def item_mrf(user, item)
    return mrf if item.magical?             # 魔法攻撃なら魔法反射率を返す
    return 0
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの命中率計算
  #--------------------------------------------------------------------------
  def item_hit(user, item)
    rate = item.success_rate * 0.01         # 成功率を取得
    rate *= user.hit if item.physical?      # 物理攻撃：命中率を乗算
    return rate                             # 計算した命中率を返す
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの回避率計算
  #--------------------------------------------------------------------------
  def item_eva(user, item)
    return eva if item.physical?            # 物理攻撃なら回避率を返す
    return mev if item.magical?             # 魔法攻撃なら魔法回避率を返す
    return 0
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの会心率計算
  #--------------------------------------------------------------------------
  def item_cri(user, item)
    item.damage.critical ? user.cri * (1 - cev) : 0
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃の効果適用
  #--------------------------------------------------------------------------
  def attack_apply(attacker)
    item_apply(attacker, $data_skills[attacker.attack_skill_id])
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの効果適用
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    @result.clear
    @result.used = item_test(user, item)
    @result.missed = (@result.used && rand >= item_hit(user, item))
    @result.evaded = (!@result.missed && rand < item_eva(user, item))
    if @result.hit?
      unless item.damage.none?
        @result.critical = (rand < item_cri(user, item))
        make_damage_value(user, item)
        execute_damage(user)
      end
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
=end