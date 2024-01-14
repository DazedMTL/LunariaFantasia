#==============================================================================
# □ Scene_Quest
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_Book < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_item_window
    create_detail_window
    create_category_window
    create_help_window
    create_rate_window
  end
  #--------------------------------------------------------------------------
  # ○ ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_BookHelp.new
    @help_window.z = 200
    @item_window.help_window = @help_window
    @category_window.help_window = @help_window
  end
  #--------------------------------------------------------------------------
  # ○ 収集率ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_rate_window
    @rate_window = Window_CollectionRate.new
    @category_window.rate_window = @rate_window
  end
  #--------------------------------------------------------------------------
  # ○ 詳細ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_detail_window
    @detail_window = Window_BookDetail.new(0, 19)
    @detail_window.viewport = @viewport
    @item_window.detail_window = @detail_window
  end
  #--------------------------------------------------------------------------
  # ○ アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    wh = 480#@detail_window.height
    @item_window = Window_BookList.new(0, wh)
    @item_window.viewport = @viewport
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @item_window.set_handler(:y_change, method(:page_next))
    @item_window.set_handler(:x_change, method(:page_prev))
    @item_window.set_handler(:z_change, method(:change_text))
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_BookCategory.new
    @category_window.viewport = @viewport
    @category_window.item_window = @item_window
    @category_window.set_handler(:ok,   method(:on_category_ok))
    #@category_window.set_handler(:monster,   method(:on_category_ok))
    #@category_window.set_handler(:character, method(:on_category_ok))
    @category_window.set_handler(:item,      method(:on_category_ok_item))
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
  # ○ カテゴリ［決定］
  #--------------------------------------------------------------------------
  def on_category_ok_item
    SceneManager.call(Scene_BookItem)
  end
  #--------------------------------------------------------------------------
  # ○ アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_cancel
    @detail_window.clear
    @help_window.clear
    @item_window.unselect
    @rate_window.visible = true
    @category_window.open.activate
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def change_text
    if @category_window.current_symbol == :character
      @help_window.flag_change
    elsif @category_window.current_symbol == :monster
      @detail_window.flag_change
    end
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def page_next
    if @category_window.current_symbol == :monster
      @detail_window.page_next
    end
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def page_prev
    if @category_window.current_symbol == :monster
      @detail_window.page_prev
    end
    @item_window.activate
  end
end

#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　メニュー画面で表示するコマンドウィンドウです。
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● 独自コマンドの追加用　※エイリアス
  #--------------------------------------------------------------------------
  alias book_add_original_commands add_original_commands
  def add_original_commands
    book_add_original_commands
    add_command("Book",  :book)
  end
end

#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　メニュー画面の処理を行うクラスです。
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias book_create_command_window create_command_window
  def create_command_window
    book_create_command_window
    @command_window.set_handler(:book,     method(:on_book))
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def on_book
    SceneManager.call(Scene_Book)
  end
end
