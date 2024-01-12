module FAKEREAL
  
  STAND_NO = 10 #立ち絵のピクチャ番号の開始位置（これにアクターＩＤを足した番号）
  NPC_STAND_NO = 20 #NPC立ち絵のピクチャ番号の開始位置（これにNPCIDを足した番号）
  STAND_BY_TONE      = Tone.new(-78, -78, -78, 85)
  STAND_BY_OPACITY      = 140#180
  STAND_Y      = -77#-20
  RIGHT_X      = 330
  LEFT_X      = -80
  PRI_Z      = 100 #立ち絵が明るいときのZ座標のプラス数値
  HIDE_OPACITY = 25
  ERASE_SWITCHES     = 97 #会話後スタンバイではなく立ち絵を消去
  NPC_ERASE_SWITCHES = 98 #上同NPC
  REVERSE_STAND_SWITCHES = 96 #立ち絵位置反転 主に上記の立ち絵即消去と併用
  
  X_ADJUST_ACTOR = Hash[
   1 => [0,-10,0], #[右,左,上]
   2 => [20,0,0],
   3 => [0,-20,0],
   4 => [0,0,0],
   5 => [20,0,0],
  ]
  
  X_ADJUST_NPC = Hash[
   1 => [0,-25,0], #[右,左,上]
   2 => [0,0,0],
   3 => [0,-20,0],
   4 => [0,-10,0],
   5 => [5,0,0],
   6 => [0,0,0],
   7 => [0,0,0],
   8 => [0,0,0],
   9 => [0,0,0],
   10 => [0,0,0],
   11 => [0,0,0],
   12 => [20,-10,0],
   13 => [0,-50,0],
   14 => [15,-10,20],
   21 => [35,-45,30],
   23 => [45,-35,30],
   31 => [15,-65,0],
   32 => [15,-50,0],
   41 => [25,-60,30],
   42 => [-5,-50,0],
   51 => [-5,-50,20],
  ]
  
  
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 文章の表示
  #--------------------------------------------------------------------------
  alias stand_command_101 command_101
  def command_101
    $game_temp.kidoku_flag = kidoku_flag if writable?
    #if @params[0] =~ /^\!(n|kp)(\d+)_(\d+)/i#/^\!.+/i
    if @params[0] =~ /^\!([a-zA-Z]+)(\d+)_(\d+)/i#/^\!.+/i
      wait_for_message
      index = @params[1].to_i
      if $1 == "n"
        stand_left($2.to_i) if $game_switches[FAKEREAL::REVERSE_STAND_SWITCHES]
        stand_talk($2.to_i, $3.to_i * 8 + index, true)
      elsif $1 == "kp"
        stand_left($2.to_i,false) if $game_switches[FAKEREAL::REVERSE_STAND_SWITCHES]
        npc_stand_talk($2.to_i, $3.to_i * 8 + index, true)
      end
      $game_message.background = @params[2]
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
      if $1 == "n"
        if $game_switches[FAKEREAL::ERASE_SWITCHES]
          stand_erase($2.to_i)
        else
          stand_by($2.to_i)
        end
      elsif $1 == "kp"
        if $game_switches[FAKEREAL::NPC_ERASE_SWITCHES]
          npc_stand_erase($2.to_i)
        else
          npc_stand_by($2.to_i)
        end
      end
    else
      stand_command_101
    end
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の左右指定表示
  #--------------------------------------------------------------------------
  def stand_left(id = 1, left = true)
    if left
      stand_show(id, FAKEREAL::LEFT_X + FAKEREAL::X_ADJUST_ACTOR[id][1])
    else
      npc_stand_show(id, FAKEREAL::RIGHT_X + FAKEREAL::X_ADJUST_NPC[id][0])
    end
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の表示　actor_id アクター番号　base 原点(左上、中心)　3=位置の指定方法
  #　　4=x 5=y　6=横ズーム%　7=縦ズーム%　8=不透明度　9=合成方法(0=通常　1=加算　2=減産)
  #--------------------------------------------------------------------------
  def stand_show(actor_id = 1, x = "", y = FAKEREAL::STAND_Y, face_id = 0, base = 0, zoom_x = 100, zoom_y = 100, op = 255, blend = 0)
    actor = $game_actors[actor_id]
    number = FAKEREAL::STAND_NO + actor_id
    y += FAKEREAL::X_ADJUST_ACTOR[actor_id][2]
    x = FAKEREAL::RIGHT_X + FAKEREAL::X_ADJUST_ACTOR[actor_id][0] if !x.is_a?(Numeric)
    stand_name = "Stands/" + actor.graphic_name + "_cos#{actor.costume}" + "_face#{format("%02d",face_id)}"
    screen.pictures[number].show(stand_name, base,
      x, y, zoom_x, zoom_y, op, blend)
    screen.pictures[number].memory_tone = nil ###
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の変更
  #--------------------------------------------------------------------------
  def stand_change(actor_id = 1, face_id = 0)
    actor = $game_actors[actor_id]
    number = FAKEREAL::STAND_NO + actor_id
    stand_name = "Stands/" + actor.graphic_name + "_cos#{actor.costume}" + "_face#{format("%02d",face_id)}"
    screen.pictures[number].change(stand_name)
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の移動
  #--------------------------------------------------------------------------
  def stand_move(plus_x, plus_y, actor_id = 1, duration = 60, waiting = true)
    number = FAKEREAL::STAND_NO + actor_id
    screen.pictures[number].stand_move(plus_x, plus_y, duration)
    wait(duration) if waiting
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の待機中トーン
  #--------------------------------------------------------------------------
  def stand_by(actor_id = 1, duration = 0)
    number = FAKEREAL::STAND_NO + actor_id
    screen.pictures[number].tone_memory unless hide_tone?(number) ###
    ###
    tone = screen.pictures[number].memory_tone == Tone.new ? FAKEREAL::STAND_BY_TONE : screen.pictures[number].memory_tone.clone
    screen.pictures[number].priority(-FAKEREAL::PRI_Z) if screen.pictures[number].z >= FAKEREAL::PRI_Z
    screen.pictures[number].start_tone_change(tone, duration)
    screen.pictures[number].op_change(FAKEREAL::STAND_BY_OPACITY)
    wait(duration) if duration > 0
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵のトーンの復帰
  #--------------------------------------------------------------------------
  def stand_talk(actor_id = 1, face_id = -1, message = false)
    number = FAKEREAL::STAND_NO + actor_id
    stand_show(actor_id) if message && screen.pictures[number].name == ""
    ###
    tone = screen.pictures[number].memory_tone ? screen.pictures[number].memory_tone.clone : Tone.new
    if face_id > -1
      actor = $game_actors[actor_id]
      stand_name = "Stands/" + actor.graphic_name + "_cos#{actor.costume}" + "_face#{format("%02d",face_id)}"
      screen.pictures[number].change(stand_name)
    end
    screen.pictures[number].priority(FAKEREAL::PRI_Z) if screen.pictures[number].z < FAKEREAL::PRI_Z
    screen.pictures[number].start_tone_change(tone, 0)
    screen.pictures[number].op_change
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の消去
  #--------------------------------------------------------------------------
  def stand_erase(actor_id = 1)
    number = FAKEREAL::STAND_NO + actor_id
    screen.pictures[number].erase
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の優先順位手動変更
  #--------------------------------------------------------------------------
  def stand_priority(actor_id, plus = 5)
    number = FAKEREAL::STAND_NO + actor_id
    screen.pictures[number].priority(plus)
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の優先順位手動リセット　z = 0
  #--------------------------------------------------------------------------
  def stand_z_reset(actor_id = 1)
    number = FAKEREAL::STAND_NO + actor_id
    screen.pictures[number].z_reset
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の透過
  #--------------------------------------------------------------------------
  def stand_hide(actor_id = 1)
    number = FAKEREAL::STAND_NO + actor_id
    screen.pictures[number].op_change(FAKEREAL::HIDE_OPACITY)
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の待機＋透過
  #--------------------------------------------------------------------------
  def stand_by_hide(actor_id = 1, duration = 0)
    number = FAKEREAL::STAND_NO + actor_id
    tone = FAKEREAL::STAND_BY_TONE
    screen.pictures[number].start_tone_change(tone, duration)
    screen.pictures[number].op_change(FAKEREAL::HIDE_OPACITY)
    wait(duration) if duration > 0
    screen.pictures[number].priority(-FAKEREAL::PRI_Z) if screen.pictures[number].z >= FAKEREAL::PRI_Z
  end
  #--------------------------------------------------------------------------
  # ○ NPC立ち絵の表示　0=ピクチャ番号　1=画像名　2=原点(左上、中心)　3=位置の指定方法
  #　　4=x 5=y　6=横ズーム%　7=縦ズーム%　8=不透明度　9=合成方法(0=通常　1=加算　2=減産)
  #--------------------------------------------------------------------------
  def npc_stand_show(npc_id, x = "", y = FAKEREAL::STAND_Y, face_id = 0, base = 0, zoom_x = 100, zoom_y = 100, op = 255, blend = 0)
    name = Person::Name[npc_id][2]
    return if name == ""
    number = FAKEREAL::NPC_STAND_NO + npc_id
    cos_id = $game_system.npc_costume(npc_id)
    y += FAKEREAL::X_ADJUST_NPC[npc_id][2]
    x = FAKEREAL::LEFT_X + FAKEREAL::X_ADJUST_NPC[npc_id][1] if !x.is_a?(Numeric)
    stand_name = "Stands/" + name + "_cos#{cos_id}" + "_face#{format("%02d",face_id)}"
    screen.pictures[number].show(stand_name, base,
      x, y, zoom_x, zoom_y, op, blend)
    screen.pictures[number].memory_tone = nil ###
  end
  #--------------------------------------------------------------------------
  # ○ NPC立ち絵の変更
  #--------------------------------------------------------------------------
  def npc_stand_change(npc_id = 1, face_id = 0)
    name = Person::Name[npc_id][2]
    number = FAKEREAL::NPC_STAND_NO + npc_id
    cos_id = $game_system.npc_costume(npc_id)
    stand_name = "Stands/" + name + "_cos#{cos_id}" + "_face#{format("%02d",face_id)}"
    screen.pictures[number].change(stand_name)
  end
  #--------------------------------------------------------------------------
  # ○ NPC立ち絵の移動
  #--------------------------------------------------------------------------
  def npc_stand_move(plus_x, plus_y, npc_id = 1, duration = 60, waiting = true)
    number = FAKEREAL::NPC_STAND_NO + npc_id
    screen.pictures[number].stand_move(plus_x, plus_y, duration)
    wait(duration) if waiting
  end
  #--------------------------------------------------------------------------
  # ○ NPC立ち絵の待機中トーン　ピクチャ番号で指定
  #--------------------------------------------------------------------------
  def npc_stand_by(npc_id, duration = 0)
    #tone = FAKEREAL::STAND_BY_TONE
    number = FAKEREAL::NPC_STAND_NO + npc_id
    screen.pictures[number].tone_memory unless hide_tone?(number) ###
    ###
    tone = screen.pictures[number].memory_tone == Tone.new ? FAKEREAL::STAND_BY_TONE : screen.pictures[number].memory_tone.clone
    screen.pictures[number].priority(-FAKEREAL::PRI_Z) if screen.pictures[number].z >= FAKEREAL::PRI_Z
    screen.pictures[number].start_tone_change(tone, duration)
    screen.pictures[number].op_change(FAKEREAL::STAND_BY_OPACITY)
    wait(duration) if duration > 0
  end
  #--------------------------------------------------------------------------
  # ○ NPC立ち絵のトーンの復帰　ピクチャ番号で指定
  #--------------------------------------------------------------------------
  def npc_stand_talk(npc_id, face_id = -1, message = false)
    #tone = Tone.new
    number = FAKEREAL::NPC_STAND_NO + npc_id
    ###
    tone = screen.pictures[number].memory_tone ? screen.pictures[number].memory_tone.clone : Tone.new
    npc_stand_show(npc_id) if message && screen.pictures[number].name == ""
    if face_id > -1
      cos_id = $game_system.npc_costume(npc_id)
      name = Person::Name[npc_id][2]
      stand_name = "Stands/" + name + "_cos#{cos_id}" + "_face#{format("%02d",face_id)}"
      screen.pictures[number].change(stand_name)
    end
    screen.pictures[number].priority(FAKEREAL::PRI_Z) if screen.pictures[number].z < FAKEREAL::PRI_Z
    screen.pictures[number].start_tone_change(tone, 0)
    screen.pictures[number].op_change
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の消去
  #--------------------------------------------------------------------------
  def npc_stand_erase(npc_id)
    number = FAKEREAL::NPC_STAND_NO + npc_id
    screen.pictures[number].erase
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵の透過
  #--------------------------------------------------------------------------
  def npc_stand_hide(npc_id)
    number = FAKEREAL::NPC_STAND_NO + npc_id
    screen.pictures[number].op_change(FAKEREAL::HIDE_OPACITY)
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵ハイド中？
  #--------------------------------------------------------------------------
  def hide_tone?(number)
    screen.pictures[number].opacity == FAKEREAL::HIDE_OPACITY
  end
  #--------------------------------------------------------------------------
  # ○ NPC立ち絵の待機＋透過
  #--------------------------------------------------------------------------
  def npc_stand_by_hide(npc_id, duration = 0)
    tone = FAKEREAL::STAND_BY_TONE
    number = FAKEREAL::NPC_STAND_NO + npc_id
    screen.pictures[number].start_tone_change(tone, duration)
    screen.pictures[number].op_change(FAKEREAL::HIDE_OPACITY)
    wait(duration) if duration > 0
    screen.pictures[number].priority(-FAKEREAL::PRI_Z) if screen.pictures[number].z >= FAKEREAL::PRI_Z
  end
  #--------------------------------------------------------------------------
  # ○ 立ち絵（正確にはピクチャ）の全消去
  #--------------------------------------------------------------------------
  def all_erase
    screen.clear_pictures
  end
  #--------------------------------------------------------------------------
  # ○ ピクチャのZ
  #--------------------------------------------------------------------------
  def cg_z(plus, number = 1)
    screen.pictures[number].priority(plus)
  end
  #--------------------------------------------------------------------------
  # ○ ピクチャのトーン記憶 ※ピクチャの色調変更を維持したい時、色調変更直後に使用
  #--------------------------------------------------------------------------
  def tone_memory(number = 1)
    screen.pictures[number].tone_memory
  end
  #--------------------------------------------------------------------------
  # ○ ピクチャのトーン記憶のリセット ※stand_hideから戻す時これを行う
  #--------------------------------------------------------------------------
  def tone_reset(number = 1)
    screen.pictures[number].tone_reset
  end
