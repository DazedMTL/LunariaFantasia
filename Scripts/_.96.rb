#==============================================================================
# ■ FAKEREAL
#------------------------------------------------------------------------------
# 　オリジナルモジュール。
#==============================================================================

module FAKEREAL
  ABILITY     = "Equip Skill"
end

#==============================================================================
# ■ ECSystem
#------------------------------------------------------------------------------
# 　装備スキルのデータを管理するモジュールです。
#   職業とスキルを連結させる事によってスキルを装備した際連結先の職業の特徴を
#   全て受け継ぐことが出来ます。また、ノートも参照出来るので韋駄天なども設定可能
#   連結方法は職業のメモに <スキル連結:スキル名>と書き
#   スキルのタイプIDを能力用のIDにするだけ
#==============================================================================

module ECSystem
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  EC_NUMBER = 5              # 装備スキルの数
  EC_S_ID = 8                # 装備スキルのスキルタイプID
  #--------------------------------------------------------------------------
  # ○ スキルに対応した職業のID検索
  #--------------------------------------------------------------------------
  def self.class_id(skill)
    return nil if !skill
    return $game_temp.equip_skills[skill.name]
  end
  #--------------------------------------------------------------------------
  # ○ 職業に対応したスキルの検索
  #--------------------------------------------------------------------------
  def self.skill_obj(class_obj)
    return nil if !class_obj
    return $data_skills[class_obj.skill_ni[1]]
  end
end

class RPG::Skill < RPG::UsableItem
  def ab_type
    @ab_type ||= ab_type_set
  end
  def ab_type_set
    type = []
    self.note.each_line do |line|
      case line
      when /\<能力タイプ:(\D+?)\>/
        type.push($1)
      end
    end
    return type
  end
end

