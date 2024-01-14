#==============================================================================
# □ Scene_Quest
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_BookItem < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_item_window
    create_detail_window
    create_category_window
    create_rate_window
  end
  #--------------------------------------------------------------------------
  # ○ ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ○ 収集率ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_rate_window
    @rate_window = Window_CollectionRate_Item.new
    @category_window.rate_window = @rate_window
  end
  #--------------------------------------------------------------------------
  # ○ 詳細ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_detail_window
    wx = @item_window.width
    wy = @help_window.height
    ww = Graphics.width - @item_window.width
    wh = @item_window.height
    @item_status_window = Window_ItemStatus_Book.new(wx, wy, ww, wh)
    @item_status_window.category_window = @category_window
    @item_window.detail_window = @item_status_window
    @item_status_window.show
  end
  #--------------------------------------------------------------------------
  # ○ アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    wy = @help_window.height
    wh = Graphics.height - @help_window.height
    @item_window = Window_BookList_Item.new(wy, wh)
    @item_window.viewport = @viewport
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @item_window.help_window = @help_window
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_BookCategory_Item.new
    @category_window.viewport = @viewport
    @category_window.item_window = @item_window
    @category_window.set_handler(:ok,   method(:on_category_ok))
    @category_window.set_handler(:cancel,    method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリ［決定］
  #--------------------------------------------------------------------------
  def on_category_ok
    @category_window.close
    @rate_window.visible = false
    update until @category_window.close?
    @item_window.activate
    @item_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_cancel
    @help_window.clear
    @item_window.unselect
    @item_status_window.contents.clear
    @rate_window.visible = true
    @category_window.open.activate
  end
end

#==============================================================================
# □ Window_BookList
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_BookList_Item < Window_BookList
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :detail_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(y, height)
    super(y, height)
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def window_width
    248
  end
  #--------------------------------------------------------------------------
  # ○ アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if !item
    $game_system.book["item"][[@category, item.id]]
  end
  #--------------------------------------------------------------------------
  # ○ アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    @data = $game_temp.item_book[@category]
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item && enable?(item)
      rect = item_rect(index)
      draw_item_name(item, 4, rect.y)
    else
      rect = item_rect(index)
      draw_text(4, rect.y, 152, line_height, "??????")
    end
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウ更新メソッドの呼び出し
  #--------------------------------------------------------------------------
  def call_update_help
    update_help if active && @detail_window && @help_window
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @detail_window.item = (enable?(item) ? item : nil)
    @help_window.set_item(enable?(item) ? item : nil)
  end
end

#==============================================================================
# ■ Window_QuestCategory
#------------------------------------------------------------------------------
#　
#　
#==============================================================================

class Window_BookCategory_Item < Window_BookCategory
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Item",   :item)
    add_command("Valuable", :key_item)
    add_command("Weapon",   :weapon)
    add_command("Armor",   :armor)
    add_command("Rune", :rune)
    add_command("Skill", :skill_book)
  end
end

#==============================================================================
# □ Window_ItemStatus
#------------------------------------------------------------------------------
# 　アイテム画面で、アイテムの能力値を表示するウィンドウです。
#==============================================================================

class Window_ItemStatus_Book < Window_ItemStatus
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  alias book_refresh refresh
  def refresh
    book_refresh
=begin
    contents.clear
    draw_category(4, 0)
    return if !@item || !self.visible
    draw_kana(4, line_height) #追加
    ay = 0
    if @item.is_a?(RPG::EquipItem)
      4.times {|i| draw_hmth(0, line_height * (2 + i), i, @item) }
      3.times {|i| draw_xparam(0, line_height * (5 + i), i, @item) }
      6.times {|i| draw_item(160, line_height * (2 + i), 2 + i) }
      draw_description(0, line_height, @item) if @item.is_a?(RPG::Armor)
      draw_description_add(0, line_height, @item) if @item.is_a?(RPG::Weapon)
      ay += 3
    elsif @item.is_a?(RPG::Item)
      ary = effects_set(@item)
      draw_effects(160, line_height, ary, @item)
      draw_oc_sc(0, line_height, @item)
      draw_stbude(0, 8, ary)
      ay += 3
    elsif @item.is_a?(RPG::Skill)
      ary = effects_set(@item)
      ary.shift
      ary.shift
      ary.shift
      draw_type(144, 0, @item)
      draw_os(0, line_height, @item)
      draw_stbude(0, 4, ary, @item.remove_hide)
      draw_cost(0, 8, @item)
      draw_horz_line(line_height * 9)
      if @item.base != 0
        draw_damage(8, 10, @item)
        draw_horz_line(line_height * 12)
        ay += 3 #if @item.stype_id != 8
      end
      if @item.use_limit != 0
        draw_use_limit(8, line_height * (10 + ay), @item)
        ay += 1
      end
    end
    draw_another(4, line_height * (10 + ay), @item)
=end
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの変更トリガー
  #--------------------------------------------------------------------------
  def window_change
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの非表示化設定
  #--------------------------------------------------------------------------
  def window_off
  end
end

#==============================================================================
# ■ Window_CollectionRate
#------------------------------------------------------------------------------
# 　図鑑収集率を表示するウィンドウです。
#==============================================================================

class Window_CollectionRate_Item < Window_CollectionRate
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def collect_rate(category, true_route = false)
    ary = $game_system.book["item"].select {|a| a.include?(category)}
    return 100 * book_collect_number_item(true_route, ary) / $game_temp.item_book[category].size
    #return 100 * ary.size / $game_temp.item_book[category].size
  end
end