# 戦闘中武器変更　　※一部処理は個別追加コマンドに

#==============================================================================
# ■ Window_EquipSlot
#------------------------------------------------------------------------------
# 　装備画面で、アクターが現在装備しているアイテムを表示するウィンドウです。
#==============================================================================

class Window_BattleEquipSlot < Window_EquipSlot
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width)
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ○ 装備スロットを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(index)
    @actor ? @actor.index_to_etype_id(index) == 0 : false
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの表示
  #--------------------------------------------------------------------------
  def show
    @help_window.show
    super
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの非表示
  #--------------------------------------------------------------------------
  def hide
    @help_window.hide
    super
  end
end

#==============================================================================
# ■ Window_EquipStatus
#------------------------------------------------------------------------------
# 　装備画面で、アクターの能力値変化を表示するウィンドウです。
#==============================================================================

class Window_BattleEquipStatus < Window_EquipStatus
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ○ ページの更新
  #--------------------------------------------------------------------------
  def update_page
    if visible && ((Input.trigger?(:RIGHT)) || Input.trigger?(:Y))
      Sound.play_cursor
      @page_index = (@page_index + 1) % page_max
      refresh
    elsif visible && ((Input.trigger?(:LEFT)) || Input.trigger?(:X))
      Sound.play_cursor
      @page_index = (@page_index - 1) % page_max
      refresh
    end
  end
end

#==============================================================================
# ■ Window_EquipItem
#------------------------------------------------------------------------------
# 　装備画面で、装備変更の候補となるアイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_BattleEquipItem < Window_EquipItem
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ○ アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return false if @actor == nil
    super(item)
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias be_create_all_windows create_all_windows
  def create_all_windows
    be_create_all_windows
    create_equip_status_window
    create_slot_window
    create_equip_item_window
  end
  #--------------------------------------------------------------------------
  # ● アクターコマンドウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias be_create_actor_command_window create_actor_command_window
  def create_actor_command_window
    be_create_actor_command_window
    @actor_command_window.set_handler(:equip,  method(:command_equip))
  end
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_equip_status_window
    @equip_status_window = Window_BattleEquipStatus.new(0, @help_window.height)
    @equip_status_window.viewport = @viewport
    @equip_status_window.actor = nil
  end
  #--------------------------------------------------------------------------
  # ○ スロットウィンドウの作成
  #--------------------------------------------------------------------------
  def create_slot_window
    wx = @equip_status_window.width
    wy = @help_window.height
    ww = Graphics.width - @equip_status_window.width
    @slot_window = Window_BattleEquipSlot.new(wx, wy, ww)
    @slot_window.viewport = @viewport
    @slot_window.help_window = @help_window
    @slot_window.status_window = @equip_status_window
    @slot_window.actor = nil
    @slot_window.set_handler(:ok,       method(:on_slot_ok))
    @slot_window.set_handler(:cancel,   method(:on_slot_cancel))
  end
  #--------------------------------------------------------------------------
  # ○ アイテムウィンドウの作成　
  #--------------------------------------------------------------------------
  def create_equip_item_window
    wx = @slot_window.x
    wy = @slot_window.y + @slot_window.height
    ww = Graphics.width - @equip_status_window.width
    wh = Graphics.height - wy
    @equip_item_window = Window_BattleEquipItem.new(wx, wy, ww, wh)
    @equip_item_window.viewport = @viewport
    @equip_item_window.help_window = @help_window
    @equip_item_window.status_window = @equip_status_window
    @equip_item_window.actor = nil
    @equip_item_window.set_handler(:ok,     method(:on_equip_ok))
    @equip_item_window.set_handler(:cancel, method(:on_equip_cancel))
    @slot_window.item_window = @equip_item_window
  end
  #--------------------------------------------------------------------------
  # ○ コマンド［装備変更］
  #--------------------------------------------------------------------------
  def command_equip
    @slot_window.show.activate
    @slot_window.select(0)
    @equip_item_window.show
    @equip_status_window.show
  end
  #--------------------------------------------------------------------------
  # ○ スロット［決定］
  #--------------------------------------------------------------------------
  def on_slot_ok
    @equip_item_window.activate
    @equip_item_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ スロット［キャンセル］
  #--------------------------------------------------------------------------
  def on_slot_cancel
    @slot_window.hide.deactivate
    @equip_item_window.hide
    @equip_status_window.hide
    @actor_command_window.refresh #######
    @actor_command_window.activate
    refresh_status
  end
  #--------------------------------------------------------------------------
  # ○ アイテム［決定］
  #--------------------------------------------------------------------------
  def on_equip_ok
    Sound.play_equip
    BattleManager.actor.change_equip(@slot_window.index, @equip_item_window.item)
    @slot_window.activate
    @slot_window.refresh
    @equip_item_window.unselect
    @equip_item_window.refresh
    # ↓　PTリピート用追加項目　通常攻撃をリピートした場合武器変更前のスキルで攻撃してしまうのの対策（鞭から杖にした場合杖で複数体を攻撃してしまう等）
    $game_temp.repeat_commands[BattleManager.actor.id] = []
  end
  #--------------------------------------------------------------------------
  # ○ アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_equip_cancel
    @slot_window.activate
    @equip_item_window.unselect
  end
  #--------------------------------------------------------------------------
  # ● 次のコマンド入力へ　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_next_command next_command
  def next_command
    @equip_status_window.actor = nil
    @equip_item_window.actor = nil
    @slot_window.actor = nil
    equip_next_command
  end
  #--------------------------------------------------------------------------
  # ● アクターコマンド選択の開始　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_start_actor_command_selection start_actor_command_selection
  def start_actor_command_selection
    equip_start_actor_command_selection
    @equip_status_window.actor = BattleManager.actor
    @equip_item_window.actor = BattleManager.actor
    @slot_window.actor = BattleManager.actor
  end
end