#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　ゲーム中の全てのウィンドウのスーパークラスです。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● シンプルなステータスの描画　※エイリアス
  #--------------------------------------------------------------------------
  alias tp_plus_draw_actor_simple_status draw_actor_simple_status
  def draw_actor_simple_status(actor, x, y)
    tp_plus_draw_actor_simple_status(actor, x, y)
    draw_actor_tp(actor, x + 120, y + line_height * 3)
  end
  #--------------------------------------------------------------------------
  # ● TP の描画　※再定義 汎用ゲージ追加
  #--------------------------------------------------------------------------
=begin
  def draw_actor_tp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.tp_rate, tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::tp_a)
    draw_current_and_max_values(x, y, width, actor.tp, actor.max_tp,
      tp_color(actor), normal_color)
  end
=end
  def draw_actor_tp(actor, x, y, width = 124)
    draw_actor_tp_gauge(actor, x, y, width)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::tp_a)
    draw_current_and_max_values(x, y, width, actor.tp, actor.max_tp,
      tp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # ● TP の文字色を取得　※エイリアス　TPをHPやMPと同じように扱う場合
  #--------------------------------------------------------------------------
  alias tp_color_hpmp tp_color
  def tp_color(actor)
    return crisis_color if actor.tp < actor.max_tp / 4
    tp_color_hpmp(actor)
  end
  #--------------------------------------------------------------------------
  # ● 現在値／最大値を分数形式で描画　※再定義
  #    ターゲットヘルプの敵HPに数字を表示させないようにするため
  #     current : 現在値
  #     max     : 最大値
  #     color1  : 現在値の色
  #     color2  : 最大値の色
  #--------------------------------------------------------------------------
  def draw_current_and_max_values(x, y, width, current, max, color1, color2)
    change_color(color1)
    xr = x + width
    if width == 70 # 追加
      draw_text(xr - 40, y, 42, line_height, "", 2) # 追加
    elsif width < 96
      draw_text(xr - 40, y, 42, line_height, current, 2)
    else
      draw_text(xr - 92, y, 42, line_height, current, 2)
      change_color(color2)
      draw_text(xr - 52, y, 12, line_height, "/", 2)
      draw_text(xr - 42, y, 42, line_height, max, 2)
    end
  end
end