end

#==============================================================================
# ■ Game_Picture
#------------------------------------------------------------------------------
# 　ピクチャを扱うクラスです。このクラスは Game_Pictures クラスの内部で、特定
# の番号のピクチャが必要になったときだけ作成されます。
#==============================================================================

class Game_Picture
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader     :z                      # Z 座標
  attr_accessor   :memory_tone            # トーンの記憶
  #--------------------------------------------------------------------------
  # ● 基本変数の初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias stand_init_basic init_basic
  def init_basic
    stand_init_basic
    z_reset
    tone_reset
  end
  #--------------------------------------------------------------------------
  # ● ピクチャの表示　※エイリアス
  #--------------------------------------------------------------------------
  alias z_reset_show show
  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    z_reset_show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @z = FAKEREAL::PRI_Z
  end
  #--------------------------------------------------------------------------
  # ○ 優先順位の変更
  #--------------------------------------------------------------------------
  def priority(plus)
    @z += plus
  end
  #--------------------------------------------------------------------------
  # ○ 優先順位のリセット
  #--------------------------------------------------------------------------
  def z_reset
    @z = 0
  end
  #--------------------------------------------------------------------------
  # ○ ピクチャの変更
  #--------------------------------------------------------------------------
  def change(name)
    @name = name
  end
  #--------------------------------------------------------------------------
  # ○ ピクチャの移動
  #--------------------------------------------------------------------------
  def stand_move(plus_x, plus_y, duration)
    x = @x + plus_x
    y = @y + plus_y
    @target_x = x.to_f
    @target_y = y.to_f
    @duration = duration
  end
  #--------------------------------------------------------------------------
  # ○ 不透明度の変更
  #--------------------------------------------------------------------------
  def op_change(opacity = 255, duration = 1)
    @target_opacity = opacity.to_f
    @duration = duration
  end
  #--------------------------------------------------------------------------
  # ○ トーンの記憶
  #--------------------------------------------------------------------------
  def tone_memory
    @memory_tone = @tone.clone
  end
  #--------------------------------------------------------------------------
  # ○ トーンの記憶
  #--------------------------------------------------------------------------
  def tone_reset
    @memory_tone = nil
  end
