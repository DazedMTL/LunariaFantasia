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
  def move_ex(ary)
    m = ary[rand(ary.size)]
    if rand(2) == 0
      @stop_count = 0
      return
    end
    move_straight(m, false)
  end
  #--------------------------------------------------------------------------
  # ○ スクリプトによるランダム移動 範囲指定型
  #　　 配列１つの場合は[下,左,右,上]　配列２つを使う場合はxyが[左,下],rt[右,上]
  #--------------------------------------------------------------------------
  def move_area(xy, rt = [])
    if rt.empty?
      move_area_2468(xy)
    else
      move_area_4268(xy, rt)
    end
=begin
    xy.each_with_index do |d, i|
      case i
      when 0,3
        ary.delete(2 * (i + 1)) if @y == d
      when 1,2
        ary.delete(2 * (i + 1)) if @x == d
      end
    end
=end
=begin
    ary = [2, 4, 6, 8]
    if xy.include?(@x) || xy.include?(@y)
      case @x
      when xy[1] ; ary.delete(4)
      when xy[2] ; ary.delete(6)
      end
      case @y
      when xy[0] ; ary.delete(2)
      when xy[3] ; ary.delete(8)
      end
    end
    m = ary[rand(ary.size)]
    move_straight(m, false)
=end
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def move_area_2468(xy)
    d = (rand(6) + 1) * 2
    case d
    when 2
      return if @y == xy[0]
    when 4
      return if @x == xy[1]
    when 6
      return if @x == xy[2]
    when 8
      return if @y == xy[3]
    else
      @stop_count = 0
      return 
    end
    move_straight(d, false)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def move_area_4268(xy, rt)
    d = (rand(6) + 1) * 2
    case d
    when 4
      return if @x == xy[0]
    when 2
      return if @y == xy[1]
    when 6
      return if @x == rt[0]
    when 8
      return if @y == rt[1]
    else
      @stop_count = 0
      return 
    end
    move_straight(d, false)
  end
  #--------------------------------------------------------------------------
  # ● ジャンプ　※エイリアス
  #     x_plus : X 座標加算値
  #     y_plus : Y 座標加算値
  #--------------------------------------------------------------------------
#=begin
  alias priority_jump jump
  def jump(x_plus, y_plus)
    @dp = @priority_type
    @priority_type = 2
    priority_jump(x_plus, y_plus)
  end
  #--------------------------------------------------------------------------
  # 〇 ジャンプ時の更新　※オーバーライド
  #--------------------------------------------------------------------------
  def update_jump
    super
    @priority_type = @dp if @jump_count == 0
  end
#=end
end

#==============================================================================
# ■ Game_CharacterBase
#------------------------------------------------------------------------------
# 　キャラクターを扱う基本のクラスです。全てのキャラクターに共通する、座標やグ
# ラフィックなどの基本的な情報を保持します。
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias priority_initialize initialize
  def initialize
    priority_initialize
    @dp = @priority_type
  end
end