#==============================================================================
# ■ Window_ItemList
#------------------------------------------------------------------------------
# 　アイテム画面で、所持アイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_SelectionList < Window_ItemList
  include FRSHIFT
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, window_height)
    @page_index = $game_variables[Option::ItemStart]
    @category_list = category_set
    category_change
    refresh
    self.height = window_height
    select_last
    activate
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリのセット
  #--------------------------------------------------------------------------
  def category_set
    [:portion, :bottle, :cooking, :all]
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの切り替え
  #--------------------------------------------------------------------------
  def category_change
    @category = category
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの切り替え
  #--------------------------------------------------------------------------
  def category_telepo_change
    @page_index = 3
    category_change
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの取得
  #--------------------------------------------------------------------------
  def category
    @category_list[@page_index]
  end
  #--------------------------------------------------------------------------
  # ○ 最大ページ数の取得
  #--------------------------------------------------------------------------
  def page_max
    @category_list.size
  end
  #--------------------------------------------------------------------------
  # ○ ページの変更
  #--------------------------------------------------------------------------
  def page_index(page_index)
    @page_index += page_index
    @page_index = 0 if @page_index > page_max - 1
    @page_index = page_max - 1 if @page_index < 0
    category_change
    refresh
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    if @category == :cooking
      return unless item
      draw_icon(item.icon_index, x, y, enabled)
      item.id == $game_party.battle_eat_id ? change_color(important_color, enabled) : change_color(normal_color, enabled)
      draw_text(x + 24, y, width, line_height, item.name)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ● 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    14
  end
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    case @category
    when :portion
      item.is_a?(RPG::Item) && item.portion?
    when :bottle
      item.is_a?(RPG::Item) && item.party_effect? && !item.cooking?
    when :cooking
      item.is_a?(RPG::Item) && item.cooking?
    when :all
      item.is_a?(RPG::Item) && item.menu_ok?
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ○ Xボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_x
    Sound.play_cursor
    Input.update
    deactivate
    call_x_handler
  end
  #--------------------------------------------------------------------------
  # ○ Yボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_y
    Sound.play_cursor
    Input.update
    deactivate
    call_y_handler
  end
  
  
  #--------------------------------------------------------------------------
  # ○ 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def ex_current_item_enabled?
    item ? true : false
    #true
  end
  #--------------------------------------------------------------------------
  # ○ のハンドリング処理の追加
  #--------------------------------------------------------------------------
  def process_handling
    super
    return unless @category == :cooking
    return process_shift if shift_enabled? && Input.trigger?(:SHIFT)
  end
end

#==============================================================================
# ■ Window_ItemCategory
#------------------------------------------------------------------------------
# 　アイテム画面またはショップ画面で、通常アイテムや装備品の分類を選択するウィ
# ンドウです。
#==============================================================================

class Window_SelectionCategory < Window_Base
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :item_window
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @category = :none
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(1)
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 指定されたシンボルを持つコマンドにカーソルを移動
  #--------------------------------------------------------------------------
  def select_symbol(symbol)
    self.category = symbol
    @item_window.category_telepo_change
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの名前を取得
  #--------------------------------------------------------------------------
  def category_name
    case @category
    when :portion ; "ポーション系"
    when :bottle ; "ボトル"
    when :cooking ; "料理"
    when :all ; "使用可能全て"
    else ; ""
    end
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    self.category = @item_window.category if @item_window
  end
  #--------------------------------------------------------------------------
  # ○ アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def item_window=(item_window)
    @item_window = item_window
    update
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(4, 0, 24 * 6, line_height, "#{category_name}", 1)
    change_color(normal_color)
    if @category == :cooking
      last_font_size = contents.font.size
      contents.font.size -= 4
      draw_text(100, 0, window_width - 100, line_height, "#{key_button("A")}、#{key_button("S")}で種類を切り替え、#{key_button("shift")}で戦闘後即使用", 1)
      contents.font.size = last_font_size
    else
      draw_text(100, 0, window_width - 100, line_height, "#{key_button("A")}、#{key_button("S")}でアイテムの種類を切り替え", 1)
    end
  end
end

#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　アイテム画面の処理を行うクラスです。
#==============================================================================

