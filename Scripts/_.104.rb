module SummonSystem
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  SUMMON_SLOT = 3             # 召喚可能最大数
  S_S_ID  = 3                 # 召喚スキルのスキルタイプID
  S_V_ID  = 2                 # ユニットIDの格納変数
  S_LV_ID = 3                 # 使用者レベルの格納変数
  S_N_ID  = 1                 # 召喚可能数を格納する変数
  BASE_HEAL  = 10             # 戦闘終了時に回復する割合のデフォルト
  ACTOR_BASE_ID  = 6          # 召喚ユニットの先頭ID。これを基準に全ての召喚ユニットIDを判別する
  RUNE_ID  = [10, 11, 12]         # 召喚ユニット用装備の防具タイプID配列
  RUNE_SHOP_SWITCH  = 32      # 召喚ユニット用装備店のスイッチ
  SUMMON_OVER_SWITCH  = 114   # 召喚システム制限緩和スイッチ

  PROHIBIT  = 8               # 召喚システム禁止スイッチ
  NO_REMOVE = 115             # 召喚ユニットを離脱させない特殊スイッチ(アネモネクエストなどで使用)
  #↑上記２つは分けているけど実質セットでスイッチを操作する必要あり
  
  Message = "%s Summoned!"      # 召喚メッセージ
  LIBERATE_S_LV   = [20, 80] # サーヴァントのスキルLvが上がる魔力解放率
  LIBERATE_SUMMON = [40, 60]  # サーヴァントの召喚可能数が増える魔力解放率
  
  SUMMON_ACTORS = [*(5..17)]  # サーヴァントアクターID配列
  #--------------------------------------------------------------------------
  # ○ スキルに対応したユニットIDの検索
  #--------------------------------------------------------------------------
  def self.summon_id(skill)
    return nil if !skill
    id = skill.summon_unit_id ? skill.summon_unit_id : nil
    return id
  end
  #--------------------------------------------------------------------------
  # ○ スキルに対応した召喚ユニットオブジェクトの検索
  #--------------------------------------------------------------------------
  def self.summon_obj(skill_id)
    id = $game_temp.summon_skills.key(skill_id)
    return nil if !id
    return $game_actors[id]
  end
  #--------------------------------------------------------------------------
  # ○ 番号から対応した召喚ユニットオブジェクトのスキルを検索
  #--------------------------------------------------------------------------
  def self.skill_search(id)
    return $data_skills[$game_temp.summon_skills[id]] if $game_temp.summon_skills[id]
    return nil
  end
  #--------------------------------------------------------------------------
  # ○ 番号から対応した召喚ユニットオブジェクトを検索
  #--------------------------------------------------------------------------
  def self.unit_search(id)
    return nil if !id
    return $game_actors[SummonSystem::ACTOR_BASE_ID + id]
  end
  #--------------------------------------------------------------------------
  # ○ 選択中のスキルが召喚か
  #--------------------------------------------------------------------------
  def self.summon_skill?
    if BattleManager.actor.input.item.is_a?(RPG::Skill)
      return BattleManager.actor.input.item.stype_id == S_S_ID
    end
    return false
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
  attr_accessor :remove_reserve                # 
  #--------------------------------------------------------------------------
  # ○ 召喚スキル
  #--------------------------------------------------------------------------
  def summon_skills
    @summon_skills ||= summon_skill_set
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def summon_skill_set
    summon = {}
    $data_skills.each do |skill|
      next if !skill
      summon[skill.summon_unit_id] = skill.id if skill.summon_unit_id
    end
    return summon
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def remove_reserve_reset
    @remove_reserve = nil
  end
end