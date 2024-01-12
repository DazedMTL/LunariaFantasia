#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#　※どうしてもこの処理のみXPスタイルバトルの下に記述する必要あり
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理　※エイリアス　戦闘開始時に召喚ユニット加入
  #--------------------------------------------------------------------------
  alias summon_add_start start
  def start
    $game_party.summon_actor_set if $game_party.summon_enabled
    summon_add_start
  end
  #--------------------------------------------------------------------------
  # ● 終了処理　※エイリアス　戦闘終了時に召喚ユニット離脱
  #--------------------------------------------------------------------------
  alias summon_remove_terminate terminate
  def terminate
    summon_remove_terminate
    $game_party.summon_reset
    BattleManager.revive_battle_members # 戦闘終了時に戦闘不能者は復活
    end_eating($game_party.leader, $game_party.battle_eat) if eating? # 食事実行
  end
end

