#==============================================================================
# □ No.023
#    画面サイズVGA（RPGツクールVX Ace）
#------------------------------------------------------------------------------
# by initialization
#==============================================================================

#==============================================================================
# □ 設定
#==============================================================================
module RGSSinit end
module RGSSinit::Screen_Size_Change
  #--------------------------------------------------------------------------
  # ○ 素材スイッチ（true/false）
  #--------------------------------------------------------------------------
  MATERIAL_SWITCH = true
  #--------------------------------------------------------------------------
  # ○ 戦闘画面の画像サポート
  #--------------------------------------------------------------------------
  BATTLE_TYPE = 2
  #--------------------------------------------------------------------------
  # ○ タイトル画面の画像サポート
  #--------------------------------------------------------------------------
  TITLE_TYPE = 2
  #--------------------------------------------------------------------------
  # ○ ゲームオーバー画面の画像サポート
  #--------------------------------------------------------------------------
  GAMEOVER_TYPE = 1
  #--------------------------------------------------------------------------
  # ○ メッセージウィンドウの幅の調整フラグ（true/false）
  #--------------------------------------------------------------------------
  MESSAGE_WINDOW_ADJUSTMENT = true
  #--------------------------------------------------------------------------
  # ○ メッセージウィンドウの幅の設定
  #--------------------------------------------------------------------------
  WIDTH = 640 #544
end

#==============================================================================
# ■ Object
#==============================================================================
class Object
  #--------------------------------------------------------------------------
  # ○ アクセス省略化
  #--------------------------------------------------------------------------
  RGSSinit023 = RGSSinit::Screen_Size_Change
end

#==============================================================================
# □ 画面サイズVGA
#==============================================================================
$rgssinit ||= {} ; $rgssinit["画面サイズVGA"] = RGSSinit023::MATERIAL_SWITCH

if $rgssinit["画面サイズVGA"]

if RGSSinit023::MESSAGE_WINDOW_ADJUSTMENT
#==============================================================================
# ■ Window_Message
#==============================================================================
class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化 [再定義]
  #--------------------------------------------------------------------------
  def initialize
    super(window_x, 0, window_width, window_height)
    self.z        = 200
    self.openness = 0
    create_all_windows
    create_back_bitmap
    create_back_sprite
    clear_instance_variables
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの横の位置
  #--------------------------------------------------------------------------
  def window_x
    (Graphics.width - window_width) / 2
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの幅の位置
  #--------------------------------------------------------------------------
  def window_width
    RGSSinit023::WIDTH
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ位置の更新 [再定義]
  #--------------------------------------------------------------------------
  def update_placement
    @position = $game_message.position
    self.y = @position * (Graphics.height - height) / 2
=begin
    case $game_message.position
    when 0
      self.y += 8 #32
    when 2
      self.y -= 8 #32
    end
=end
    @gold_window.y = y > 0 ? 0 : Graphics.height - @gold_window.height
    @back_sprite.x = (Graphics.width - width) / 2 if @background == 1
  end
end
end

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 戦闘背景（床）スプライトの作成 [再定義]
  #--------------------------------------------------------------------------
  def create_battleback1
    case RGSSinit023::BATTLE_TYPE
    when 1
      create_battleback1_type1
    when 2
      create_battleback1_type2
    else
      @back1_sprite        = Sprite.new(@viewport1)
      @back1_sprite.bitmap = battleback1_bitmap
      @back1_sprite.z      = 0
      center_sprite(@back1_sprite)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘背景（床）スプライトの作成：引き伸ばし
  #--------------------------------------------------------------------------
  def create_battleback1_type1
    battleback1_bg       = battleback1_bitmap
    resize               = Bitmap.new(676, 516)
    resize.stretch_blt(resize.rect, battleback1_bg, battleback1_bg.rect)
    @back1_sprite        = Sprite.new(@viewport1)
    @back1_sprite.bitmap = resize
    @back1_sprite.z      = 0
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘背景（床）スプライトの作成：左上表示
  #--------------------------------------------------------------------------
  def create_battleback1_type2
    @back1_sprite        = Sprite.new(@viewport1)
    @back1_sprite.bitmap = battleback1_bitmap
    @back1_sprite.z      = 0
  end
  #--------------------------------------------------------------------------
  # ● 戦闘背景（壁）スプライトの作成 [再定義]
  #--------------------------------------------------------------------------
  def create_battleback2
    case RGSSinit023::BATTLE_TYPE
    when 1
      create_battleback2_type1
    when 2
      create_battleback2_type2
    else
      @back2_sprite        = Sprite.new(@viewport1)
      @back2_sprite.bitmap = battleback2_bitmap
      @back2_sprite.z      = 1
      center_sprite(@back2_sprite)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘背景（壁）スプライトの作成：引き伸ばし
  #--------------------------------------------------------------------------
  def create_battleback2_type1
    battleback2_bg       = battleback2_bitmap
    resize               = Bitmap.new(676, 516)
    resize.stretch_blt(resize.rect, battleback2_bg, battleback2_bg.rect)
    @back2_sprite        = Sprite.new(@viewport1)
    @back2_sprite.bitmap = resize
    @back2_sprite.z      = 1
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘背景（壁）スプライトの作成：左上表示
  #--------------------------------------------------------------------------
  def create_battleback2_type2
    @back2_sprite        = Sprite.new(@viewport1)
    @back2_sprite.bitmap = battleback2_bitmap
    @back2_sprite.z      = 1
  end
