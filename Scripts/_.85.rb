module FAKEREAL
  
  SELF_MOVABLE        = 81 #自律移動の許可スイッチ番号
  
end
#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　イベントを扱うクラスです。条件判定によるイベントページ切り替えや、並列処理
# イベント実行などの機能を持っており、Game_Map クラスの内部で使用されます。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 自律移動の更新
  #--------------------------------------------------------------------------
  alias sms_update_self_movement update_self_movement
  def update_self_movement
    sms_update_self_movement unless self_movement_stop
  end
  #--------------------------------------------------------------------------
  # 〇 自律移動の停止条件
  #--------------------------------------------------------------------------
  def self_movement_stop
    ($game_switches[FAKEREAL::EVENT_RUNNING] || $game_message.busy? || $game_message.visible) &&
     !$game_switches[FAKEREAL::SELF_MOVABLE]
  end
end
