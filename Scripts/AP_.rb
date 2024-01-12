
class RPG::Actor < RPG::BaseItem
  def init_ap
    self.note =~ /\<初期AP:(-?\d+)\>/ ? $1.to_i : 0
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
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :ap                     # アビリティポイント
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  #alias ap_initialize initialize
  #def initialize(actor_id)
    #ap_initialize(actor_id)
    #@ap = 0
  #end
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias ap_setup setup
  def setup(actor_id)
    ap_setup(actor_id)
    ap_initialize
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def ap_initialize
    @ap = actor.init_ap + level_init_ap(@level)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def level_init_ap(level)
    i = 0
    (level - 1).times {|lv| i += (lv + 2) * 5 }
    return i
  end
  #--------------------------------------------------------------------------
  # ○ アビリティポイントの変更 最大値の999999を超えないようにaccessorではなく
  #　　個別関数で定義
  #--------------------------------------------------------------------------
  def ap=(ap)
    @ap = [[ap, 999999].min, 0].max
  end
  #--------------------------------------------------------------------------
  # ○ アビリティポイント倍率の取得
  #--------------------------------------------------------------------------
  def ap_rate
    rate1 = equip_class.compact.inject(1.0) {|r, job| r += job.ap_rate * skill_lv(job.skill_ni[1])}#ECSystem.skill_id(job.id))}
    rate2 = equips.compact.inject(1.0) {|r, equip| r += equip.ap_rate}
    return [[rate1, rate2].max, 1.5].min
    #rate += full_equip.inject(0) {|r, equip| r += equip.ap_rate}
    #return rate
  end
  #--------------------------------------------------------------------------
  # ○ APの獲得（AP倍率を考慮）
  #--------------------------------------------------------------------------
  def gain_ap(ap)
    self.ap += $game_party.ap_uper? ? ap.to_i : (ap * ap_rate).to_i
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
  # ● 定数
  #--------------------------------------------------------------------------
  EXCEPT_SKILL  = [1, 411]             # 行動重複しても削除しないスキル
  #--------------------------------------------------------------------------
  # ○ アビリティポイント
  #--------------------------------------------------------------------------
  def ap
    enemy.ap
  end
  #--------------------------------------------------------------------------
  # ● ドロップアイテムの配列作成 ※ドロップ率の計算変更　エディタ設定の数字を
  #    そのままパーセンテージに（75と設定すると75%の確率でドロップ）
  #　　更に設定値を100以上にするとデフォルトの計算式（１％未満の確率を設定可能）
  #--------------------------------------------------------------------------
  def make_drop_items
    enemy.drop_items.inject([]) do |r, di|
      dir = rand
      #p dir
      if di.denominator > 100
        #p "アイテム #{di.denominator}"
        if di.kind > 0 && dir * di.denominator < drop_item_rate
          r.push(item_object(di.kind, di.data_id))
        else
          r
        end
      else
        #p "アイテム #{di.denominator * 0.01}"
        if di.kind > 0 && dir < di.denominator * 0.01 * drop_item_rate
      #if di.kind > 0 && x < di.denominator * drop_item_rate
      #if di.kind > 0 && rand > 1.0 - di.denominator * drop_item_rate * 0.01
      #if di.kind > 0 && (rand(100) + 1) > 100 - di.denominator * drop_item_rate
      #if di.kind > 0 && rand(1001) * 0.001 > 1.0 - (di.denominator * 0.001) * drop_item_rate
          r.push(item_object(di.kind, di.data_id))
        else
          r
        end
      end
    end
  end
=begin
  def make_drop_items
    enemy.drop_items.inject([]) do |r, di|
      if di.kind > 0 && rand * di.denominator < drop_item_rate
        r.push(item_object(di.kind, di.data_id))
      else
        r
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の作成
  #    行動回数追加において行動が重複しないよう調整
  #--------------------------------------------------------------------------
  alias same_delete_make_actions make_actions
  def make_actions
    same_delete_make_actions
    if @actions.size > 1
      before = []
      @actions.each do |action|
        before.push(action.item.id)
      end
      after = Array.new(before.size) {nil}
      before.each_with_index do |num, i|
        after[i] = num unless after.include?(num)
      end
      after.each_with_index do |num, i|
        @actions[i] = nil if num == nil
      end
      @actions = @actions.compact
    end
  end
=end
  #--------------------------------------------------------------------------
  # ● 戦闘行動をランダムに選択
  #     行動回数追加において同じ行動はリストから除外（スキルID 1 は例外）
  #     action_list : RPG::Enemy::Action の配列
  #     rating_zero : ゼロとみなすレーティング値
  #--------------------------------------------------------------------------
  alias same_delete_select_enemy_action select_enemy_action
  def select_enemy_action(action_list, rating_zero)
    same = []
    act_id = []
    @actions.each {|act| same.push(act.item)}
    same.compact!.each {|item| act_id.push(item.id)}
    #action_list.each_with_index{|action, i| action_list.delete_at(i) if act_id.include?(action.skill_id) && !EXCEPT_SKILL.include?(action.skill_id)}#action.skill_id != 1}
    action_list.reject! {|a| act_id.include?(a.skill_id) && !EXCEPT_SKILL.include?(a.skill_id) }
    if action_list.all?{|action| 0 >= (action.rating - rating_zero) }
      rating_zero = 0
      if action_list.empty?
        action_list = enemy.actions.select {|a| action_valid?(a) }
        rating_max = action_list.collect {|a| a.rating }.max
        action_list.reject! {|a| act_id.include?(a.skill_id) && !EXCEPT_SKILL.include?(a.skill_id) }
      end
    end
    same_delete_select_enemy_action(action_list, rating_zero)
  end
