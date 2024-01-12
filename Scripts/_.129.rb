#==============================================================================
# ■ RGSS3 エンカウントゲージ Ver1.01 by 星潟
#------------------------------------------------------------------------------
# マップ画面でのランダムエンカウントについて
# 次のエンカウントまでの歩数カウントをゲージで表示します。
# ゲージスキン(背景部分)とゲージ(歩数カウントによって変動するバーの部分)の
# 2つを画面に表示するのが主な機能です。
# 自作画像をゲージスキンとゲージに用いる事も出来ます。
# その場合、GraphicsフォルダのSystemフォルダに
# SkinとGaugeの項目で指定された画像ファイルを入れて下さい。
# デフォルトではゲージスキンがEncountGaugeSkin1、
# ゲージ部分がEncountGauge1というファイル名に指定されています。
#==============================================================================
=begin
module EncountGauge
  
  #ゲージ・ゲージスキンを表示する条件となるスイッチIDを指定。
  
  #SID   = 12
  
  #エンカウントする敵が設定されていないマップではゲージの表示を消すか否かを指定。
  #trueで消す。falseで消さない。
  
  NoEncountMapZero = true
  
  #エンカウントする敵がいない座標ではゲージの表示を消すか否かを指定。
  #(動作が重くなる場合があります。要注意)
  #trueで消す。falseで消さない。
  
  NoEncountPosZero = true
  
  #エンカウント禁止状態ではゲージの表示を消すか否かを指定。
  #trueで消す。falseで消さない。
  
  NoEncountSeal = true
  
  #乗り物に乗り降り(乗っている間ではなく、乗降タイミング)している間は
  #ゲージ・ゲージスキンを消すか否かを指定。
  
  VehicleGetting   = true
  
  #ゲージ・ゲージスキンの表示状態が切り替わった場合、エンカウント歩数も作り直すか？
  #trueで作り直す。falseで作り直さない。
  
  GVC_RemakeEncount = false
  
  #ゲージが縦向きか横向きかを指定。
  #trueで縦向き、falseで横向き。
  
  Vertical = false
  
  #ゲージスキンのX座標を指定。
  
  SkinX = 520
  
  #ゲージスキンのY座標を指定。
  
  SkinY = 24
  
  #ゲージのX座標を指定。
  
  GaugeX = 520
  
  #ゲージのY座標を指定。
  
  GaugeY = 24
  
  #ゲージ・ゲージスキンのビューポートを指定。
  #特に拘りがなければ変更不要。
  
  Viewport = "@viewport2"
  
  #独自画像を使用するか否かを指定。
  #trueで使用し、false使用しない。
  
  AnotherGraphic = false
  
  #★★★AnotherGraphicがfalseの場合の設定
  
  #ゲージスキンの横幅を指定。(横向きゲージの場合はこちらを長く)
  
  SkinW = 100
  
  #ゲージスキンの縦幅を指定。(縦向きゲージの場合はこちらを長く)
  
  SkinH = 5
  
  #ゲージスキンにおいてゲージの割合が低い側のグラデーション基本色を指定。
  
  SkinColor1 = [16,4,0]
  
  #ゲージスキンにおいてゲージの割合が高い側のグラデーション基本色を指定。
  
  SkinColor2 = [32,8,0]
  
  #ゲージスキン画像の仮の名前を指定。基本的に変更不要。
  
  SkinTempName = "EncountGaugeSkin"
  
  #ゲージの横幅を指定。(横向きゲージの場合はこちらを長く)
  
  GaugeW = 100
  
  #ゲージの縦幅を指定。(縦向きゲージの場合はこちらを長く)
  
  GaugeH = 5
  
  #ゲージにおいてゲージの割合が低い側のグラデーション基本色を指定。
  
  GaugeColor1 = [128,32,0]
  
  #ゲージにおいてゲージの割合が高い側のグラデーション基本色を指定。
  
  GaugeColor2 = [255,64,0]
  
  #ゲージ画像の仮の名前を指定。基本的に変更不要。
  
  GaugeTempName = "EncountGauge"
  
  #★★★AnotherGraphicがfalseの場合の設定ここまで
  
  
  
  #★★★AnotherGraphicがtrueの場合の設定
  
  #ゲージスキンのファイル名を指定。
  
  Skin  = "EncountGaugeSkin1"
  
  #ゲージのファイル名を指定。
  
  Gauge = "EncountGauge1"
  
  #★★★AnotherGraphicがtrueの場合の設定ここまで
  
