#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　スキルやアイテムの説明、アクターのステータスなどを表示するウィンドウです。
#==============================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(line_number = 3)
    super(0, 0, Graphics.width, fitting_height(line_number))
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● クリア
  #--------------------------------------------------------------------------
  def clear
    set_text("")
  end
  #--------------------------------------------------------------------------
  # ● アイテム設定
  #     item : スキル、アイテム等
  #--------------------------------------------------------------------------
  def set_item(item)
    set_text(item ? item.description : "")
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_text_ex(4, 0, @text)
  end
end
