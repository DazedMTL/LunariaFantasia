module FAKEREAL
  
  EVEN_TONE      = Tone.new(50, -34, -34, 20)
  NIGHT_TONE     = Tone.new(-68, -68, 0, 68)
  MIDNIGHT_TONE  = Tone.new(-92, -100, 4, 92)
  
  EVEN_SWITCHES      = 3
  NIGHT_SWITCHES     = 4
  MIDNIGHT_SWITCHES  = 5
  
end
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
  attr_reader     :game_day                   # ゲーム内時間
  attr_accessor   :event_freeze               # イベント移動停止フラグ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias game_day_initialize initialize
  def initialize
    game_day_initialize
    @game_day = :day
    @event_freeze = false
  end
  #--------------------------------------------------------------------------
  # ● 時間 の変更
  # :day  :evening  :night  の３パターン
  #--------------------------------------------------------------------------
  def day_change(symbol)
    @game_day = symbol
    if symbol == :evening
      $game_switches[FAKEREAL::EVEN_SWITCHES] = true
      $game_switches[FAKEREAL::NIGHT_SWITCHES] = false
      $game_switches[FAKEREAL::MIDNIGHT_SWITCHES] = false
    elsif symbol == :night
      $game_switches[FAKEREAL::EVEN_SWITCHES] = false
      $game_switches[FAKEREAL::NIGHT_SWITCHES] = true
      $game_switches[FAKEREAL::MIDNIGHT_SWITCHES] = false
    elsif symbol == :midnight
      $game_switches[FAKEREAL::EVEN_SWITCHES] = false
      $game_switches[FAKEREAL::NIGHT_SWITCHES] = false
      $game_switches[FAKEREAL::MIDNIGHT_SWITCHES] = true
    else
      $game_switches[FAKEREAL::EVEN_SWITCHES] = false
      $game_switches[FAKEREAL::NIGHT_SWITCHES] = false
      $game_switches[FAKEREAL::MIDNIGHT_SWITCHES] = false
    end
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
  # ● ゲーム内時間変更　朝～昼
  #--------------------------------------------------------------------------
  def day_mode(time = 60, waiting = true)
    screen.start_tone_change(Tone.new, time) if !$game_map.no_day_tone
    wait(time) if waiting
    $game_system.day_change(:day)
    $game_map.refresh
  end
  #--------------------------------------------------------------------------
  # ● ゲーム内時間変更　夕方
  #--------------------------------------------------------------------------
  def even_mode(time = 60, waiting = true)
    screen.start_tone_change(FAKEREAL::EVEN_TONE, time) if !$game_map.no_day_tone
    wait(time) if waiting
    $game_system.day_change(:evening)
    $game_map.refresh
  end
  #--------------------------------------------------------------------------
  # ● ゲーム内時間変更　夜
  #--------------------------------------------------------------------------
  def night_mode(time = 60, waiting = true)
    screen.start_tone_change(FAKEREAL::NIGHT_TONE, time) if !$game_map.no_day_tone
    wait(time) if waiting
    $game_system.day_change(:night)
    $game_map.refresh
  end
  #--------------------------------------------------------------------------
  # ● ゲーム内時間変更　深夜
  #--------------------------------------------------------------------------
  def midnight_mode(time = 60, waiting = true)
    screen.start_tone_change(FAKEREAL::MIDNIGHT_TONE, time) if !$game_map.no_day_tone
    wait(time) if waiting
    $game_system.day_change(:midnight)
    $game_map.refresh
  end
  #--------------------------------------------------------------------------
  # ● ゲーム内時間のチェック symbolに時間の英単語を『文字列』で指定
  #   ※例　time_check("night")
  #   このように "" で括らないとエラーが発生するので注意
  #   またシンボルそのもので指定する事も可能　※例　time_check(:night)
  #--------------------------------------------------------------------------
  def time_check(symbol)
    $game_system.game_day == symbol.to_sym
  end
end