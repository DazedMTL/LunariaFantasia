#==============================================================================
# □ Scene_Quest
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_Quest < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_detail_window
    create_item_window
    create_category_window
  end
  #--------------------------------------------------------------------------
  # ○ 詳細ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_detail_window
    @detail_window = Window_QuestDetail.new
    @detail_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ○ アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    wh = @detail_window.height
    @item_window = Window_QuestList.new(wh)
    @item_window.detail_window = @detail_window
    @item_window.viewport = @viewport
    @item_window.set_handler(:cancel, method(:on_item_cancel))
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_QuestCategory.new
    @category_window.viewport = @viewport
    @category_window.item_window = @item_window
    @category_window.set_handler(:main,   method(:on_category_ok))
    @category_window.set_handler(:sub,    method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:return_scene))
    @detail_window.y = @category_window.height
    @item_window.y = @category_window.height
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリ［決定］
  #--------------------------------------------------------------------------
  def on_category_ok
    @item_window.activate
    @item_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_cancel
    @category_window.activate
    @detail_window.clear
    @item_window.unselect
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
  alias quest_add_original_commands add_original_commands
  def add_original_commands
    quest_add_original_commands
    add_command("クエスト",  :quest)
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
  alias quest_create_command_window create_command_window
  def create_command_window
    quest_create_command_window
    @command_window.set_handler(:quest,     method(:on_quest))
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def on_quest
    SceneManager.call(Scene_Quest)
  end
end
