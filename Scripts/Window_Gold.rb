#==============================================================================
# ■ Window_Gold
#------------------------------------------------------------------------------
# 　所持金を表示するウィンドウです。
#==============================================================================

class Window_Gold < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(1))
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_currency_value(value, currency_unit, 4, 0, contents.width - 8)
  end
  #--------------------------------------------------------------------------
  # ● 所持金の取得
  #--------------------------------------------------------------------------
  def value
    $game_party.gold
  end
  #--------------------------------------------------------------------------
  # ● 通貨単位の取得
  #--------------------------------------------------------------------------
  def currency_unit
    Vocab::currency_unit
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウを開く
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
end
