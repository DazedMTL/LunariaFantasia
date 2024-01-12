#==============================================================================
# □ Window_Liberate
#------------------------------------------------------------------------------
# 　魔力解放率を表示するウィンドウです。
#==============================================================================

class Window_Liberate < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(4))
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_sex_point($game_variables[FAKEREAL::SEX_POINT], 0, line_height * 0, contents.width - 8)
    draw_horz_line(line_height * 1)
    draw_liberate_point($game_variables[FAKEREAL::LIBERATE], 0, line_height * 2, contents.width - 8)
  end
  #--------------------------------------------------------------------------
  # 〇 水平線の描画
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # 〇 水平線の色を取得
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # ○ 魔力解放率の描画
  #--------------------------------------------------------------------------
  def draw_liberate_point(liberate, x, y, width, align = 0)
    #l_width = 94
    change_color(system_color)
    #draw_text(x, y, l_width, line_height, "#{FAKEREAL::KEYWORD[0][0]}", 0)
    draw_text(x + 4, y, width, line_height, "#{FAKEREAL::KEYWORD[0][0]}", align)
    change_color(normal_color)
    #draw_text(4 + l_width, y, width - l_width, line_height * 2 , "#{liberate}％", align)
    draw_currency_value(liberate, "％", 4, y + line_height, width)
    #draw_text(x, line_height, width - 4, line_height , "#{liberate}％", align)
  end
  #--------------------------------------------------------------------------
  # ○ 淫性値の描画
  #--------------------------------------------------------------------------
  def draw_sex_point(sex, x, y, width, align = 0)
    change_color(system_color)
    draw_text(x + 4, y, width, line_height, "#{FAKEREAL::SEX_POINT_NAME}")
    change_color(normal_color)
    #draw_currency_value(sex, "　", 4, y, width)
    draw_text(x + 4, y, width - 19, line_height, sex, 2)
  end
end

#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　メニュー画面の処理を行うクラスです。
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias liberate_start start
  def start
    liberate_start
    create_liberate_window
  end
  #--------------------------------------------------------------------------
  # ○ 魔力解放率ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_liberate_window
    @liberate_window = Window_Liberate.new
    #@liberate_window.x = @gold_window.width + @nowmap_window.width
    @liberate_window.y = Graphics.height - @liberate_window.height - @gold_window.height
    #@liberate_window.contents_opacity = 0 unless $game_switches[FAKEREAL::LIBERATE_OPACITY]
    @liberate_window.visible = false unless $game_switches[FAKEREAL::LIBERATE_OPACITY]
  end
end
