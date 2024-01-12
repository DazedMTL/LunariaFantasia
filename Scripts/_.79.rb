#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 画面のフェードアウト
  #--------------------------------------------------------------------------
  def no_wait_fadeout(duration, flag = false)
    Fiber.yield while $game_message.visible
    screen.start_fadeout(duration)
    wait(duration) if flag
  end
  #--------------------------------------------------------------------------
  # ● 画面のフェードイン
  #--------------------------------------------------------------------------
  def no_wait_fadein(duration, flag = false)
    Fiber.yield while $game_message.visible
    screen.start_fadein(duration)
    wait(duration) if flag
  end
end