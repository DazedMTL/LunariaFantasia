#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # 〇 マップの手動スクロール　dir 2=>下、4=>左、6=>右、8=>上
  # a 開始点　　b 終着点　　speed 速度　　hor 横移動か？
  #--------------------------------------------------------------------------
  #def self_scroll(dir, dis, speed)
  def self_scroll(a, b, speed, hor = true)
    return if $game_party.in_battle
    Fiber.yield while $game_map.scrolling?
    dis = a - b
    return if dis == 0
    if hor
      dir = dis > 0 ? 4 : 6
    else
      dir = dis > 0 ? 8 : 2
    end
    $game_map.start_scroll(dir, dis.abs, speed)
  end
  #--------------------------------------------------------------------------
  # 〇 スクロールが終了するまで待機
  #--------------------------------------------------------------------------
  def stay_scroll
    Fiber.yield while $game_map.scrolling?
  end
end