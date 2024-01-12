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
  W_S_ID = 9                # 武器スキルのスキルタイプID
  ALWAYS_ID = 100                # 常時発動スキルの識別ID
end

class RPG::Class < RPG::BaseItem
  def wtype
    @wtype ||= wtype_set
  end
  def wtype_set
    self.note =~ /\<武器スキル\:(\d+)\>/ ? $1.to_i : 0
  end
  def atype
    @atype ||= atype_set
  end
  def atype_set
    type = []
    self.note.each_line do |line|
      case line
      when /\<防具スキル\:(\d+)\>/
        type.push($1.to_i)
      end
    end
    return type
  end
  def wpp
    @wpp ||= wpp_set
  end
  def wpp_set
    w_param_plus = {}
    self.note.each_line do |line|
      case line
      when /\<上乗せ\:(\d+)\,(\d+)\,(\d+)\>/
        w_param_plus[$1.to_i] = [$2.to_i, $3.to_i]
      end
    end
    return w_param_plus
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
  # ● 定数（使用効果）
  #--------------------------------------------------------------------------
  PARAM_LIMIT_A     = 9999              # ステータス上限値A
  PARAM_LIMIT_B     = 999               # ステータス上限値B
  #--------------------------------------------------------------------------
  # ● セットアップ　※エイリアス
  #--------------------------------------------------------------------------
  alias weapon_skill_setup setup
  def setup(actor_id)
    init_weapon_skill
    weapon_skill_setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  alias weapon_skill_refresh refresh
  def refresh
    active_skill_set if @active_change
    weapon_skill_refresh
    @active_change = false
  end
  #--------------------------------------------------------------------------
  # ● 装備の破棄
  #     item : 破棄する武器／防具
  #--------------------------------------------------------------------------
  alias weapon_discard_equip discard_equip
  def discard_equip(item)
    @active_change = true
    weapon_discard_equip(item)
    refresh
    #slot_id = equips.index(item)
    #@equips[slot_id].object = nil if slot_id
  end
  #--------------------------------------------------------------------------
  # ● 装備品の初期化
  #     equips : 初期装備の配列
  #--------------------------------------------------------------------------
  alias weapon_skill_init_equips init_equips
  def init_equips(equips)
    @active_change = true
    weapon_skill_init_equips(equips)
  end
  #--------------------------------------------------------------------------
  # ● 装備の強制変更
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  alias weapon_skill_force_change_equip force_change_equip
  def force_change_equip(slot_id, item)
    @active_change = true if !same_skill?(@equips[slot_id].object,item)
    weapon_skill_force_change_equip(slot_id, item)
  end
  #--------------------------------------------------------------------------
  # ○ 同じスキル構成か
  #--------------------------------------------------------------------------
  def same_skill?(now, new)
    if now.is_a?(RPG::Weapon) && new.is_a?(RPG::Weapon)
      now.wtype_id == new.wtype_id
    elsif now.is_a?(RPG::Armor) && new.is_a?(RPG::Armor)
      now.atype_id == new.atype_id
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ○ 武器スキルの初期化
  #--------------------------------------------------------------------------
  def init_weapon_skill
    @weapon_skill = []
    @active_skill = []
    @active_change = false
  end
  #--------------------------------------------------------------------------
  # ○ アクティブ武器スキルのセット
  #--------------------------------------------------------------------------
  def active_skill_set
    @active_skill = @weapon_skill.collect {|w_skill| $data_classes[equip_class_comvert(w_skill)] }.select {|c_data| active_weapon_skill(c_data) }
  end
  #--------------------------------------------------------------------------
  # ○ 武器スキルの選定
  #--------------------------------------------------------------------------
  def active_weapon_skill(c_data)
    return c_data ? (always_skill?(c_data.wtype) || wtype_equipped?(c_data.wtype) || c_data.atype.any? {|id| atype_equipped?(id) }) : false
  end
  #--------------------------------------------------------------------------
  # ○ アクティブ武器スキルの職業データを返す
  #--------------------------------------------------------------------------
  def weapon_skill
    @active_skill
  end
  #--------------------------------------------------------------------------
  # ○ 特定のタイプの防具を装備しているか
  #--------------------------------------------------------------------------
  def atype_equipped?(atype_id)
    armors.any? {|armor| armor.atype_id == atype_id }
    #armors.compact.any? {|armor| armor.atype_id == atype_id }
  end
  #--------------------------------------------------------------------------
  # ○ 常時発動スキルか
  #--------------------------------------------------------------------------
  def always_skill?(wtype_id)
    wtype_id == ECSystem::ALWAYS_ID
  end
  #--------------------------------------------------------------------------
  # ● スキルを覚える　※エイリアス
  #--------------------------------------------------------------------------
  alias weapon_skill_learn_skill learn_skill
  def learn_skill(skill_id)
    if !skill_learn?($data_skills[skill_id]) && $data_skills[skill_id].stype_id == ECSystem::W_S_ID
      @weapon_skill.push(ECSystem.class_id($data_skills[skill_id]))
      @active_change = true #if !@equips.empty?
      refresh
    end
    weapon_skill_learn_skill(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の加算値取得 ※エイリアス
  #--------------------------------------------------------------------------
  alias w_skill_param_plus param_plus
  def param_plus(param_id)
    w_skill_param_plus(param_id) + weapon_class_params(param_id) + weapon_class_param_plus(param_id)
  end
  #--------------------------------------------------------------------------
  # ○ 武器スキルの能力値　※スキルレベル対応
  #--------------------------------------------------------------------------
  def weapon_class_params(param_id)
    #weapon_skill.compact.inject(0) {|r, w_class| r += (w_class.params[param_id, skill_lv(w_class.skill_ni[1])] - 1)}
    weapon_skill.compact.inject(0) {|r, p_class| p_class.param_ary.include?(param_id) ? r += (p_class.params[param_id, skill_lv(p_class.skill_ni[1])]) : r }# - 1) : r }
  end
  #--------------------------------------------------------------------------
  # ○ 武器スキルの能力値特殊加算
  #--------------------------------------------------------------------------
  def weapon_class_param_plus(param_id)
    weapon_skill.compact.inject(0) {|r, p_class| p_class.wpp[param_id] ? r += (self.param(p_class.wpp[param_id][0]) * p_class.wpp[param_id][1] / 100) : r }# - 1) : r }
  end
  #--------------------------------------------------------------------------
  # ● 特徴を保持する全オブジェクトの配列取得　※エイリアス
  #--------------------------------------------------------------------------
  alias w_skill_feature_objects feature_objects
  def feature_objects
    w_skill_feature_objects + weapon_skill.compact
  end
  #--------------------------------------------------------------------------
  # ○ 装備品と装備スキル両方の取得　※エイリアス
  #--------------------------------------------------------------------------
  alias w_skill_full_equip full_equip
  def full_equip
    w_skill_full_equip + weapon_skill.compact
  end
end


class RPG::BaseItem
  def limit_break
    @limit_break ||= limit_break_set
  end
  def limit_break_set
    lb = {}
    self.note.each_line do |line|
      case line
      when /\<限界突破\:(\d+)\>/
        lb[$1.to_i] = true
      end
    end
    return lb
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
  # ● 通常能力値の最大値取得　※再定義
  #--------------------------------------------------------------------------
  def param_max(param_id)
    case param_id
    when 0,1
      return PARAM_LIMIT_A
    else
      return PARAM_LIMIT_A if param_limit_break(param_id)
      return PARAM_LIMIT_B
    end
  end
  #--------------------------------------------------------------------------
  # ○ 能力値の上限突破をしているか？
  #--------------------------------------------------------------------------
  def param_limit_break(param_id)
    full_equip.any? {|obj| obj.limit_break[param_id] }
  end
end


class Game_BaseItem
  #--------------------------------------------------------------------------
  # ● 装備品を ID で設定　※従来だと初期装備設定の際は必ずクラスが武器か防具に
  #　　なってしまいNilクラス判定ができない為、IDが0の場合はNilクラスに強制変更
  #     is_weapon : 武器かどうか
  #     item_id   : 武器／防具 ID
  #--------------------------------------------------------------------------
  alias init_fix_set_equip set_equip
  def set_equip(is_weapon, item_id)
    init_fix_set_equip(is_weapon, item_id)
    @class = nil if item_id == 0
  end
end
