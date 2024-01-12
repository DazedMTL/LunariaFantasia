#==============================================================================
# ■ FAKEREAL
#------------------------------------------------------------------------------
# 　オリジナルモジュール。
#==============================================================================

module FAKEREAL
  SID_V     = 20 # スキルＩＤ格納変数
end

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
#==============================================================================

class Game_Battler < Game_BattlerBase
  attr_reader   :skill_lv       # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias skill_lv_initialize initialize
  def initialize
    skill_lv_initialize
    @skill_lv = {}
  end
  #--------------------------------------------------------------------------
  # ● ダメージ計算
  #--------------------------------------------------------------------------
  alias slv_in_v_make_damage_value make_damage_value
  def make_damage_value(user, item)
    $game_variables[FAKEREAL::SID_V] = item ? item.id : 0
    slv_in_v_make_damage_value(user, item)
    $game_variables[FAKEREAL::SID_V] = 0 #計算終了後変数のリセット
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
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias slv_act_setup setup
  def setup(actor_id)
    slv_act_setup(actor_id)
    skill_lv_set
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルの初期数値
  #--------------------------------------------------------------------------
  def skill_lv_set
    actor.skill_lv_set.each {|slv|
      @skill_lv[slv[0]] = slv[1]
    }
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルの初期化
  #--------------------------------------------------------------------------
  def init_skill_lv(id)
    @skill_lv[id] = 1 if !@skill_lv[id]
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルのアップ
  #--------------------------------------------------------------------------
  def skill_lv_up(id, plus)
    @skill_lv[id] += plus if @skill_lv[id]
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルの取得
  #--------------------------------------------------------------------------
  def skill_lv(skill_id)
    return 1 if !skill_id || !@skill_lv[skill_id]
    [@skill_lv[skill_id], Learn::S_LV_MAX].min
  end
  #--------------------------------------------------------------------------
  # ● スキルを覚える　※エイリアス
  #--------------------------------------------------------------------------
  alias skill_lv_learn_skill learn_skill
  def learn_skill(skill_id)
    init_skill_lv(skill_id) unless skill_learn?($data_skills[skill_id])
    skill_lv_learn_skill(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の加算値取得 ※再定義
  #--------------------------------------------------------------------------
  #def param_plus(param_id)
    #equips.compact.inject(super) {|r, item| r += item.params[param_id] } + 
     #equip_class.compact.inject(0) {|r, s_class| r += (s_class.params[param_id, skill_lv(s_class.skill_ni[1])] - 1)}#(ECSystem.skill_id(s_class.id))] - 1)}
  #end
end

class RPG::Actor < RPG::BaseItem
  def skill_lv_set
    slv = []
    self.note.each_line do |line|
      case line
      when /\<初期スキルLv:(\d+),(\d+)\>/
        slv.push([$1.to_i, $2.to_i])
      end
    end
    return slv
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
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias enemy_skill_initialize initialize
  def initialize(index, enemy_id)
    enemy_skill_initialize(index, enemy_id)
    fix_slv_set
    fluctuation_slv_set
  end
  #--------------------------------------------------------------------------
  # ○ 固定スキルレベルのセット
  #--------------------------------------------------------------------------
  def fix_slv_set
    #@fix_slv = []
    #@fix_slv = {}
    enemy.note.each_line do |line|
      case line
      when /\<固定スキル:(\d+)\s?(\d?)\>/
        @skill_lv[$1.to_i] = $2.to_i != 0 ? $2.to_i : 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ 変動スキルレベルのセット
  #--------------------------------------------------------------------------
  def fluctuation_slv_set
    #@fix_slv = []
    #@fix_slv = {}
    enemy.note.each_line do |line|
      case line
      when /\<変動スキル:(\d+)\s\[(\d+)\,(\d+)\,(\d+)\]\>/
        #@fix_slv.push($1.to_i)
        slv = 1
        slv += 1 if @level >= $2.to_i
        slv += 1 if @level >= $3.to_i
        slv += 1 if @level >= $4.to_i
        @skill_lv[$1.to_i] = slv
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルの取得
  #--------------------------------------------------------------------------
  def skill_lv(skill_id)
    #return 1 if @fix_slv.include?(skill_id)
    return @skill_lv[skill_id] if @skill_lv[skill_id]
    @enemy_skill_lv ||= esl_set
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルのセット
  #--------------------------------------------------------------------------
  def esl_set
    eslv = 1
    #ary = enemy.note =~ /\<スキルLv:(\d+)?\,?(\d+)?\,?(\d+)?\>/ ? [$1.to_i, $2.to_i, $3.to_i] : []
    ary = enemy.note =~ /\<スキルLv:(\d+),(\d+),(\d+)\>/ ? [$1.to_i, $2.to_i, $3.to_i] : [@base_level + 10, @base_level + 25, @base_level + 40]
    ary.each {|lv| eslv += 1 if lv != 0 && @level >= lv}
    return eslv
  end
end

class RPG::UsableItem::Damage
  #--------------------------------------------------------------------------
  # ○ スキルレベル反映の共通計算式
  #--------------------------------------------------------------------------
  def skill_lv_attack(s_id)
    "(a.skill_lv(#{s_id}) - 1)"
  end
  #--------------------------------------------------------------------------
  # ○ 計算式の文字列置き換え　※再定義
  #--------------------------------------------------------------------------
  alias skill_lv_change_formula change_formula
  def change_formula
    result = skill_lv_change_formula
    result.gsub!(/s_lv/i)  { skill_lv_attack($game_variables[FAKEREAL::SID_V]) }
    result
  end
end

#==============================================================================
# ■ Window_SkillList
#------------------------------------------------------------------------------
# 　スキル画面で、使用できるスキルの一覧を表示するウィンドウです。
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if skill
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(skill, rect.x, rect.y, enable?(skill))
      draw_skill_cost(rect, skill)
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画　※オーバーライド
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 196)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    star = ""
    @actor.skill_lv(item.id).times do |i|
      star += "★" unless i == 0
    end
    #draw_text(x + 24, y, width, line_height, item.name + "　Lv#{@actor.skill_lv(item.id)}")
    if $game_system.skill_lv_visible && item.lvup_able? #note =~ /\<スキルレベルAP:(\d+),(\d+)\>/
      draw_text(x + 24, y, width, line_height, item.name + " #{star}")
    else
      draw_text(x + 24, y, width, line_height, item.name)
    end
  end
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
  attr_accessor :skill_lv_visible  # スキルアップ画面以外でスキルLvを表示するか？
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias slvv_initialize initialize
  def initialize
    slvv_initialize
    @skill_lv_visible = true
  end
