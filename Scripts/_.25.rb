#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#_/    ◆ 汎用ゲージ描画 - KMS_GenericGauge ◆ VX Ace ◆
#_/    ◇ Last update : 2012/08/05 (TOMY@Kamesoft) ◇
#_/----------------------------------------------------------------------------
#_/  汎用的なゲージ描画機能を提供します。
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

#==============================================================================
# ★ 設定項目 - BEGIN Setting ★
#==============================================================================

module KMS_GenericGauge
  # ◆ ゲージ画像
  #  "Graphics/System" から読み込む。
  HP_IMAGE  = "GaugeHP_fr"   # HP
  MP_IMAGE  = "GaugeMP_fr"   # MP
  TP_IMAGE  = "GaugeTP_fr"   # TP
  EXP_IMAGE = "GaugeEXP_fr"  # EXP

  # ◆ ゲージ位置補正 [x, y]
  HP_OFFSET  = [-23, -2]  # HP
  MP_OFFSET  = [-23, -2]  # MP
  TP_OFFSET  = [-23, -2]  # TP
  EXP_OFFSET = [-23, -2]  # EXP

  # ◆ ゲージ長補正
  HP_LENGTH  = -4  # HP
  MP_LENGTH  = -4  # MP
  TP_LENGTH  = -4  # TP
  EXP_LENGTH = -4  # EXP

  # ◆ ゲージの傾き角度
  #  -89 ～ 89 で指定。
  HP_SLOPE  = 0  # HP
  MP_SLOPE  = 0  # MP
  TP_SLOPE  = 0  # TP
  EXP_SLOPE = 0  # EXPe
end

#==============================================================================
# ☆ 設定ここまで - END Setting ☆
#==============================================================================

$kms_imported = {} if $kms_imported == nil
$kms_imported["GenericGauge"] = true

# *****************************************************************************

#==============================================================================
# ■ Bitmap
#==============================================================================

class Bitmap
  #--------------------------------------------------------------------------
  # ○ 平行四辺形転送
  #--------------------------------------------------------------------------
  def skew_blt(x, y, src_bitmap, src_rect, slope, opacity = 255)
    slope = [[slope, -90].max, 90].min
    sh    = src_rect.height
    off  = sh / Math.tan(Math::PI * (90 - slope.abs) / 180.0)
    if slope >= 0
      dx   = x + off.round
      diff = -off / sh
    else
      dx   = x
      diff = off / sh
    end
    rect = Rect.new(src_rect.x, src_rect.y, src_rect.width, 1)

    sh.times { |i|
      blt(dx + (diff * i).round, y + i, src_bitmap, rect, opacity)
      rect.y += 1
    }
  end
end unless $kms_imported["BitmapExtension"]  # ビットマップ拡張未導入時のみ

#==============================================================================
# ■ Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 現在のレベルから次のレベルまでの全必要経験値取得
  #--------------------------------------------------------------------------
  def next_level_exp_full
    return next_level_exp - current_level_exp
  end
  #--------------------------------------------------------------------------
  # ○ 次のレベルまでの残り経験値取得
  #--------------------------------------------------------------------------
  def next_level_exp_rest
    return next_level_exp - exp
  end
  #--------------------------------------------------------------------------
  # ○ 次のレベルまでの経験値取得率取得
  #--------------------------------------------------------------------------
  def exp_rate
    diff = [next_level_exp_full, 1].max
    rest = [next_level_exp_rest, 1].max
    return (diff - rest) * 1.0 / diff
  end
end