class RPG::Class < RPG::BaseItem
  def param_ary
    @param_ary ||= param_ary_set
  end
  def param_ary_set
    param = []
    self.note.each_line do |line|
      case line
      when /\<パラメータ反映\:(\d+)\>/
        param.push($1.to_i)
      end
    end
    return param
  end
  def skill_ni
    @skill_ni ||= skill_name_id_set
  end
  def skill_name_id_set
    return [$1, $2.to_i] if self.note =~ /\<スキル連結:(.+),(\d+)\>/
    return ["", 0]
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
  # ○ 装備スキル
  #--------------------------------------------------------------------------
  def equip_skills
    @equip_skills ||= equip_skill_set
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def equip_skill_set
    e_class = {}
    $data_classes.each do |data|
      next if !data || data.skill_ni[0] == ""
      $data_skills.each do |skill|
        next if !skill
        if skill.name == data.skill_ni[0]
          e_class[skill.name] = data.id
          break
        end
      end
    end
    return e_class
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
  # ● セットアップ　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_class_setup setup
  def setup(actor_id)
    init_equip_class
    equip_class_setup(actor_id)
    #@skill_slot = init_skill_slot
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  #alias equip_skill_refresh refresh
  #def refresh
    #equip_class_set if @class_change
    #equip_skill_refresh
    #@class_change = false
  #end
  #--------------------------------------------------------------------------
  # ○ 装備スキルの初期化
  #--------------------------------------------------------------------------
  def init_equip_class
    @equip_class = Array.new(ECSystem::EC_NUMBER) { Game_BaseItem.new }
    #@equip_class_obj = []
    #equip_class_set
    #@class_change = false
  end
  #--------------------------------------------------------------------------
  # ○ スキルスロットの初期化
  #--------------------------------------------------------------------------
  #def init_skill_slot
    #ss = Array.new(ECSystem::EC_NUMBER) { [true] }
    #actor.note.each_line do |line|
      #case line
      #when /\<スキルスロット(\d)\:(\w+)\,(\d+)\>/
        #ss[$1.to_i - 1] = [false, $2, $3.to_i]
      #end
    #end
    #return ss
  #end
  #--------------------------------------------------------------------------
  # ○ スキルスロット
  #--------------------------------------------------------------------------
  def skill_slot
    actor.skill_slot
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルの職業IDを職業データのオブジェクトに変換して返す
  #--------------------------------------------------------------------------
  def equip_class
    @equip_class.collect {|e_class| e_class.class_object }
    #@equip_class_obj
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルのLv能力値に関係する職業データだけをオブジェクトに変換して返す
  #--------------------------------------------------------------------------
  def param_class
    equip_class.compact.select {|e_class| !e_class.param_ary.empty? }
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルのLv能力値に関係する職業データだけをオブジェクトに変換して返す
  #--------------------------------------------------------------------------
  def param_up_class
    param_class.inject([]) {|r, p_class| r += p_class.param_ary }
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルの職業IDを職業データのオブジェクトに変換して返す
  #--------------------------------------------------------------------------
  #def equip_class_set
    #@equip_class.inject([]) {|r, e_class| r.push($data_classes[equip_class_comvert(e_class)])}
    #@equip_class_obj = @equip_class.collect {|e_class| $data_classes[equip_class_comvert(e_class)]}
  #end
  #--------------------------------------------------------------------------
  # ○ 装備クラスをスキルオブジェクトの配列に変換
  #--------------------------------------------------------------------------
  def change_skill
    #equip_class.inject([]) {|r, e_class| r.push(ECSystem.skill_obj(e_class)) }
    @equip_class.collect {|e_class| e_class.object }
  end
  #--------------------------------------------------------------------------
  # ○ 装備クラスのnilを0に変換。0以外はそのままの数値を返す
  #--------------------------------------------------------------------------
  def equip_class_comvert(e_class)
    e_class ? e_class : 0
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルの変更
  #    equip_class : 職業ID   index : スロット番号
  #--------------------------------------------------------------------------
  def equip_classchange(index, skill)
    #@class_change = true
    @equip_class[index].object = skill
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 初期スキルのセットアップ
  #--------------------------------------------------------------------------
  def equip_skill_set
    actor.init_equip_skill.each_with_index do |skill_id, i|
      break if i == ECSystem::EC_NUMBER
      equip_classchange(i, $data_skills[skill_id])
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルを装備しているか？
  #--------------------------------------------------------------------------
  def skill_equip?(skill)
    change_skill.any? {|s_obj| s_obj == skill }
  end
  #--------------------------------------------------------------------------
  # ○同タイプのスキルを装備しているか？★
  #--------------------------------------------------------------------------
  #def skill_type_equip?(skill)
    #es_type = equip_skill_type
    #type = skill.ab_type
    #val = false
    #es_type.each do |est|
      #type.each do |st|
        #val = est.include?(st)
        #return val if val
      #end
    #end
    #return false
  #end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def ab_type(skill)
    return [] if !skill
    return skill.ab_type
  end
  #--------------------------------------------------------------------------
  # ○装備スキルタイプのスロット毎の配列★
  #--------------------------------------------------------------------------
  def equip_skill_type
    val = []
    change_skill.each {|s_obj| val.push(ab_type(s_obj))}
    return val
  end
  #--------------------------------------------------------------------------
  # ○装備スキルタイプの全配列★
  #--------------------------------------------------------------------------
  def equip_skill_type_all
    val = []
    ECSystem::EC_NUMBER.times {|i| val += equip_skill_type[i]}
    return val
  end
  #--------------------------------------------------------------------------
  # ● 特徴を保持する全オブジェクトの配列取得　※エイリアス
  #--------------------------------------------------------------------------
  alias e_class_feature_objects feature_objects
  def feature_objects
    #super + [actor] + [self.class] + equips.compact + equip_class.compact
    e_class_feature_objects + equip_class.compact + costume_feature.compact
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルの強制変更
  #     slot_id : 装備スロット ID
  #     item    : スキル（nil なら装備解除）
  #--------------------------------------------------------------------------
  def force_change_equip_class(slot_id, item)
    #@class_change = true
    @equip_class[slot_id].object = item
    #item_id = ECSystem.class_id(item)
    #@equip_class[slot_id] = item_id
    #release_unequippable_items(false) # 削除予定かも？
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の加算値取得 ※エイリアス
  #   加算値に装備スキル(クラスのLV1の数値追加)
  #   但しエディタ上で0に設定する事が出来ないため数値から1を引いている
  #   そのクラスで５上げたい時はプラス１した数値である６にしないといけない
  #--------------------------------------------------------------------------
  alias e_class_param_plus param_plus
  def param_plus(param_id)
    e_class_param_plus(param_id) + equip_class_params(param_id)
     #equip_class.compact.inject(0) {|r, s_class| r += (s_class.params[param_id, 1] - 1)}
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルの能力値　※スキルレベル対応
  #--------------------------------------------------------------------------
  def equip_class_params(param_id)
    #change_skill.compact.inject(0) {|r, skill| r += ($data_classes[skill.class_id].params[param_id, skill_lv(skill.id)] - 1)}
    #return 0 if !param_up_class.include?(param_id)
    
    param_class.inject(0) {|r, p_class| p_class.param_ary.include?(param_id) ? r += (p_class.params[param_id, skill_lv(p_class.skill_ni[1])]) : r }
    
      #r += (p_class.params[param_id, skill_lv(p_class.skill_ni[1])] - 1) if p_class.param_ary.include?(param_id) 
      #r
    #}
    #equip_class.compact.inject(0) {|r, s_class| r += (s_class.params[param_id, skill_lv(s_class.skill_ni[1])] - 1)}
    #equip_class.compact.inject(0) {|r, s_class| r += (s_class.params[param_id, 1] - 1)}
  end
  #--------------------------------------------------------------------------
  # ○ 外部からの確認用　※削除予定
  #--------------------------------------------------------------------------
  def equip_class_disp
    @equip_class
  end
  #--------------------------------------------------------------------------
  # ○ 装備品と装備スキル両方の取得
  #--------------------------------------------------------------------------
  def full_equip
    equips.compact + equip_class.compact + costume_feature.compact
  end
  #--------------------------------------------------------------------------
  # ○ 装備品と装備スキル両方＋ステートの取得
  #--------------------------------------------------------------------------
  def full_equip_plus_states
    full_equip + states
  end
  #--------------------------------------------------------------------------
  # ○ レベルアップウィンドウ用に装備等の数値変化物を総リセット ※一時アクター用
  #    今回は不要なので削除予定
  #--------------------------------------------------------------------------
  def lv_prepare
    @equips = Array.new(equip_slots.size) { Game_BaseItem.new }
    init_equip_class
    clear_states
    clear_buffs
  end
  #--------------------------------------------------------------------------
  # 〇 スキル変更の可能判定
  #     slot_id : 装備スロット ID
  #--------------------------------------------------------------------------
  def equip_skill_change_ok?(slot_id)
    return skill_unlock(slot_id)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def skill_unlock(slot_id)
    return true if skill_slot[slot_id][0]
    case skill_slot[slot_id][1].upcase
    when "LV"
      return @level >= skill_slot[slot_id][2]
    when "SKILL"
      return skill_learn?($data_skills[skill_slot[slot_id][2]])
    when "SWITCHES"
      return $game_switches[skill_slot[slot_id][2]]
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # 〇 スキル解放レベルの配列
  #--------------------------------------------------------------------------
  def skill_unlock_level
    sul = []
    skill_slot.each {|ss| sul.push(ss[2]) if !ss[0] && (ss[1].upcase == "LV") }
    return sul
  end
  #--------------------------------------------------------------------------
  # ● 経験値の変更　※エイリアス
  #     show : レベルアップ表示フラグ
  #--------------------------------------------------------------------------
  alias s_unlock_change_exp change_exp
  def change_exp(exp, show)
    #@exp[@class_id] = [exp, 0].max
    #last_level = @level
    #last_skills = skills
    #level_up while !max_level? && self.exp >= next_level_exp
    #level_down while self.exp < current_level_exp
    #display_level_up(skills - last_skills) if show && @level > last_level
    #refresh
    sul_level = @level
    s_unlock_change_exp(exp, show)
    display_skill_unlock(skill_unlock_level.inject(0){|r, l| ((sul_level + 1) .. @level).include?(l) ? r + 1 : r }) if show && @level > sul_level
  end
  #--------------------------------------------------------------------------
  # ○ スキルスロット解放メッセージの表示
  #     slots : 解放数
  #--------------------------------------------------------------------------
  def display_skill_unlock(slots)
    $game_message.add(sprintf(Vocab::UnlockSlots, slots)) if slots > 0
  end
