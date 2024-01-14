#==============================================================================
# ■ Game_Actors
#------------------------------------------------------------------------------
# 　アクターの配列のラッパーです。このクラスのインスタンスは $game_actors で参
# 照されます。
#==============================================================================

class Game_Actors
  #--------------------------------------------------------------------------
  # ● アクターの取得　※再定義
  #--------------------------------------------------------------------------
  def [](actor_id)
    return nil unless $data_actors[actor_id]
    #@data[actor_id] ||= SUMMON_ACTORS.include?(actor_id) ? Game_Servant.new(actor_id) : Game_Actor.new(actor_id)
    @data[actor_id] ||= SummonSystem::SUMMON_ACTORS.include?(actor_id) ? Game_Servant.new(actor_id) : Game_Actor.new(actor_id)
  end
end

#==============================================================================
# ■ Game_Servant
#------------------------------------------------------------------------------
# 　召喚アクターを扱うクラスです。
#　 このクラスの基本的な扱いは Game_Actorクラスと同じになります。
#==============================================================================

class Game_Servant < Game_Actor
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットは死亡と同時に消滅
  #--------------------------------------------------------------------------
  def summon_death
    summon_remove if death_state? && !$game_party.summon_no_remove
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットか
  #--------------------------------------------------------------------------
  def summon_type?
    return true #actor.note.include?("<召喚ユニット>")
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def bonus_text
    SummonSystem::BONUS_TEXT[@actor_id]
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def bonus_class_number
    if actor.note =~ /\<ボーナスクラス:(\d+)\>/
      return $1.to_i
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def bonus_class
    $game_actors[1].pp >= 100 ? [$data_classes[bonus_class_number]].compact : []
  end
  #--------------------------------------------------------------------------
  # ○ アクティブ武器スキルの職業データを返す
  #--------------------------------------------------------------------------
  def weapon_skill
    super + bonus_class
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘終了後の回復率
  #--------------------------------------------------------------------------
  def heal_rate
    rate = 0
    if actor.note =~ /\<戦闘終了後回復率:(\d+)\>/
      rate += $1.to_i
    else
      rate += SummonSystem::BASE_HEAL
    end
    rate += (heal_lv_rate($game_actors[1].pp)).to_i
    [full_equip.inject(rate) {|r, full_e| r += full_e.heal_rate_plus }, 1].max
  end
  #--------------------------------------------------------------------------
  # ○ 回復値の上昇　
  #--------------------------------------------------------------------------
  def heal_lv_rate(base)
    return [(base / 10), 10].min
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの消滅
  #--------------------------------------------------------------------------
  def summon_remove
    $game_party.remove_actor(@actor_id)
  end
  #--------------------------------------------------------------------------
  # ○ 割合回復　※改修時に追加
  #--------------------------------------------------------------------------
  def summon_heal(rate)
    rate += heal_rate
    @hp = 1 if dead?
    @hp += mhp * rate / 100
    @mp += mmp * rate / 100
    @tp += max_tp * rate / 100
    clear_states
    clear_buffs
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 次に覚える予定のスキル配列
  #--------------------------------------------------------------------------
  def next_skills
    #@next_skills ||= next_skills_set
    $game_temp.next_skills[@actor_id] ||= next_skills_set
  end
  #--------------------------------------------------------------------------
  # ○ 次に覚える予定のスキル配列設定　３つまで
  #--------------------------------------------------------------------------
  def next_skills_set
    ns = []
    all = self.class.learnings.select {|learn| learn.level > level }
    all.each_with_index do |skill, i|
      ns.push(skill)
      break if i == 2
    end
    return ns
  end
  #--------------------------------------------------------------------------
  # ● レベルアップ
  #--------------------------------------------------------------------------
  def level_up
    super
    #@next_skills = next_skills_set
    $game_temp.next_skills[@actor_id] = next_skills_set
  end
  #--------------------------------------------------------------------------
  # ● 逃げる
  #--------------------------------------------------------------------------
  def escape
    summon_remove
  end
  #--------------------------------------------------------------------------
  # ○ ガッツ無しの戦闘不能　※召喚ユニットは死亡と同時にMP・TPが０になる
  #--------------------------------------------------------------------------
  def no_guts_die
    @mp = @tp = 0 if !$game_party.summon_no_remove
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットの配列を取得
  #--------------------------------------------------------------------------
  def equip_slots
    return [4,4,4,0,0,2,3] if dual_wield?       # 二刀流
    return [4,4,4,0,1,2,3]                      # 通常
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットのレベルの変更　※改修
  #--------------------------------------------------------------------------
  def summon_level_set(level)
    return if @level == level
    level = [[level, max_level].min, 1].max
    change_exp(exp_for_level(level), false)
  end
  #--------------------------------------------------------------------------
  # 〇 スキルを覚える
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    if !skill_learn?($data_skills[skill_id]) && $data_skills[skill_id].stype_id == ECSystem::EC_S_ID
      @equip_class.each_with_index do |obj, i|
        if obj.is_nil?
          equip_classchange(i, $data_skills[skill_id])
          break
        end
      end
    end
    super(skill_id)
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルの取得　※スキルレベルを召喚ユニットにも反映
  #--------------------------------------------------------------------------
  def summon_skill_lv_set
    plus = 1
    plus += 1 if $game_actors[1].pp >= SummonSystem::LIBERATE_S_LV[0]
    plus += 1 if $game_actors[1].pp >= SummonSystem::LIBERATE_S_LV[1]
    full_equip.inject(plus) {|r, item| r += item.slv_plus }
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルの取得　※スキルレベルを召喚ユニットにも反映
  #--------------------------------------------------------------------------
  def skill_lv(skill_id)
    return 1 if skill_id == 0 || !$data_skills[skill_id].lvup_able?
    slv = summon_skill_lv_set
    slv += actor.slv_plus
    return [slv, Learn::S_LV_MAX].min
  end
  #--------------------------------------------------------------------------
  # ● 経験値の獲得（経験獲得率を考慮）　召喚ユニットは経験値を獲得せず
  #--------------------------------------------------------------------------
  def gain_exp(exp)
  end
  #--------------------------------------------------------------------------
  # ○ 解放率による召喚ユニットの能力値の上昇　全ステータス
  #--------------------------------------------------------------------------
  def liberate_summon_point(param_id)
    #($game_variables[FAKEREAL::LIBERATE] * (@sg_base[param_id] * liberate_lv_point(param_id))).to_i
    ($game_actors[1].pp * (actor.summon_growth[param_id] * liberate_lv_point(param_id))).to_i
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の基本値取得
  #--------------------------------------------------------------------------
  def param_base(param_id)
    super(param_id) + liberate_summon_point(param_id)
  end
  #--------------------------------------------------------------------------
  # ● TP の最大値を取得　※追加　※エイリアス
  #--------------------------------------------------------------------------
  def max_tp
    super + liberate_summon_point(8)
  end
  #--------------------------------------------------------------------------
  # ● 防具装備可能の判定
  #--------------------------------------------------------------------------
  #def equip_atype_ok?(atype_id)
    #super || SummonSystem::RUNE_ID.include?(atype_id)
  #end
  #--------------------------------------------------------------------------
  # ○ 召喚可能枠の追加 ※サーヴァントには必要ない為0を返す
  #--------------------------------------------------------------------------
  def summon_plus
    return 0
  end
  #--------------------------------------------------------------------------
  # ○ ※スキル確認用
  #--------------------------------------------------------------------------
  def skills_disp
    @skills
  end