end
module Cache
  #--------------------------------------------------------------------------
  # ゲージスキンの画像を作成
  #--------------------------------------------------------------------------
  def self.encount_gauge_skin
    @cache ||= {}
    path = EncountGauge::SkinTempName
    if !@cache[path] or @cache[path].disposed?
      @cache[path] = Bitmap.new(EncountGauge::SkinW,EncountGauge::SkinH)
      v = EncountGauge::Vertical
      c1 = v ? EncountGauge::SkinColor2 : EncountGauge::SkinColor1
      c2 = v ? EncountGauge::SkinColor1 : EncountGauge::SkinColor2
      @cache[path].gradient_fill_rect(@cache[path].rect,
      Color.new(c1[0],c1[1],c1[2]),Color.new(c2[0],c2[1],c2[2]),v)
    end
    @cache[path]
  end
  #--------------------------------------------------------------------------
  # ゲージの画像を作成
  #--------------------------------------------------------------------------
  def self.encount_gauge
    @cache ||= {}
    path = EncountGauge::GaugeTempName
    if !@cache[path] or @cache[path].disposed?
      @cache[path] = Bitmap.new(EncountGauge::GaugeW,EncountGauge::GaugeH)
      v = EncountGauge::Vertical
      c1 = v ? EncountGauge::GaugeColor2 : EncountGauge::GaugeColor1
      c2 = v ? EncountGauge::GaugeColor1 : EncountGauge::GaugeColor2
      @cache[path].gradient_fill_rect(@cache[path].rect,
      Color.new(c1[0],c1[1],c1[2]),Color.new(c2[0],c2[1],c2[2]),v)
    end
    @cache[path]
  end
end
class Game_Player < Game_Character
  attr_accessor :encounter_extra_visible
  #--------------------------------------------------------------------------
  # エンカウントカウント作成
  #--------------------------------------------------------------------------
  alias make_encounter_count_encount_gauge make_encounter_count
  def make_encounter_count
    make_encounter_count_encount_gauge
    @encounter_count_max = @encounter_count if @encounter_count != @old_count
  end
  #--------------------------------------------------------------------------
  # エンカウントゲージ割合
  #--------------------------------------------------------------------------
  def get_encounter_count_rate
    return 0 unless @encounter_count_max
    now = (@encounter_count_max - @encounter_count)
    now = @encounter_count_max if @encounter_count <= 0
    now.to_f / @encounter_count_max
  end
  #--------------------------------------------------------------------------
  # 乗り物乗降中か？
  #--------------------------------------------------------------------------
  def encounter_vehicle_getting?
    @vehicle_getting_on or @vehicle_getting_off
  end
end
class Sprite_EncountGaugeBase < Sprite
  #--------------------------------------------------------------------------
  # 初期化
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    @last_map_id = nil
    set_bitmap
    set_position
    update
  end
  #--------------------------------------------------------------------------
  # ビットマップの設定
  #--------------------------------------------------------------------------
  def set_bitmap
    self.bitmap = EncountGauge::AnotherGraphic ? Cache.system(bitmap_name) : get_by_drawn_bitmap
  end
  #--------------------------------------------------------------------------
  # 更新
  #--------------------------------------------------------------------------
  def update
    super
    if @last_map_id != $game_map.map_id
      @last_map_id = $game_map.map_id
      @encounter_list_empty = $game_map.encounter_list.empty?
    end
    self.visible = check_extra_visible_setting
  end
