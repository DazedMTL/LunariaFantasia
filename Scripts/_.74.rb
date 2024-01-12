#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  FD_SE       = ["Audio/SE/Damage1", 80, 150]  #床ダメージ時の SE設定
  NF_SE       = ["Audio/SE/Slash1", 80, 150]  #床ダメージ時の SE設定
  #--------------------------------------------------------------------------
  # ● 床ダメージの処理
  #--------------------------------------------------------------------------
  alias se_execute_floor_damage execute_floor_damage
  def execute_floor_damage
    se_execute_floor_damage
    Audio.se_play(*FD_SE)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def needle_damage(rate = 0.05)
    damage = (basic_floor_damage(rate) * fdr).to_i
    self.hp -= [damage, max_floor_damage].min
    perform_map_damage_effect if damage > 0
    Audio.se_play(*NF_SE)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def trap_damage(rate = 0.05)
    damage = (basic_floor_damage(rate) * fdr).to_i
    self.hp -= [damage, max_floor_damage].min
    perform_map_damage_effect if damage > 0
    Audio.se_play(*FD_SE)
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
  # ○ とげ床ダメージ実行
  #--------------------------------------------------------------------------
  def needle_damage(rate = 0.05)
    return if $game_party.floor_damage_cancel?
    c = get_character(0)
    if c.direction != 8
      c.set_direction_fix(false)
      c.set_direction(4)
      c.set_direction(6)
      c.set_direction(8)
      c.set_direction_fix(true)
    end
    $game_party.members.each {|actor| actor.needle_damage(rate) }
  end
  #--------------------------------------------------------------------------
  # ○ 罠ダメージ実行
  #--------------------------------------------------------------------------
  def trap_damage(rate = 0.05)
    $game_party.members.each {|actor| actor.trap_damage(rate) }
  end
end

#==============================================================================
# ■ Game_CharacterBase
#------------------------------------------------------------------------------
# 　キャラクターを扱う基本のクラスです。全てのキャラクターに共通する、座標やグ
# ラフィックなどの基本的な情報を保持します。
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # ○ 向き固定フラグ変更
  #--------------------------------------------------------------------------
  def set_direction_fix(flag)
    @direction_fix = flag
  end
end

#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　イベントを扱うクラスです。条件判定によるイベントページ切り替えや、並列処理
# イベント実行などの機能を持っており、Game_Map クラスの内部で使用されます。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 画面の可視領域付近にいるか判定
  #     dx : 画面中央から左右何マス以内を判定するか
  #     dy : 画面中央から上下何マス以内を判定するか
  #--------------------------------------------------------------------------
  alias trap_near_the_screen? near_the_screen?
  def near_the_screen?(dx = 12, dy = 8)
    return true if @event.name.include?("<画面外自律>")
    trap_near_the_screen?(dx, dy)
    #ax = $game_map.adjust_x(@real_x) - Graphics.width / 2 / 32
    #ay = $game_map.adjust_y(@real_y) - Graphics.height / 2 / 32
    #ax >= -dx && ax <= dx && ay >= -dy && ay <= dy
  end
end

#==============================================================================
# ■ Game_Character
#------------------------------------------------------------------------------
# 　主に移動ルートなどの処理を追加したキャラクターのクラスです。Game_Player、
# Game_Follower、GameVehicle、Game_Event のスーパークラスとして使用されます。
#==============================================================================

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # ○ スクリプトによるランダム移動
  #--------------------------------------------------------------------------
  def rock_trap(start_xy, end_xy = [], diagonal = [])
    return if Graphics.brightness < 255
    if diagonal.empty?
      move_forward
      if !end_xy.empty?
        moveto(start_xy[0], start_xy[1]) if (@x == end_xy[0] && @y == end_xy[1]) && stopping?
      else
        moveto(start_xy[0], start_xy[1]) if !passable?(@x, @y, @direction) && stopping?
      end
    else
      move_diagonal(diagonal[0], diagonal[1])
      moveto(start_xy[0], start_xy[1]) if !diagonal_passable?(@x, @y, diagonal[0], diagonal[1]) && stopping?
    end
  end
end