class Scene_SelectionItem < Scene_Item#Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    #@category_window.openness = 0
    #@category_window.deactivate
    #create_help_window
    #create_item_window
    #create_item_status_window
    #create_servant_window
  end
  #--------------------------------------------------------------------------
  # 〇 アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    wy = @category_window.y + @category_window.height
    @item_window = Window_SelectionList.new(0, wy, Graphics.width)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:return_scene))
    @item_window.set_handler(:x_change, method(:prev_category))
    @item_window.set_handler(:y_change, method(:next_category))
    @item_window.set_handler(:shift_change, method(:eat_set))
    @category_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # 〇 カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  def create_category_window
    wy = @help_window.height
    @category_window = Window_SelectionCategory.new(0, wy)
    @category_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ○ アイテムステータスウィンドウの作成 
  #--------------------------------------------------------------------------
  def create_item_status_window
  end
  #--------------------------------------------------------------------------
  # ○ サーヴァントウィンドウの作成
  #--------------------------------------------------------------------------
  def create_servant_window
    @servant_window = Window_SummonList_Heal.new
    @servant_window.set_handler(:ok,     method(:on_servant_ok))
    @servant_window.set_handler(:cancel, method(:on_servant_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def prev_category
    @item_window.page_index(-1)
    @item_window.select_last
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def next_category
    @item_window.page_index(1)
    @item_window.select_last
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def eat_set
    if @item_window.item && ($game_party.battle_eat_id != @item_window.item.id)
      $game_party.battle_eat = @item_window.item
      $game_party.battle_eat_id = @item_window.item.id
    else
      $game_party.battle_eat = nil
      $game_party.battle_eat_id = 0
    end
    @item_window.activate
    @item_window.refresh
  end
  #--------------------------------------------------------------------------
  # ○ テレポ判定のシンボル
  #--------------------------------------------------------------------------
  def return_symbol
    return :all
  end
  #--------------------------------------------------------------------------
  # ○ テレポ判定のシンボル
  #--------------------------------------------------------------------------
  def category_process
    @item_window.select_last
  end
=begin
  #--------------------------------------------------------------------------
  # ○ サーヴァントウィンドウの作成
  #--------------------------------------------------------------------------
  def create_servant_window
    @servant_window = Window_SummonList_Heal.new
    @servant_window.set_handler(:ok,     method(:on_servant_ok))
    @servant_window.set_handler(:cancel, method(:on_servant_cancel))
    @item_status_window.servant_window = @servant_window
  end
  #--------------------------------------------------------------------------
  # ○ アイテムステータスウィンドウの作成 ※オリジナルの再定義
  #--------------------------------------------------------------------------
  def create_item_status_window
    wy = @help_window.height
    wh = Graphics.height - wy
    @item_status_window = Window_ItemStatus_SV.new(0, wy, Graphics.width / 2, wh)
    @item_status_window.actor_window = @actor_window
    @item_window.item_status_window = @item_status_window
  end
  #--------------------------------------------------------------------------
  # ● アイテム［決定］
  #--------------------------------------------------------------------------
  def on_item_ok
    $game_party.last_item.object = item
    determine_item
  end
  #--------------------------------------------------------------------------
  # ● アイテム使用時の SE 演奏
  #--------------------------------------------------------------------------
  def play_se_for_item
    Sound.play_use_item
  end
  #--------------------------------------------------------------------------
  # ● アイテムの使用
  #--------------------------------------------------------------------------
  def use_item
    super
    @item_window.redraw_current_item
  end
=end
end

#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● シーン遷移に関連する更新
  #--------------------------------------------------------------------------
  alias quick_item_update_scene update_scene
  def update_scene
    quick_item_update_scene
    update_call_q_item unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # ○ 特定ボタンによるクイックアイテム判定
  #--------------------------------------------------------------------------
  def update_call_q_item
    return if call_disabled
    call_q_item if Input.trigger?(:Z)
  end
  #--------------------------------------------------------------------------
  # ○ クイックアイテムの実行
  #--------------------------------------------------------------------------
  def call_q_item
    if !$game_system.menu_disabled
      Sound.play_ok
      SceneManager.call(Scene_SelectionItem)
    else
      Sound.play_buzzer
    end
  end
end

class RPG::UsableItem < RPG::BaseItem
  def portion?
    self.note =~ /\<回復系\>/
  end
  def cooking?
    self.note =~ /\<料理系\>/
  end
end