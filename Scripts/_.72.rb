#==============================================================================
# ■ Window_KeyItem
#------------------------------------------------------------------------------
# 　イベントコマンド［アイテム選択の処理］に使用するウィンドウです。
#==============================================================================

class Window_KeyItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end
end
