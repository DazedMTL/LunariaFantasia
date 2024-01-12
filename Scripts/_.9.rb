#==============================================================================
# ★ RGSS3-Extension
# LNX25_ゲーム画面倍率切替
# 　ゲーム中、F5 キーでゲーム画面の表示倍率を切り替えます。
#
# 　version   : 1.00 (12/02/27)
# 　author    : ももまる
# 　reference : http://peachround.blog.fc2.com/blog-entry-20.html
#
#==============================================================================
=begin
module LNX25
  #--------------------------------------------------------------------------
  # ● 切替キー
  #--------------------------------------------------------------------------
  RESIZE_KEY = :F5 # 規定値: :F5
  RESIZE_ZOOM = 0.25 # ※追加
  ZOOM_MAX = 2.25 # ※追加
end

#==============================================================================
# ■ LNXスクリプト導入情報
#==============================================================================
$lnx_include = {} if $lnx_include == nil
$lnx_include[:lnx25] = 100 # version
p "OK:LNX25_ウィンドウサイズ変更"

#==============================================================================
# ■ Graphics
#==============================================================================
module Graphics
  @screen_zoom = 1
  #--------------------------------------------------------------------------
  # ● ゲーム画面の表示倍率取得
  #--------------------------------------------------------------------------
  def self.screen_zoom
    @screen_zoom
  end
  #--------------------------------------------------------------------------
  # ● ゲーム画面の表示倍率変更
  #--------------------------------------------------------------------------
  def self.screen_zoom=(rate)
    self.rgssplayer_resize(rate)
    @screen_zoom = rate
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウハンドルの取得(Win32API)
  #--------------------------------------------------------------------------
  def self.rgssplayer
    Win32API.new("user32", "FindWindow", "pp", "i").call("RGSS Player", 0)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウのリサイズ(Win32API)
  #--------------------------------------------------------------------------
  def self.rgssplayer_resize(rate)
    move_w = Win32API.new("user32", "MoveWindow", "liiiil", "l")
    get_sm = Win32API.new("user32", "GetSystemMetrics", "i", "i")
    # サイズ計算
    frame_w   = get_sm.call(7) * 2 # ウィンドウ枠(横方向)
    frame_h   = get_sm.call(8) * 2 # ウィンドウ枠(縦方向)
    caption_h = get_sm.call(4)     # タイトルバーの高さ
    width  = self.width  * rate + frame_w
    height = self.height * rate + frame_h + caption_h
    x = (get_sm.call(0) - width ) / 2
    y = (get_sm.call(1) - height) / 2
    # ウィンドウ位置・サイズ変更(ウィンドウ, X, Y, 幅, 高さ, 更新フラグ)
    move_w.call(self.rgssplayer, x, y, width, height, 1)
  end
end
class << Graphics
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias :lnx25_update :update
  def update
    # 元のメソッドを呼ぶ
    lnx25_update
    # F5 キーが押されたらリサイズ
    if Input.trigger?(LNX25::RESIZE_KEY)
      if self.screen_zoom >= LNX25::ZOOM_MAX
        self.screen_zoom = 1
      else
        self.screen_zoom += LNX25::RESIZE_ZOOM
      end
#=begin
      self.screen_zoom = (self.screen_zoom == 1 ? 2 : 1)
#=end
    end
  end
end
=end

#==============================================================================
# ★ RGSS3-Extension
# LNX25_ゲーム画面倍率切替
# 　ゲーム中、F5 キーでゲーム画面の表示倍率を切り替えます。
#
# 　version   : 1.01 (16/1/10)
# 　author    : ももまる
# 　website   : http://peachround.com/
# 　license   : http://creativecommons.org/licenses/by/2.1/jp/
#
#==============================================================================