end

#==============================================================================
# ■ Sprite_Picture
#------------------------------------------------------------------------------
# 　ピクチャ表示用のスプライトです。Game_Picture クラスのインスタンスを監視し、
# スプライトの状態を自動的に変化させます。
#==============================================================================

class Sprite_Picture < Sprite
  #--------------------------------------------------------------------------
  # ● 位置の更新　※再定義
  #--------------------------------------------------------------------------
  def update_position
    self.x = @picture.x
    self.y = @picture.y
    self.z = (@picture.number + @picture.z)
  end
end

#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは $game_system で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias stand_initialize initialize
  def initialize
    stand_initialize
    npc_costume_init
  end
  #--------------------------------------------------------------------------
  # 〇 NPCのコスチュームの初期化
  #--------------------------------------------------------------------------
  def npc_costume_init
    @npc_costume = {}
  end
  #--------------------------------------------------------------------------
  # 〇 NPCのコスチューム
  #--------------------------------------------------------------------------
  def npc_costume(npc_id)
    npc_costume_init if !@npc_costume
    npc_costume_set(npc_id) if !@npc_costume[npc_id]
    @npc_costume[npc_id]
  end
  #--------------------------------------------------------------------------
  # 〇 NPCのコスチューム番号のセット
  #--------------------------------------------------------------------------
  def npc_costume_set(npc_id, cos_id = 1)
    @npc_costume[npc_id] = format("%02d",cos_id)
  end
end