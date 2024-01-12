#==============================================================================
# ■ Window_SaveFile
#------------------------------------------------------------------------------
# 　セーブ画面およびロード画面で表示する、セーブファイルのウィンドウです。
#==============================================================================

class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :header                 # 外部呼出し用
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※再定義
  #     index : セーブファイルのインデックス
  #--------------------------------------------------------------------------
  def initialize(height, index)
    super(0, index * height, window_width, height)
    @file_index = index
    self.opacity = 0 #追加
    @header = nil #追加
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # ○ ヘッダのセット
  #--------------------------------------------------------------------------
  def header_set
    @header = DataManager.load_header(@file_index)
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width - 260
  end
  #--------------------------------------------------------------------------
  # ○ 日付幅
  #--------------------------------------------------------------------------
  def day_width
    return 100
  end
  #--------------------------------------------------------------------------
  # ○ ファイルナンバー幅
  #--------------------------------------------------------------------------
  def no_width
    return 60
  end
  #--------------------------------------------------------------------------
  # ○ マップ名幅
  #--------------------------------------------------------------------------
  def map_width
    return contents.width - day_width - no_width - 4 * 6
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ　※再定義
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_background(contents.rect)
    change_color(normal_color)
    header_set
    name = Vocab::File + "#{@file_index + 1}"
    draw_text(4, 0, no_width, line_height, name)
    @name_width = text_size(name).width
    draw_savemap(no_width + 8, contents.height - line_height, map_width, 1)
    draw_savetime(contents.width - day_width - 4, contents.height - line_height, day_width, 2)
  end
  #--------------------------------------------------------------------------
  # ○ セーブしたマップの描画
  #--------------------------------------------------------------------------
  def draw_savemap(x, y, width, align)
    #header = DataManager.load_header(@file_index)
    return unless @header
    draw_text(x, y, width, line_height, @header[:save_map], 1)
  end
  #--------------------------------------------------------------------------
  # ○ セーブした日付の描画
  #--------------------------------------------------------------------------
  def draw_savetime(x, y, width, align)
    #header = DataManager.load_header(@file_index)
    return unless @header
    draw_text(x, y, width, line_height, @header[:save_time], 2)
  end
  #--------------------------------------------------------------------------
  # ● カーソルの更新　※再定義
  #--------------------------------------------------------------------------
  def update_cursor
    if @selected
      cursor_rect.set(0, 0, contents_width, contents_height)#@name_width + 8, line_height)
    else
      cursor_rect.empty
    end
  end
  #--------------------------------------------------------------------------
  # ● 背景の描画
  #--------------------------------------------------------------------------
  def draw_background(rect)
    temp_rect = rect.clone
    temp_rect.width /= 2
    #contents.fill_rect(rect, back_color1)
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
  #--------------------------------------------------------------------------
  # ● 標準パディングサイズの取得
  #--------------------------------------------------------------------------
  def standard_padding
    return 2
  end
end

#==============================================================================
# ■ Window_SaveInfo
#------------------------------------------------------------------------------
# 　セーブ画面およびロード画面で表示する、セーブファイルのウィンドウです。
#==============================================================================

