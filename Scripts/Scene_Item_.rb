#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　アイテム画面の処理を行うクラスです。
#==============================================================================

class Scene_Item < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_ItemCategory_Extra.new
    @category_window.help_window = @help_window
    @category_window.y = @help_window.y #@help_window.height / 2
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成 ※y位置・height修正
  #--------------------------------------------------------------------------
  def create_item_window
    wy = @help_window.height
    wh = Graphics.height - wy
    @item_window = Window_ItemList.new(0, wy, Graphics.width, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @category_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ［決定］
  #--------------------------------------------------------------------------
  def on_category_ok
    #@select_c_index = @category_window.index
    @category_window.close
    update until @category_window.close?
    @item_window.activate
    @item_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.unselect
    @category_window.open.activate
  end
end