end

#==============================================================================
# ■ Scene_Title
#==============================================================================
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # ● 背景の作成 [再定義]
  #--------------------------------------------------------------------------
  def create_background
    case RGSSinit023::TITLE_TYPE
    when 1
      create_background_type1
    when 2
      create_background_type2
    else
      @sprite1 = Sprite.new
      @sprite1.bitmap = Cache.title1($data_system.title1_name)
      @sprite2 = Sprite.new
      @sprite2.bitmap = Cache.title2($data_system.title2_name)
      center_sprite(@sprite1)
      center_sprite(@sprite2)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 背景の作成：引き伸ばし
  #--------------------------------------------------------------------------
  def create_background_type1
    title_bg1           = Cache.title1($data_system.title1_name)
    title_bg2           = Cache.title2($data_system.title2_name)
    resize1             = resize2 = Bitmap.new(640, 480)
    resize1.stretch_blt(resize1.rect, title_bg1, title_bg1.rect)
    resize2.stretch_blt(resize2.rect, title_bg2, title_bg2.rect)
    @sprite1 = @sprite2 = Sprite.new
    @sprite1.bitmap     = resize1
    @sprite2.bitmap     = resize2
  end
  #--------------------------------------------------------------------------
  # ○ 背景の作成：左上表示
  #--------------------------------------------------------------------------
  def create_background_type2
    @sprite1        = Sprite.new
    @sprite1.bitmap = Cache.title1($data_system.title1_name)
    @sprite2        = Sprite.new
    @sprite2.bitmap = Cache.title2($data_system.title2_name)
  end
end

#==============================================================================
# ■ Scene_Gameover
#==============================================================================
class Scene_Gameover < Scene_Base
  #--------------------------------------------------------------------------
  # ● 背景の作成 [再定義]
  #--------------------------------------------------------------------------
  def create_background
    case RGSSinit023::GAMEOVER_TYPE
    when 1
      create_background_type1
    when 2
      create_background_type2
    else
      @sprite = Sprite.new
      @sprite.bitmap = Cache.system("GameOver")
    end
  end
  #--------------------------------------------------------------------------
  # ○ 背景の作成：引き伸ばし
  #--------------------------------------------------------------------------
  def create_background_type1
    gameover_bg    = Cache.system("GameOver")
    resize         = Bitmap.new(640, 480)
    resize.stretch_blt(resize.rect, gameover_bg, gameover_bg.rect)
    @sprite        = Sprite.new
    @sprite.bitmap = resize
  end
  #--------------------------------------------------------------------------
  # ○ 背景の作成：中央寄せ
  #--------------------------------------------------------------------------
  def create_background_type2
    @sprite        = Sprite.new
    @sprite.bitmap = Cache.system("GameOver")
    center_sprite(@sprite)
  end
  #--------------------------------------------------------------------------
  # ○ スプライトを画面中央に移動
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x  = Graphics.width / 2
    sprite.y  = Graphics.height / 2
  end
end

#==============================================================================
# ■ Object
#==============================================================================
class Object
  Graphics.resize_screen(640, 480)
end

end