class Window_SaveInfo < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #     index : セーブファイルのインデックス
  #--------------------------------------------------------------------------
  def initialize
    super(Graphics.width - window_width, 0, window_width, Graphics.height)
    @header = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅
  #--------------------------------------------------------------------------
  def window_width
    return 260
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    #draw_text(4, 0, 200, line_height, name)
    draw_chapter(0, 0, contents.width - 4, 1)
    draw_party_members(35, line_height * 1)
    draw_party_characters(contents.height - line_height * 3 + 24)
    draw_liberate(0, contents.height - line_height * 2, contents.width - 4, 1)
    draw_playtime(0, contents.height - line_height, contents.width - 4, 1)
  end
  #--------------------------------------------------------------------------
  # ○ パーティメンバーの描画
  #--------------------------------------------------------------------------
  def draw_party_members(x, y)
    return unless @header
    padding = [156 - (@header[:members].size - 1) * 55, 0].max
    @header[:members].each_with_index do |data, i|
      draw_face(data[0], data[1], x, padding + y + i * 104)# + i % 2 * 106, y + i / 2 * 116)
      draw_actor_info(data[2], data[3], x + 100, padding + y + i * 104)# + i % 2 * 106, y + i / 2 * 116)
    end
  end
  #--------------------------------------------------------------------------
  # 〇 パーティキャラの描画
  #--------------------------------------------------------------------------
  def draw_party_characters(y)
    return unless @header
    return if !@header[:characters]
    x = contents.width / 2 - 24 * (@header[:characters].size - 1)
    @header[:characters].each_with_index do |data, i|
      draw_character(data[0], data[1], x + i * 48, y)
    end
  end
  #--------------------------------------------------------------------------
  # ○ キャラ情報の描画
  #--------------------------------------------------------------------------
  def draw_actor_info(name, level, x, y, width = 112)
    change_color(normal_color)
    draw_text(x, y, width, line_height, name)
    change_color(system_color)
    draw_text(x, y + 32, 32, line_height, Vocab::level_a)
    change_color(normal_color)
    draw_text(x + 32, y + 32, 24, line_height, level, 2)
  end
  #--------------------------------------------------------------------------
  # ○ チャプター名の描画
  #--------------------------------------------------------------------------
  def draw_chapter(x, y, width, align)
    return unless @header
    return if !@header[:chapter]
    c_copy = @header[:chapter].clone
    number = c_copy.slice!(/^.+?章/)
    c_copy.slice!(/^\S/)
    change_color(important_color)
    draw_text(x, y, width, line_height, number, align)
    draw_text(x, y + line_height, width, line_height, c_copy, align)
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ○ 魔力解放率の描画
  #--------------------------------------------------------------------------
  def draw_liberate(x, y, width, align)
    return unless @header
    return if !@header[:draw_flag]
    draw_text(x, y, width, line_height, "#{FAKEREAL::KEYWORD[0][0]} #{@header[:liberate]}％", align)
  end
  #--------------------------------------------------------------------------
  # ○ プレイ時間の描画
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
    return unless @header
    if @header[:game_clear]
      star = @header[:game_clear] >= 1 ? (@header[:game_clear] == 1 ? "★" : "★x#{@header[:game_clear]}") : ""
      draw_text(x, y, width, line_height, star + "プレイ時間 " + @header[:playtime_s], align)
    else
      draw_text(x, y, width, line_height, "プレイ時間 " + @header[:playtime_s], align)
    end
  end
  #--------------------------------------------------------------------------
  # ○ ヘッダの設定
  #--------------------------------------------------------------------------
  def header=(header)
    @header = header
    refresh
  end
end

#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　スキルやアイテムの説明、アクターのステータスなどを表示するウィンドウです。
#==============================================================================

class Window_SaveHelp < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(line_number = 2)
    super(0, 0, window_width, fitting_height(line_number))
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width - 260
  end
  #--------------------------------------------------------------------------
  # ○ テキスト設定
  #--------------------------------------------------------------------------
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ○ クリア
  #--------------------------------------------------------------------------
  def clear
    set_text("")
  end
  #--------------------------------------------------------------------------
  # ○ アイテム設定
  #     item : スキル、アイテム等
  #--------------------------------------------------------------------------
  def set_item(item)
    set_text(item ? item.description : "")
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_text_ex(4, 0, @text)
  end
end

#==============================================================================
# ■ Scene_File
#------------------------------------------------------------------------------
# 　セーブ画面とロード画面の共通処理を行うクラスです。
#==============================================================================

class Scene_File < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理　※再定義
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_savefile_viewport
    create_savefile_windows
    create_saveinfo_window
    init_selection
  end
  #--------------------------------------------------------------------------
  # ● 終了処理　※再定義　viewport解放済みの対策としてwindowsとviewportの解放順を入れ替えただけ
  #--------------------------------------------------------------------------
  def terminate
    super
    @savefile_windows.each {|window| window.dispose }
    @savefile_viewport.dispose
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成　※再定義
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_SaveHelp.new(1)
    @help_window.set_text(help_window_text)
  end
  #--------------------------------------------------------------------------
  # ○ セーブインフォウィンドウの作成
  #--------------------------------------------------------------------------
  def create_saveinfo_window
    @saveinfo_window = Window_SaveInfo.new
  end
  #--------------------------------------------------------------------------
  # ● 画面内に表示するセーブファイル数を取得　※再定義
  #--------------------------------------------------------------------------
  def visible_max
    return 8
  end
  #--------------------------------------------------------------------------
  # ● 選択状態の初期化　※再定義
  #--------------------------------------------------------------------------
  def init_selection
    @index = first_savefile_index
    @savefile_windows[@index].selected = true
    self.top_index = @index - visible_max / 2
    @saveinfo_window.header = @savefile_windows[@index].header #追加
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # ● カーソルの更新　※再定義
  #--------------------------------------------------------------------------
  def update_cursor
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_pagedown   if Input.trigger?(:R)
    cursor_pageup     if Input.trigger?(:L)
    if @index != last_index
      Sound.play_cursor
      @savefile_windows[last_index].selected = false
      @savefile_windows[@index].selected = true
      @saveinfo_window.header = @savefile_windows[@index].header #追加
    end
  end
end