end

class RPG::Skill < RPG::UsableItem
  def lvup_able?
    Learn.lvup_point(self)
  end
end

class RPG::Skill < RPG::UsableItem
=begin
  def summon_actor
    @summon_actor ||= actor_set
  end
  def actor_set
    summon_unit_id ? $game_actors[summon_unit_id] : nil
  end
=end
  def base
    @base ||= base_set
  end
  def plus
    @plus ||= plus_set
  end
  def magni?
    self.note =~ /\<倍率計算\>/
  end
  def base_set
    self.note =~ /\<BASE\:(\d+)\>/ ? (magni? ? ($1.to_i * 0.01).round(2) : $1.to_i) : 0 #$1.to_i * (magni? ? 0.01 : 1) : 0
  end
  def plus_set
    self.note =~ /\<PLUS\:(\d+)\>/ ? (magni? ? ($1.to_i * 0.01).round(2) : $1.to_i) : 0 #$1.to_i * (magni? ? 0.01 : 1) : 0
  end
end

class RPG::UsableItem::Damage
  def base(id)
    @base ||= base_set(id)
  end
  def plus(id)
    @plus ||= plus_set(id)
  end
  def base_set(id)
    $data_skills[id].base
  end
  def plus_set(id)
    $data_skills[id].plus
  end
  #--------------------------------------------------------------------------
  # ○ 計算式の文字列置き換え
  #--------------------------------------------------------------------------
  alias base_plus_change_formula change_formula
  def change_formula
    result = base_plus_change_formula
    result.gsub!(/base/i)  { base($game_variables[FAKEREAL::SID_V]) }
    result.gsub!(/plus/i)  { plus($game_variables[FAKEREAL::SID_V]) }
    result
  end
end
