#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　マップを扱うクラスです。スクロールや通行可能判定などの機能を持っています。
# このクラスのインスタンスは $game_map で参照されます。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :slip_floor                # スリップマップ
  attr_reader   :slope_stair                # 横階段マップ
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  alias slip_setup setup
  def setup(map_id)
    slip_setup(map_id)
    slip_floor_set
    slope_set
    terrain_write_set
  end
  #--------------------------------------------------------------------------
  # ○ イベントによる地形タグ上書きの有無
  #--------------------------------------------------------------------------
  def terrain_write_set
    @terrain_write = note =~ /\<地形タグ上書き\>/ ? true : false
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def slip_floor_set
    @slip_floor = note =~ /\<スリップ床\>/ ? true : false
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def slope_set
    @slope_stair = note =~ /\<横階段\>/ ? true : false
  end
  #--------------------------------------------------------------------------
  # ○ 滑る床タグの設定　1=下　2=左　3=右　4=上　5=そのままの向き
  #--------------------------------------------------------------------------
  def slip?(x, y)
    if @slip_floor
      tt = terrain_tag(x, y)
      return tt > 0 && tt < 6
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def stair?(x, y)
    if @slope_stair
      tt = terrain_tag(x, y)
      return tt > 5
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def front_stair?(x, y, d)
    if @slope_stair
      tt = front_tt(x, y, d)
      return tt > 5
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def front_tt(x, y, d)
    case d
    when 2; terrain_tag(x, y + 1)
    when 4; terrain_tag(x - 1, y)
    when 6; terrain_tag(x + 1, y)
    when 8; terrain_tag(x, y - 1)
    else  ; terrain_tag(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # ● 地形タグの取得
  #--------------------------------------------------------------------------
  alias slip_extra_terrain_tag terrain_tag
  def terrain_tag(x, y)
    if @terrain_write
      return 0 unless valid?(x, y)
      all_tiles(x, y).each do |tile_id|
        tag = tileset.flags[tile_id] >> 12
        return tag if tag > 0
      end
      return 0
    else
      slip_extra_terrain_tag(x, y)
    end
  end
end

#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================

class Game_Player < Game_Character
  SF_SE       = ["Audio/SE/Ice3", 80, 150]  #スリップ時の SE設定
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :slip_straight                # スリップ中判定
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias slip_initialize initialize
  def initialize
    slip_initialize
    @slip_straight = false
  end
  #--------------------------------------------------------------------------
  # ● 方向ボタン入力による移動処理　※エイリアス
  #--------------------------------------------------------------------------
  #alias slip_move_by_input move_by_input
  #def move_by_input
    #slip_move_by_input
    #slip_set if $game_map.slip_floor && $game_map.slip?(x, y) && passable?(x, y, floor_direction)
  #end
  #--------------------------------------------------------------------------
  # ● まっすぐに移動　※エイリアス
  #--------------------------------------------------------------------------
  alias slip_move_straight move_straight
  def move_straight(d, turn_ok = true)
    slip_move_straight(d, turn_ok)
    slip_set if $game_map.slip_floor && $game_map.slip?(x, y) && passable?(x, y, floor_direction)
    #@followers.move if passable?(@x, @y, d)
    #super
  end
  #--------------------------------------------------------------------------
  # ○ 滑る床による移動処理
  #--------------------------------------------------------------------------
  def move_by_slip
    return if !movable? || $game_map.interpreter.running?
    tt = terrain_tag
    set_direction(tt * 2) if tt > 0 && tt < 5
    play_se_slip
    move_forward
    slip_reset if !$game_map.slip?(x, y) || !passable?(x, y, floor_direction)
  end
  #--------------------------------------------------------------------------
  # ○ スリップ音
  #--------------------------------------------------------------------------
  def play_se_slip
    Audio.se_play(*SF_SE)
  end
  #--------------------------------------------------------------------------
  # ○ 床の滑る向き取得
  #--------------------------------------------------------------------------
  def floor_direction
    tt = terrain_tag
    tt > 0 && tt < 5 ? tt * 2 : direction
  end
  #--------------------------------------------------------------------------
  # ○ スリップフラグセット
  #--------------------------------------------------------------------------
  def slip_set
    @slip_straight = true
    @walk_anime = false
  end
  #--------------------------------------------------------------------------
  # ○ スリップフラグリセット
  #--------------------------------------------------------------------------
  def slip_reset
    @slip_straight = false
    @walk_anime = true
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新　※エイリアス
  #--------------------------------------------------------------------------
  alias slip_update update
  def update
    if @slip_straight
      last_real_x = @real_x
      last_real_y = @real_y
      last_moving = moving?
      move_by_slip
      super
      update_scroll(last_real_x, last_real_y)
      update_vehicle
      update_nonmoving(last_moving) unless moving?
      @followers.update
    else
      slip_update
    end
  end
end

#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　メニュー画面で表示するコマンドウィンドウです。
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● セーブの有効状態を取得　※条件に滑っている状態でない事を追加
  #--------------------------------------------------------------------------
  alias slip_save_enabled save_enabled
  def save_enabled
    slip_save_enabled && !$game_player.slip_straight
  end
end

#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================

#class Game_Player < Game_Character
class Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● まっすぐに移動　※エイリアス
  #--------------------------------------------------------------------------
  alias stair_move_straight move_straight
  def move_straight(d, turn_ok = true)
    if stair_passable?(x, y, d)
      tt = $game_map.terrain_tag(x, y)
      ft = $game_map.front_tt(x, y, d)
      if ft == 6
        move_diagonal(d, (d == 4 ? 8 : 2))
        set_direction(d)
      elsif tt == 6 && ft > 5
        move_diagonal(d, (d == 4 ? 8 : 2))
        set_direction(d)
      elsif ft == 7
        move_diagonal(d, (d == 6 ? 8 : 2))
        set_direction(d)
      elsif tt == 7 && ft > 5
        move_diagonal(d, (d == 6 ? 8 : 2))
        set_direction(d)
      elsif last_down_stair(x, y, d)
        move_diagonal(d, (d == 4 ? 8 : 2)) if tt == 6
        move_diagonal(d, (d == 6 ? 8 : 2)) if tt == 7
        set_direction(d)
      else
        stair_move_straight(d, turn_ok)
      end
    else
      stair_move_straight(d, turn_ok)
    end
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def stair_passable?(x, y, d)
    ($game_map.stair?(x, y) || ($game_map.front_stair?(x, y, d) && first_stair(x, y, d))) && [4,6].include?(d)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def first_stair(x, y, d)
    $game_map.terrain_tag(x, y) < 6 && (($game_map.front_tt(x, y, d) == 6 && d == 4) || ($game_map.front_tt(x, y, d) == 7 && d == 6))
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def last_down_stair(x, y, d)
    $game_map.front_tt(x, y, d) < 6 && (($game_map.terrain_tag(x, y) == 6 && d == 6) || ($game_map.terrain_tag(x, y) == 7 && d == 4))
  end
  #--------------------------------------------------------------------------
  # 〇 斜めに移動
  #     horz : 横方向（4 or 6）
  #     vert : 縦方向（2 or 8）
  #--------------------------------------------------------------------------
=begin
  def move_stair(horz, vert)
    @move_succeed = diagonal_passable?(x, y, horz, vert)
    if @move_succeed
      @x = $game_map.round_x_with_direction(@x, horz)
      @y = $game_map.round_y_with_direction(@y, vert)
      @real_x = $game_map.x_with_direction(@x, reverse_dir(horz))
      @real_y = $game_map.y_with_direction(@y, reverse_dir(vert))
      increase_steps
    elsif
      @move_succeed = passable?(@x, @y, d)
      if @move_succeed
        set_direction(d)
        @x = $game_map.round_x_with_direction(@x, d)
        @y = $game_map.round_y_with_direction(@y, d)
        @real_x = $game_map.x_with_direction(@x, reverse_dir(d))
        @real_y = $game_map.y_with_direction(@y, reverse_dir(d))
        increase_steps
      elsif turn_ok
        set_direction(d)
        check_event_trigger_touch_front
      end
    end
    set_direction(horz) if @direction == reverse_dir(horz)
    #set_direction(vert) if @direction == reverse_dir(vert)
  end
=end
end

#==============================================================================
# ■ Game_CharacterBase
#------------------------------------------------------------------------------
# 　キャラクターを扱う基本のクラスです。全てのキャラクターに共通する、座標やグ
# ラフィックなどの基本的な情報を保持します。
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● 通行可能判定
  #     d : 方向（2,4,6,8）
  #--------------------------------------------------------------------------
=begin
  def passable?(x, y, d)
    if $game_map.stair?(x, y)
      x2 = $game_map.round_x_with_direction(x, d)
      y2 = $game_map.round_y_with_direction(y, d)
      y3 = y2 + (d == 4 ? -1 : (d == 6 ? 1 : 0))
      y4 = y2 + (d == 4 ? 1 : (d == 6 ? -1 : 0))
      if $game_map.terrain_tag(x, y) == 6
        return false unless $game_map.valid?(x2, y2) && $game_map.valid?(x2, y3)
        return true if @through || debug_through?
        return false unless map_passable?(x, y, d)
        return false unless map_passable?(x2, y2, reverse_dir(d)) && map_passable?(x2, y4, reverse_dir(d))
        return false if collide_with_characters?(x2, y2) && collide_with_characters?(x2, y3)
      else
        return false unless $game_map.valid?(x2, y2)
        return true if @through || debug_through?
        return false unless map_passable?(x, y, d)
        return false unless map_passable?(x2, y2, reverse_dir(d))
        return false if collide_with_characters?(x2, y2)
      end
      return true
    else
      x2 = $game_map.round_x_with_direction(x, d)
      y2 = $game_map.round_y_with_direction(y, d)
      return false unless $game_map.valid?(x2, y2)
      return true if @through || debug_through?
      return false unless map_passable?(x, y, d)
      return false unless map_passable?(x2, y2, reverse_dir(d))
      return false if collide_with_characters?(x2, y2)
      return true
    end
  end
=end
end
