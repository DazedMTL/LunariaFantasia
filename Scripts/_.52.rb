#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは $game_system で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader     :h_event                   # エッチEV中判定
  attr_accessor   :window_change             # ウィンドウ変更判定
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias h_event_initialize initialize
  def initialize
    h_event_initialize
    @h_event = false
    @window_change = false
  end
  #--------------------------------------------------------------------------
  # ○ エッチイベントON
  #--------------------------------------------------------------------------
  def h_on
    @h_event = true
    @window_change = true
  end
  #--------------------------------------------------------------------------
  # ○ エッチイベントOFF
  #--------------------------------------------------------------------------
  def h_off
    @h_event = false
    @window_change = true
    #$game_party.message_auto_mode = false if !$game_switches[FAKEREAL::EVENT_RUNNING] # メッセージ関連追加
    $game_temp.shot_init
    $game_switches[Option::EXH_SWF] = false
    $game_switches[Option::EXH_SWS] = false
    $game_switches[Option::EXH_SWB] = false
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
  # ○ エッチ開始
  #--------------------------------------------------------------------------
  def h_on
    $game_system.h_on
  end
  #--------------------------------------------------------------------------
  # ○ エッチ終了
  #--------------------------------------------------------------------------
  def h_off
    $game_system.h_off
  end
  #--------------------------------------------------------------------------
  # ● 文章の表示　※再定義
  #--------------------------------------------------------------------------
=begin
  def command_101
    wait_for_message
    $game_message.face_name = @params[0]
    $game_message.face_index = @params[1]
    if $game_system.h_event
      $game_message.background = 1
    else
      $game_message.background = @params[2]
    end
    $game_message.position = @params[3]
    while next_event_code == 401       # 文章データ
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    case next_event_code
    when 102  # 選択肢の表示
      @index += 1
      setup_choices(@list[@index].parameters)
    when 103  # 数値入力の処理
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 104  # アイテム選択の処理
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    wait_for_message
  end
=end
end

#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　文章表示に使うメッセージウィンドウです。
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ● 背景色 1 の取得
  #--------------------------------------------------------------------------
  alias h_event_back_color1 back_color1
  def back_color1
    if $game_system.h_event
      Color.new(0, 0, 0, h_opacity)
    else
      h_event_back_color1
    end
  end
  #--------------------------------------------------------------------------
  # 〇 エッチシーン中の背景色
  #--------------------------------------------------------------------------
  def h_opacity
    [base_opacity * ($game_variables[Option::H_Opacity] - 1), 255].min
  end
  #--------------------------------------------------------------------------
  # 〇 エッチシーン中の背景色の透過率基礎数値
  #--------------------------------------------------------------------------
  def base_opacity
    return 32
  end
  #--------------------------------------------------------------------------
  # 自動ページ送りの切り替えフラグ ※メッセージ関連追加 改造
  #--------------------------------------------------------------------------
  alias h_event_message_auto_mode_switching_flag message_auto_mode_switching_flag
  def message_auto_mode_switching_flag
    h_event_message_auto_mode_switching_flag && $game_temp.message_skipable? #$game_system.h_event
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ背景の更新
  #--------------------------------------------------------------------------
  alias h_event_update_background update_background
  def update_background
    if $game_system.h_event
      @background = 1
      self.opacity = @background == 0 ? 255 : 0
    else
      h_event_update_background
    end
  end
  #--------------------------------------------------------------------------
  # ● 背景と位置の変更判定
  #--------------------------------------------------------------------------
  alias h_event_settings_changed? settings_changed?
  def settings_changed?
    if $game_system.h_event
      @position != $game_message.position
    else
      h_event_settings_changed?
    end
  end
end

#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias h_event_update update
  def update
    h_event_update
    recreate_message_window if $game_system.window_change && !$game_message.visible
  end
  #--------------------------------------------------------------------------
  # ○ メッセージウィンドウの再作成
  #--------------------------------------------------------------------------
  def recreate_message_window
    @message_window.dispose
    @message_window = Window_Message.new
    $game_system.window_change = false
  end
end

class << MessageEnhance
  #--------------------------------------------------------------------------
  # メッセージウィンドウの不可視化＆停止状態の切り替え ※メッセージ関連追加 改造
  #--------------------------------------------------------------------------
  alias h_event_invisible invisible
  def invisible
    h_event_invisible && $game_system.h_event
  end
end