#==============================================================================
# ■ Window_Base
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  # ゲージ転送元座標 [x, y]
  GAUGE_SRC_POS = {
    :normal   => [ 0, 24],
    :decrease => [ 0, 48],
    :increase => [72, 48],
  }
  #--------------------------------------------------------------------------
  # ○ クラス変数
  #--------------------------------------------------------------------------
  @@__gauge_buf = Bitmap.new(320, 24)
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     x       : ウィンドウの X 座標
  #     y       : ウィンドウの Y 座標
  #     width   : ウィンドウの幅
  #     height  : ウィンドウの高さ
  #--------------------------------------------------------------------------
  alias initialize_KMS_GenericGauge initialize
  def initialize(x, y, width, height)
    initialize_KMS_GenericGauge(x, y, width, height)

    @@__gauge_buf = Bitmap.new(320, 24) if @@__gauge_buf.disposed?
  end
  #--------------------------------------------------------------------------
  # ○ ゲージ描画
  #     file       : ゲージ画像ファイル名
  #     x, y       : 描画先 X, Y 座標
  #     width      : 幅
  #     ratio      : 割合
  #     offset     : 座標調整 [x, y]
  #     len_offset : 長さ調整
  #     slope      : 傾き
  #     gauge_type : ゲージタイプ
  #--------------------------------------------------------------------------
  def draw_generic_gauge(file, x, y, width, ratio, offset, len_offset, slope,
                         gauge_type = :normal)
    img    = Cache.system(file)
    x     += offset[0]
    y     += offset[1]
    width += len_offset
    draw_generic_gauge_base(img, x, y, width, slope)
    gw = (width * ratio).to_i
    draw_generic_gauge_bar(img, x, y, width, gw, slope, GAUGE_SRC_POS[gauge_type])
  end
  #--------------------------------------------------------------------------
  # ○ ゲージベース描画
  #     img   : ゲージ画像
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #     slope : 傾き
  #--------------------------------------------------------------------------
  def draw_generic_gauge_base(img, x, y, width, slope)
    rect = Rect.new(0, 0, 24, 24)
    if slope != 0
      contents.skew_blt(x, y, img, rect, slope)
      rect.x = 96
      contents.skew_blt(x + width + 24, y, img, rect, slope)

      rect.x     = 24
      rect.width = 72
      dest_rect = Rect.new(0, 0, width, 24)
      @@__gauge_buf.clear
      @@__gauge_buf.stretch_blt(dest_rect, img, rect)
      contents.skew_blt(x + 24, y, @@__gauge_buf, dest_rect, slope)
    else
      contents.blt(x, y, img, rect)
      rect.x = 96
      contents.blt(x + width + 24, y, img, rect)
      rect.x     = 24
      rect.width = 72
      dest_rect = Rect.new(x + 24, y, width, 24)
      contents.stretch_blt(dest_rect, img, rect)
    end
  end
  #--------------------------------------------------------------------------
  # ○ ゲージ内部描画
  #     img     : ゲージ画像
  #     x, y    : 描画先 X, Y 座標
  #     width   : 全体幅
  #     gw      : 内部幅
  #     slope   : 傾き
  #     src_pos : 転送元座標 [x, y]
  #     start   : 開始位置
  #--------------------------------------------------------------------------
  def draw_generic_gauge_bar(img, x, y, width, gw, slope, src_pos, start = 0)
    rect = Rect.new(src_pos[0], src_pos[1], 72, 24)
    dest_rect = Rect.new(0, 0, width, 24)
    @@__gauge_buf.clear
    @@__gauge_buf.stretch_blt(dest_rect, img, rect)
    dest_rect.x     = start
    dest_rect.width = gw
    x += start
    if slope != 0
      contents.skew_blt(x + 24, y, @@__gauge_buf, dest_rect, slope)
    else
      contents.blt(x + 24, y, @@__gauge_buf, dest_rect)
    end
  end
  #--------------------------------------------------------------------------
  # ● HP の描画
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 124)
    draw_actor_hp_gauge(actor, x, y, width)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    draw_current_and_max_values(x, y, width, actor.hp, actor.mhp,
      hp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # ● MP の描画
  #--------------------------------------------------------------------------
  def draw_actor_mp(actor, x, y, width = 124)
    draw_actor_mp_gauge(actor, x, y, width)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::mp_a)
    draw_current_and_max_values(x, y, width, actor.mp, actor.mmp,
      mp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # ● TP の描画
  #--------------------------------------------------------------------------
  def draw_actor_tp(actor, x, y, width = 124)
    draw_actor_tp_gauge(actor, x, y, width)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::tp_a)
    change_color(tp_color(actor))
    draw_text(x + width - 42, y, 42, line_height, actor.tp.to_i, 2)
  end
  #--------------------------------------------------------------------------
  # ○ HP ゲージの描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_hp_gauge(actor, x, y, width = 120)
    draw_generic_gauge(KMS_GenericGauge::HP_IMAGE,
      x, y, width, actor.hp_rate,
      KMS_GenericGauge::HP_OFFSET,
      KMS_GenericGauge::HP_LENGTH,
      KMS_GenericGauge::HP_SLOPE
    )
  end
  #--------------------------------------------------------------------------
  # ○ MP ゲージの描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_mp_gauge(actor, x, y, width = 120)
    draw_generic_gauge(KMS_GenericGauge::MP_IMAGE,
      x, y, width, actor.mp_rate,
      KMS_GenericGauge::MP_OFFSET,
      KMS_GenericGauge::MP_LENGTH,
      KMS_GenericGauge::MP_SLOPE
    )
  end
  #--------------------------------------------------------------------------
  # ○ TP ゲージの描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_tp_gauge(actor, x, y, width = 120)
    draw_generic_gauge(KMS_GenericGauge::TP_IMAGE,
      x, y, width, actor.tp_rate,
      KMS_GenericGauge::TP_OFFSET,
      KMS_GenericGauge::TP_LENGTH,
      KMS_GenericGauge::TP_SLOPE
    )
  end
  #--------------------------------------------------------------------------
  # ○ Exp の描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_exp(actor, x, y, width = 180)
    str = actor.max_level? ? "-------" : actor.exp
    change_color(normal_color)
    draw_text(x, y, width, line_height, str, 2)
  end
  #--------------------------------------------------------------------------
  # ○ NextExp の描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_next_exp(actor, x, y, width = 180)
    draw_actor_exp_gauge(actor, x, y, width)

    str = actor.max_level? ? "-------" : actor.next_level_exp_rest
    change_color(normal_color)
    draw_text(x, y, width, line_height, str, 2)
  end
  #--------------------------------------------------------------------------
  # ○ Exp ゲージの描画
  #     actor : アクター
  #     x, y  : 描画先 X, Y 座標
  #     width : 幅
  #--------------------------------------------------------------------------
  def draw_actor_exp_gauge(actor, x, y, width = 180)
    draw_generic_gauge(KMS_GenericGauge::EXP_IMAGE,
      x, y, width, actor.exp_rate,
      KMS_GenericGauge::EXP_OFFSET,
      KMS_GenericGauge::EXP_LENGTH,
      KMS_GenericGauge::EXP_SLOPE
    )
  end
end

#==============================================================================
# ■ Window_Status
#==============================================================================

class Window_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 経験値情報の描画
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    change_color(system_color)
    draw_text(x, y + line_height * 0, 180, line_height, Vocab::ExpTotal)
    draw_text(x, y + line_height * 2, 180, line_height, s_next)
    change_color(normal_color)
    draw_actor_exp(     @actor, x, y + line_height * 1)
    draw_actor_next_exp(@actor, x, y + line_height * 3)
  end
end
