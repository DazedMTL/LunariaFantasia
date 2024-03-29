module FAKEREAL
  
  CLEAR_SWITCH = 95 # クリアデータである事の判定スイッチ

end

#==============================================================================
# ■ Scene_Save
#------------------------------------------------------------------------------
# 　セーブ画面の処理を行うクラスです。
#==============================================================================

class Scene_ClearSave < Scene_Save
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    $game_switches[FAKEREAL::CLEAR_SWITCH] = true
  end
  #--------------------------------------------------------------------------
  # ○ 終了処理
  #--------------------------------------------------------------------------
  def terminate
    $game_switches[FAKEREAL::CLEAR_SWITCH] = false
    super
  end
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ○ クリアデータセーブ画面を開く
  #--------------------------------------------------------------------------
  def clear_save
    return if $game_party.in_battle
    SceneManager.call(Scene_ClearSave)
    Fiber.yield
  end
end