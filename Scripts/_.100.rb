#==============================================================================
# □ Window_LearnList
#------------------------------------------------------------------------------
# 　技習得画面で、習得できるスキルの一覧を表示するウィンドウです。
#==============================================================================
class Window_LearnList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :stype_window
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  alias stype_initialize initialize
  def initialize(x, y, width, height)
    stype_initialize(x, y, width, height)
    list_reset
  end
  #--------------------------------------------------------------------------
  # ○ アクターの設定
  #--------------------------------------------------------------------------
  def list_reset
    @page_index = 0
    @stype_list = []
  end
  #--------------------------------------------------------------------------
  # ○ アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    list_reset
    @actor.added_skill_types.sort.each {|stype_id| @stype_list.push(stype_id) } if @actor
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def stype_id
    @stype_list[@page_index]
  end
  #--------------------------------------------------------------------------
  # ○ スキルをリストに含めるかどうか
  #--------------------------------------------------------------------------
  alias stype_include? include?
  def include?(item)
    return false if item.stype_id != stype_id
    stype_include?(item)
  end
  #--------------------------------------------------------------------------
  # ○ 最大ページ数の取得
  #--------------------------------------------------------------------------
  def page_max
    @stype_list.size
  end
  #--------------------------------------------------------------------------
  # ○ ページの変更
  #--------------------------------------------------------------------------
  def page_index(page_index)
    @page_index += page_index
    @page_index = 0 if @page_index > page_max - 1
    @page_index = page_max - 1 if @page_index < 0
    refresh
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
  # ○ スキルタイプウィンドウの設定
  #--------------------------------------------------------------------------
  def stype_window=(stype_window)
    @stype_window = stype_window
    update
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    if @stype_window
      @stype_window.stype_change(@stype_list, stype_id)
    end
  end
end

#==============================================================================
# □ Window_
#------------------------------------------------------------------------------
# 　
#   
#==============================================================================

class Window_SkillType < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(wy)
    super(0, wy, window_width, fitting_height(4))
    @stype_id = 0
    @stype_list = []
    self.opacity = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def stype_change(list, id)
    return if @stype_list == list && @stype_id == id
    @stype_list = list
    @stype_id = id
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_stype(4, line_height * 3)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def draw_stype(x, y)
    @stype_list.each_with_index do |stype_id, i|
      change_color(system_color, @stype_id == stype_id)
      draw_text(x + 110 + 48 * i, y, 48, line_height, Vocab::stype_name(stype_id), 1)
    end
    fs = contents.font.clone
    contents.font.size = 20
    change_color(normal_color)
    draw_text(x + 360, y + 2, window_width - 390, line_height, "#{key_button("A")}・#{key_button("S")} - Switch", 2)
    contents.font = fs
  end
end

#==============================================================================
# □ Window_LearnList
#------------------------------------------------------------------------------
# 　スキルアップ画面で、アップできるスキルの一覧を表示するウィンドウです。
#==============================================================================

class Window_SkillUpList < Window_LearnList
  #--------------------------------------------------------------------------
  # ○ スキルをリストに含めるかどうか
  #--------------------------------------------------------------------------
  alias lvup_stype_include? include?
  def include?(item)
    return false if item.stype_id != @stype_list[@page_index]
    lvup_stype_include?(item)
  end
end

#==============================================================================
# ■ Scene_Learn
#------------------------------------------------------------------------------
# 　技習得画面の処理を行うクラスです。
#==============================================================================

class Scene_Learn < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias stype_start start
  def start
    stype_start
    create_stype_window
  end
  #--------------------------------------------------------------------------
  # ● スキルタイプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_stype_window
    wy = 0 #@category_window.y + @category_window.height
    @stype_window = Window_SkillType.new(wy)
    @stype_window.viewport = @viewport
    @item_window.stype_window = @stype_window
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  alias stype_create_item_window create_item_window
  def create_item_window
    stype_create_item_window
    @item_window.set_handler(:x_change,     method(:prev_stype))
    @item_window.set_handler(:y_change,     method(:next_stype))
  end
  #--------------------------------------------------------------------------
  # ● カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  alias stype_create_category_window create_category_window
  def create_category_window
    stype_create_category_window
    @category_window.set_handler(:x_change,     method(:prev_stype_c))
    @category_window.set_handler(:y_change,     method(:next_stype_c))
  end
  #--------------------------------------------------------------------------
  # ● アイテム［選択］
  #--------------------------------------------------------------------------
  def prev_stype
    @item_window.page_index(-1)
    @item_window.select(0)
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ● アイテム［選択］
  #--------------------------------------------------------------------------
  def next_stype
    @item_window.page_index(1)
    @item_window.select(0)
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ● アイテム［選択］
  #--------------------------------------------------------------------------
  def prev_stype_c
    @item_window.page_index(-1)
    @item_window.select(0)
    @item_window.unselect
    @category_window.activate
  end
  #--------------------------------------------------------------------------
  # ● アイテム［選択］
  #--------------------------------------------------------------------------
  def next_stype_c
    @item_window.page_index(1)
    @item_window.select(0)
    @item_window.unselect
    @category_window.activate
  end
end