end

#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
# 　用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#==============================================================================

module Vocab

  UnlockSlots     = "スキルスロットが%sつ解放された！"
  
end

class RPG::Actor < RPG::BaseItem
  def skill_slot
    @skill_slot ||= skill_slot_set
  end
  def skill_slot_set
    ss = Array.new(ECSystem::EC_NUMBER) { [true] }
    self.note.each_line do |line|
      case line
      when /\<スキルスロット(\d)\:(\w+)\,(\d+)\>/
        ss[$1.to_i - 1] = [false, $2, $3.to_i]
      end
    end
    return ss
  end
end

#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。主に能力値計算のメソッドを含んでいます。こ
# のクラスは Game_Battler クラスのスーパークラスとして使用されます。
#==============================================================================
=begin
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ○ 特定のスキルを装備しているかの判定　※汎用追加項目に移動済み
  #--------------------------------------------------------------------------
  def equip_skill_check(str)
    return false if enemy? #エネミーはスキル装備がないので
    equip_class.any?{|skill| note_check(skill, str)}
  end
end
=end
#==============================================================================
# ■ Window_ActorCommand
#------------------------------------------------------------------------------
# 　バトル画面で、アクターの行動を選択するウィンドウです。
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● スキルコマンドをリストに追加　※再定義
  # 非表示にするスキル(パッシブスキル)を追加
  #--------------------------------------------------------------------------
  def add_skill_commands
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id) unless no_add_skill.include?(stype_id)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 非表示にするスキルのID配列
  #--------------------------------------------------------------------------
  def no_add_skill
    [ECSystem::EC_S_ID, ECSystem::W_S_ID]
  end
end

class RPG::Skill < RPG::UsableItem
  def class_id
    @class_id ||= class_id_set
  end
  def class_id_set
    self.note =~ /\<装備スキル職業\:(\d+)\>/ ? $1.to_i : 0 #$1.to_i * (magni? ? 0.01 : 1) : 0
  end
end


#==============================================================================
# ■ Game_BaseItem
#------------------------------------------------------------------------------
# 　スキル、アイテム、武器、防具を統一的に扱うクラスです。セーブデータに含める
# ことができるように、データベースオブジェクト自体への参照は保持しません。
#==============================================================================

class Game_BaseItem
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_initialize initialize
  def initialize
    equip_initialize
    @class_id = 0
  end
  #--------------------------------------------------------------------------
  # 〇 職業オブジェクトの取得
  #--------------------------------------------------------------------------
  def class_object
    return $data_classes[@class_id] if is_skill? && @class_id > 0
    return nil
  end
  #--------------------------------------------------------------------------
  # ● アイテムオブジェクトの設定　※再定義
  #--------------------------------------------------------------------------
  def object=(item)
    @class = item ? item.class : nil
    @item_id = item ? item.id : 0
    @class_id = item && is_skill? ? item.class_id : 0
  end
end