=begin
  #--------------------------------------------------------------------------
  # ● 戦闘行動をランダムに選択
  #     action_list : RPG::Enemy::Action の配列
  #     rating_zero : ゼロとみなすレーティング値
  #--------------------------------------------------------------------------
  def select_enemy_action(action_list, rating_zero, actions)
    same = []
    act_id = []
    actions.each {|act| same.push(act.item)}
    same.compact!.each {|item| act_id.push(item.id)}
    action_list.each_with_index{|action, i| action_list.delete_at(i) if act_id.include?(action.skill_id) && action.skill_id != 1}
    sum = action_list.inject(0) {|r, a| r += a.rating - rating_zero }
    return nil if sum <= 0
    value = rand(sum)
    action_list.each do |action|
      return action if value < action.rating - rating_zero
      value -= action.rating - rating_zero
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の作成
  #--------------------------------------------------------------------------
  def make_actions
    super
    return if @actions.empty?
    action_list = enemy.actions.select {|a| action_valid?(a) }
    return if action_list.empty?
    rating_max = action_list.collect {|a| a.rating }.max
    rating_zero = rating_max - 3
    action_list.reject! {|a| a.rating <= rating_zero }
    @actions.each do |action|
      action.set_enemy_action(select_enemy_action(action_list, rating_zero, @actions))
    end
  end
=end
end

class RPG::Enemy < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ アビリティポイントの設定
  #--------------------------------------------------------------------------
  def ap
    point = 1
    self.note.each_line do |line|
      case line
      when /\<AP:(\d+)\>/
        point = $1.to_i
      end
    end
    return point
  end
end


#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　敵グループおよび戦闘に関するデータを扱うクラスです。バトルイベントの処理も
# 行います。このクラスのインスタンスは $game_troop で参照されます。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ○ アビリティポイントの合計計算
  #--------------------------------------------------------------------------
  def ap_total
    dead_members.inject(0) {|r, enemy| r += enemy.ap }
  end
end


class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ AP倍率の計算　倍率は少数ではなく％で指定　例：50
  #--------------------------------------------------------------------------
  def ap_rate
    rate = 0
    self.note.each_line do |line|
      case line
      when /\<AP倍率加算:(\d+)\>/
        rate = $1.to_i
      end
    end
    return rate * 0.01
  end
end

#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
# 　用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#==============================================================================

module Vocab
  
  ObtainAp      = "%s を %s 獲得！"
  Eating        = "料理 %s を使用"

  EAT_SE = RPG::SE.new("Heal3", 80, 100)


  # スキルタイプの名前
  def self.stype_name(stype_id)
    $data_system.skill_types[stype_id]
  end
  
  # 武器タイプの名前
  def self.wtype_name(wtype_id)
    $data_system.weapon_types[wtype_id]
  end
  
  # 防具タイプの名前
  def self.atype_name(atype_id)
    $data_system.armor_types[atype_id]
  end
  
  def self.learn;       "スキル習得";     end   # 技習得
  def self.skillup;     "強化";   end   # スキルレベルアップ
  def self.ap;          "LP";             end   # APの名前
  def self.ap_ex;          "ＬＰ";             end   # APの名前（全角）
  
end

#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　戦闘の進行を管理するモジュールです。
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # ● 勝利の処理　※再定義
  #--------------------------------------------------------------------------
  def self.process_victory
    play_battle_end_me
    replay_bgm_and_bgs
    $game_message.add(sprintf(Vocab::Victory, $game_party.name))
    display_exp
    gain_ap # 追加
    gain_gold
    eating # 追加
    gain_drop_items
    gain_exp
    SceneManager.return
    battle_end(0)
    return true
  end
  #--------------------------------------------------------------------------
  # ○ APの獲得
  #--------------------------------------------------------------------------
  def self.gain_ap
    if $game_troop.ap_total > 0
      $game_party.all_members.each do |actor|
        actor.gain_ap($game_troop.ap_total)
      end
      text = sprintf(Vocab::ObtainAp, Vocab::ap_ex, $game_troop.ap_total)
      $game_message.add('\.' + text)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 料理の使用
  #--------------------------------------------------------------------------
  def self.eating
    if$game_party.eating?
      @helpdisplay_wait = 60
      @helpdisplay_wait_input = true
      Vocab::EAT_SE.play
      #@helpdisplay_se = Vocab::EAT_SE#.play
      text = sprintf(Vocab::Eating, $game_party.battle_eat.name)
      m = $game_party.battle_members[1] && !$game_party.battle_members[1].summon_type? ? "達" : ""
      target = sprintf("#{$game_party.leader.name}%s の", m)
      text2 = ""
      $game_party.battle_eat.effects.each do |f|
        case f.code
        when 11 ; text2 += "ＨＰ#{(f.value1 * 100).to_i}% "
        when 12 ; text2 += "ＭＰ#{(f.value1 * 100).to_i}% "
        when 13 ; text2 += "ＳＰ#{$game_party.battle_eat.note =~ /\<TP回復率:(\d+)\>/ ? $1 : ""}% " #if $game_party.battle_eat.note =~ /\<TP回復率:(\d+)\>/
        when 22 
          if f.data_id == 2
            text2 += "毒 "
          elsif f.data_id == 31
            text2 += "閉門 "
          end
        end
      end
      text2 += "が回復！"
      $game_message.add('\.' + text)
      $game_message.add('\.' + target + text2)
      wait_for_message
      @helpdisplay_wait = nil
      @helpdisplay_wait_input = nil
      @helpdisplay_se = nil
    end
  end
end
