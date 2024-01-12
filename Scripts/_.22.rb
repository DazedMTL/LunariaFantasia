class RPG::BaseItem
  def mix_only?
    @mix_only ||= self.note =~ /\<錬成専用\>/ ? true : false
  end
end

#==============================================================================
# ■ Window_ShopBuy
#------------------------------------------------------------------------------
# 　ショップ画面で、購入できる商品の一覧を表示するウィンドウです。
#==============================================================================

class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  alias mix_only_draw_item draw_item
  def draw_item(index)
    item = @data[index]
    if mix_only?(item) && $game_switches[EasyCompose::SID]
      rect = item_rect(index)
      draw_item_name_only(item, rect.x, rect.y, enable?(item))
      rect.width -= 4
      draw_text(rect, price(item), 2)
    else
      mix_only_draw_item(index)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def mix_only?(item)
    return false unless item
    item.mix_only?
  end
  #--------------------------------------------------------------------------
  # ○ 錬成専用アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name_only(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(important_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
    change_color(normal_color, enabled)
    #change_color(normal_color, enabled)
    #draw_text(x + 24, y, width, line_height, "#{item.name} ★")
  end
end