end
class Sprite_EncountGaugeSkin < Sprite_EncountGaugeBase
  #--------------------------------------------------------------------------
  # ビットマップ名
  #--------------------------------------------------------------------------
  def bitmap_name
    EncountGauge::Skin
  end
  #--------------------------------------------------------------------------
  # EncountGauge::AnotherGraphicがfalseの場合、描写したビットマップを取得
  #--------------------------------------------------------------------------
  def get_by_drawn_bitmap
    Cache.encount_gauge_skin
  end
  #--------------------------------------------------------------------------
  # 座標設定
  #--------------------------------------------------------------------------
  def set_position
    self.x = EncountGauge::SkinX
    self.y = EncountGauge::SkinY
  end
  #--------------------------------------------------------------------------
  # 可視判定
  #--------------------------------------------------------------------------
  def check_extra_visible_setting
    f = true #$game_switches[EncountGauge::SID]
    f = (@encounter_list_empty ? false : true) if f && EncountGauge::NoEncountMapZero
    f = $game_map.encounter_list.any? {|e| $game_player.encounter_ok?(e)} if f && EncountGauge::NoEncountPosZero
    f = ($game_system.encounter_disabled ? false : true) if f && EncountGauge::NoEncountSeal
    f = !$game_player.encounter_vehicle_getting? if f && EncountGauge::VehicleGetting
    f = false if ($game_switches[FAKEREAL::EVENT_RUNNING] || $game_message.busy? || $game_message.visible)
    if EncountGauge::GVC_RemakeEncount && $game_player.encounter_extra_visible != f
      $game_player.make_encounter_count
    end
    $game_player.encounter_extra_visible = f
  end
end
class Sprite_EncountGauge < Sprite_EncountGaugeBase
  #--------------------------------------------------------------------------
  # ビットマップ名
  #--------------------------------------------------------------------------
  def bitmap_name
    EncountGauge::Gauge
  end
  #--------------------------------------------------------------------------
  # 座標設定
  #--------------------------------------------------------------------------
  def set_position
    self.x = EncountGauge::GaugeX
    self.y = EncountGauge::GaugeY
  end
  #--------------------------------------------------------------------------
  # 更新
  #--------------------------------------------------------------------------
  def update
    super
    update_rect
  end
  #--------------------------------------------------------------------------
  # ビットマップの設定
  #--------------------------------------------------------------------------
  def set_bitmap
    super
    @bitmap_rect = self.bitmap.rect
  end
  #--------------------------------------------------------------------------
  # EncountGauge::AnotherGraphicがfalseの場合、描写したビットマップを取得
  #--------------------------------------------------------------------------
  def get_by_drawn_bitmap
    Cache.encount_gauge
  end
  #--------------------------------------------------------------------------
  # 矩形の更新
  #--------------------------------------------------------------------------
  def update_rect
    rate = $game_player.get_encounter_count_rate
    if @last_rate != rate
      @last_rate = rate
      rect_data = @bitmap_rect.clone
      if EncountGauge::Vertical
        wr = (rate * rect_data.height).to_i
        rect_data.height = wr
        rect_data.y = @bitmap_rect.height - wr
        self.oy = -rect_data.y
      else
        wr = (rate * rect_data.width).to_i
        rect_data.width = wr
      end
      self.src_rect = rect_data
    end
  end
  #--------------------------------------------------------------------------
  # 可視判定
  #--------------------------------------------------------------------------
  def check_extra_visible_setting
    $game_player.encounter_extra_visible
  end
end
class Spriteset_Map
  #--------------------------------------------------------------------------
  # タイマースプライトの作成
  #--------------------------------------------------------------------------
  alias create_timer_encount_gauge create_timer
  def create_timer
    create_timer_encount_gauge
    @encount_gauge_skin = Sprite_EncountGaugeSkin.new(eval(EncountGauge::Viewport))
    @encount_gauge = Sprite_EncountGauge.new(eval(EncountGauge::Viewport))
  end
  #--------------------------------------------------------------------------
  # タイマースプライトの解放
  #--------------------------------------------------------------------------
  alias dispose_timer_encount_gauge dispose_timer
  def dispose_timer
    dispose_timer_encount_gauge
    @encount_gauge_skin.dispose
    @encount_gauge.dispose
  end
  #--------------------------------------------------------------------------
  # タイマースプライトの更新
  #--------------------------------------------------------------------------
  alias update_timer_encount_gauge update_timer
  def update_timer
    update_timer_encount_gauge
    @encount_gauge_skin.update
    @encount_gauge.update
  end
end
=end