module LNX25
  #--------------------------------------------------------------------------
  # ● 最大ズーム倍率
  #--------------------------------------------------------------------------
  MAX_SCREEN_ZOOM = 0 # 規定値: 0 (0:自動 1以上:任意の最大ズーム倍率)
  #--------------------------------------------------------------------------
  # ● 切替キー
  #--------------------------------------------------------------------------
  RESIZE_KEY = :F5 # 規定値: :F5
end

#==============================================================================
# ■ LNXスクリプト導入情報
#==============================================================================
$lnx_include = {} if $lnx_include == nil
$lnx_include[:lnx25] = 101 # version
p "OK:LNX25_ウィンドウサイズ変更"

#==============================================================================
# ■ Graphics
#==============================================================================
module Graphics
  @screen_zoom = 1
  #--------------------------------------------------------------------------
  # ● ゲーム画面の表示倍率取得
  #--------------------------------------------------------------------------
  def self.screen_zoom
    @screen_zoom
  end
  #--------------------------------------------------------------------------
  # ● ゲーム画面の表示倍率変更
  #--------------------------------------------------------------------------
  def self.screen_zoom=(rate)
    if rate - 1 > (LNX25::MAX_SCREEN_ZOOM == 0 ?
               self.max_screen_zoom : LNX25::MAX_SCREEN_ZOOM - 1).truncate
      rate = 1
    end
    self.rgssplayer_resize(rate)
    @screen_zoom = rate
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウサイズ情報
  #--------------------------------------------------------------------------
  def self.window_frame_size
    get_sm = Win32API.new("user32", "GetSystemMetrics", "i", "i")
    frame_width    = get_sm.call(7) * 2 # ウィンドウ枠(横方向)
    frame_height   = get_sm.call(8) * 2 # ウィンドウ枠(縦方向)
    caption_height = get_sm.call(4)     # タイトルバーの高さ
    return [frame_width, frame_height, caption_height]
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウのリサイズ
  #--------------------------------------------------------------------------
  def self.rgssplayer_resize(rate)
    wfs = self.window_frame_size
    rate = [rate, self.max_screen_zoom].min
    width  = self.width  * rate + wfs[0]
    height = self.height * rate + wfs[1] + wfs[2]
    workarea = display_workarea
    x = (workarea[2] - width)  / 2 + workarea[0] / 2
    y = (workarea[3] - height) / 2 + workarea[1] / 2
    # ウィンドウ位置・サイズ変更(ウィンドウ, X, Y, 幅, 高さ, 更新フラグ)
    move_w = Win32API.new("user32", "MoveWindow", "liiiil", "l")
    h = Win32API.new("user32", "FindWindow", "pp", "i").call("RGSS Player", 0)
    move_w.call(h, x, y, width, height, 1)
  end
  #--------------------------------------------------------------------------
  # ● ゲーム画面の最大表示倍率取得
  #--------------------------------------------------------------------------
  def self.max_screen_zoom
    wfs = self.window_frame_size
    workarea = display_workarea
    screen_w = workarea[2] - workarea[0] - wfs[0]
    screen_h = workarea[3] - workarea[1] - wfs[1] - wfs[2]
    max_zoom_width  = [screen_w.to_f / self.width,  1].max
    max_zoom_height = [screen_h.to_f / self.height, 1].max
    return [max_zoom_width, max_zoom_height].min
  end
  #--------------------------------------------------------------------------
  # ● ディスプレイのワークエリア取得
  #--------------------------------------------------------------------------
  def self.display_workarea
    workarea = Win32API.new("user32", "SystemParametersInfoA", "llp", "l")
    rect = "    " * 4
    a = workarea.call(48, 0, rect)
    rect_array = rect.unpack('l4')
    return rect_array
  end
end

class << Graphics
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias :lnx25_update :update
  def update
    # 元のメソッドを呼ぶ
    lnx25_update
    # F5 キーが押されたらリサイズ
    if Input.trigger?(LNX25::RESIZE_KEY)
      self.screen_zoom += 1
    end
  end
end