end

module SummonSystem
  BONUS_TEXT = Hash[
    5 => "Ice/Dark Magic Aptitude +20: Negates weakness element\nIce/Dark Resistance +: Charm chance increase for '\edb[s,545]'",#Anemone
    6 => "Physical Damage Dealt 1.2x\n'\ei[50]' Full Ailment Guard",#Fencer
    7 => "\epr[0] 1.2x\nHP 100% on revival with skill '\edb[s,307]'",#Defender
    8 => "Healing Magic Aptitude +10\n\epr[1] 1.2x",#Healer
    9 => "Fire/Ice/Thunder Magic Aptitude +10\n\epr[1] 1.2x",#Elem
    10 => "Evasion Rate +5; Magic Evasion Rate +10\n\e}\epr[6] 1.2x: Base success rate of stealing 1.5x\e{",#Thief
    11 => "\epr[0]・\epr[1] 1.05x\nAll Damage Reduced by 10%",#Bachelor
    12 => "Fire Magic Aptitude +20: Light Magic Aptitude +5\nIce Damage Reduction",#Ifrit
    13 => "Fire Damage Reduction\n\epr[2]・\epr[6] 1.2x",#Fenrir
    14 => "Ice/Light Damage Slight Reduction\nThunder Magic Aptitude +20",#Nue
    15 => "Light Magic Aptitude +20: Healing Magic Aptitude +5\nDark Damage Reduction",#Unicorn
    16 => "Dark Magic Aptitude +20\nLight & \edb[el,7] Damage Reduction",#Baikorn
    17 => "\edb[st,2], \edb[st,7] Nullification & Other Status Resistances (Medium)\nLight & Dark Damage Slight Reduction",#Nidhogg
  ]

  HEAL_ITEM = "<サーヴァント回復>"  # サーヴァントの回復アイテムノートコメント

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
  attr_accessor :next_skills                # アクターが次に覚えるスキルの配列
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias next_skills_initialize initialize
  def initialize
    next_skills_initialize
    @next_skills = {}
  end
end