#==============================================================================
# ■ Window_TitleCommand
#------------------------------------------------------------------------------
# 　タイトル画面で、ニューゲーム／コンティニューを選択するウィンドウです。
#==============================================================================

class Window_TitleCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    update_placement
    select_symbol(:continue) if continue_enabled
    hide
    self.openness = 0
  end
  #--------------------------------------------------------------------------
  # ● カーソルの移動処理
  #--------------------------------------------------------------------------
=begin
  def process_cursor_move
    return unless cursor_movable?
    super
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
  end
=end
  #--------------------------------------------------------------------------
  # 〇 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :item_window
  #--------------------------------------------------------------------------
  # 〇 フレーム更新
  #--------------------------------------------------------------------------
  alias tm_update update
  def update
    tm_update
    @item_window.index = self.index if @item_window
  end
  #--------------------------------------------------------------------------
  # 〇 アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def item_window=(item_window)
    @item_window = item_window
    update
  end
  #--------------------------------------------------------------------------
  # ● 開く処理の更新
  #--------------------------------------------------------------------------
  def update_open
    @item_window.contents_opacity += 24 if @item_window
    #super
    self.openness += 24
    @opening = false if open?
  end
  #--------------------------------------------------------------------------
  # ● 閉じる処理の更新
  #--------------------------------------------------------------------------
  def update_close
    @item_window.contents_opacity -= 24 if @item_window
    self.openness -= 24
    @closing = false if close?
  end
end

#==============================================================================
# ■ Window_
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_TitlePict < Window_Base
  #--------------------------------------------------------------------------
  # ● 定数
  #--------------------------------------------------------------------------
  MENU     = ["Newgame_", "Continue_", "Option_", "End_"]
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor   :index                    # カーソル位置
  attr_accessor   :continue_enabled         # 
  #--------------------------------------------------------------------------
  # 〇 オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @index = -1
    @continue_enabled = false
    self.opacity = 0
    self.contents_opacity = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 300
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # 〇 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return 6
  end
  #--------------------------------------------------------------------------
  # 〇 リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    4.times {|i| draw_item(0, i * 36, i)}
  end
  #--------------------------------------------------------------------------
  # 〇 フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    refresh
  end
  #--------------------------------------------------------------------------
  # 〇 タイトルコマンド画像の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_ncoe(type, index, i, x, y, enabled = true)
    type +=  index == i ? "b" : "a"
    type = "No" + type unless enabled
    bitmap = Cache.system(type)
    rect = Rect.new(0, 0, 270, 30)
    contents.blt(x, y, bitmap, rect)#, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # 〇 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(x, y, i)
    draw_ncoe(MENU[i], self.index, i, x, y, i == 1 ? @continue_enabled : true)
  end
end


#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　タイトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias tm_create_command_window create_command_window
  def create_command_window
    tm_create_command_window
    @busy_window = Window_SaveLoading.new
    #@command_window = Window_TitleCommand.new
    @pict_window = Window_TitlePict.new(25, 280)#(100, 250)
    @command_window.item_window = @pict_window
    @pict_window.continue_enabled = @command_window.continue_enabled
    @command_window.open
  end
  
  #--------------------------------------------------------------------------
  # ● コマンド［コンティニュー］
  #--------------------------------------------------------------------------
  alias sdl_command_continue command_continue
  def command_continue
    @busy_window.show
    sdl_command_continue
    #close_command_window
    #SceneManager.call(Scene_Load)
  end
end


#==============================================================================
# ■ Window_SaveLoading
#------------------------------------------------------------------------------
# 　を表示するウィンドウです。
#==============================================================================

class Window_SaveLoading < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(Graphics.width / 2 - window_width / 2, Graphics.height / 2 - 12, window_width, fitting_height(1))
    self.opacity = 0
    hide
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 320
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_background(contents.rect)
    draw_text(contents.rect, "セーブデータ読み込み中", 1)
  end
  #--------------------------------------------------------------------------
  # ● 背景の描画
  #--------------------------------------------------------------------------
  def draw_background(rect)
    temp_rect = rect.clone
    temp_rect.width /= 2
    contents.gradient_fill_rect(temp_rect, back_color2, back_color1)
    temp_rect.x = temp_rect.width
    contents.gradient_fill_rect(temp_rect, back_color1, back_color2)
  end
  #--------------------------------------------------------------------------
  # ● 背景色 1 の取得
  #--------------------------------------------------------------------------
  def back_color1
    Color.new(0, 0, 0, 192)
  end
  #--------------------------------------------------------------------------
  # ● 背景色 2 の取得
  #--------------------------------------------------------------------------
  def back_color2
    Color.new(0, 0, 0, 0)
  end
end
