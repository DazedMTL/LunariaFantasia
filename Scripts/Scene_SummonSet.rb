#==============================================================================
# □ Scene_SummonSet
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_SummonSet < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    #$game_party.summon_number_check
    create_help_window
    create_item_window
    create_dummy_window
    create_skill_window
    create_status_window
    create_equip_window
    create_talisman_window
    create_name_window
    create_slot_window
  end
  #--------------------------------------------------------------------------
  # ○ サーヴァント候補ウィンドウの作成　item_window
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 0 # @slot_window.x
    wy = @help_window.height #@slot_window.y + @slot_window.height
    #ww = @slot_window.width
    wh = Graphics.height - @help_window.height
    @item_window = Window_SummonList.new(wx, wy, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    #@item_window.status_window = @status_window
    #@item_window.skill_window = @skill_window
    #@item_window.equip_window = @equip_window
    #@item_window.talisman_window = @talisman_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @item_window.set_handler(:x_change, method(:change_skill))
    @item_window.set_handler(:y_change, method(:change_equip))
    @item_window.set_handler(:z_change, method(:change_status))
    #@slot_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # 〇 ダミーウィンドウの作成
  #--------------------------------------------------------------------------
  def create_dummy_window
    #wx = @item_window.x
    wx = Graphics.width - @item_window.width
    wy = @item_window.y
    ww = @item_window.width
    wh = @item_window.height
    @dummy_window = Window_Base.new(wx, wy, ww, wh)
    @dummy_window.viewport = @viewport
    @item_window.x = wx
  end
  #--------------------------------------------------------------------------
  # ○ スキルウィンドウの作成
  #--------------------------------------------------------------------------
  def create_skill_window
    @skill_window = Window_SummonSkills.new(@help_window.height, @help_window.height)
    @skill_window.help_window = @help_window
    @skill_window.set_handler(:cancel,     method(:skill_off))
    @skill_window.set_handler(:x_change,   method(:skill_off))
    @help_window.viewport = nil
  end
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    wx = @item_window.x
    wy = @item_window.y
    ww = @item_window.width
    @status_window = Window_SummonStatus.new(wx, wy, ww, @help_window.height)
    @status_window.set_handler(:ok,         method(:status_off))
    @status_window.set_handler(:cancel,     method(:status_off))
    @status_window.set_handler(:z_change,   method(:status_off))
    @status_window.set_handler(:pagedown, method(:next_actor))
    @status_window.set_handler(:pageup,   method(:prev_actor))
    @status_window.help_window = @help_window
  end
  #--------------------------------------------------------------------------
  # ○ 現在装備中の護符ウィンドウの作成　equip_window
  #--------------------------------------------------------------------------
  def create_equip_window
    wx = 0 #@item_window.width
    wy = @item_window.y
    ww = Graphics.width - @item_window.width
    @equip_window = Window_SummonEquipSlot.new(wx, wy, ww)
    @equip_window.help_window = @help_window
    @equip_window.set_handler(:ok,         method(:change_talisman))
    @equip_window.set_handler(:cancel,     method(:equip_off))
    @equip_window.set_handler(:y_change,   method(:equip_off))
    @equip_window.set_handler(:pagedown, method(:next_actor))
    @equip_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ○ 装備護符の候補ウィンドウの作成　talisman_window
  #--------------------------------------------------------------------------
  def create_talisman_window
    wx = 0 #@item_window.width
    wy = @item_window.y + @equip_window.height
    ww = Graphics.width - @item_window.width
    wh = Graphics.height - wy
    @talisman_window = Window_Talisman.new(wx, wy, ww, wh)
    @talisman_window.help_window = @help_window
    #@talisman_window.status_window = @status_window
    @talisman_window.set_handler(:ok,         method(:on_talisman_ok))
    @talisman_window.set_handler(:cancel,     method(:talisman_cancel))
    @equip_window.item_window = @talisman_window
    @talisman_window.viewport = @viewport
    @talisman_window.hide
  end
  #--------------------------------------------------------------------------
  # ○ 現在セット中のサーヴァントスロットウィンドウの作成　slot_window
  #--------------------------------------------------------------------------
  def create_slot_window
    wx = 0 #@item_window.width
    wy = 0 #@item_window.y
    ww = Graphics.width - @item_window.width
    @slot_window = Window_SummonSlot.new(wx, wy, ww)
    @slot_window.y = Graphics.height - @slot_window.height
    @slot_window.viewport = @viewport
    @slot_window.help_window = @help_window
    #@slot_window.status_window = @status_window
    #@slot_window.skill_window = @skill_window
    #@slot_window.equip_window = @equip_window
    #@slot_window.talisman_window = @talisman_window
    @slot_window.set_handler(:ok,       method(:on_slot_ok))
    @slot_window.set_handler(:cancel,   method(:return_scene))
    @slot_window.set_handler(:x_change,   method(:change_skill))
    @slot_window.set_handler(:y_change,   method(:change_equip))
    @slot_window.set_handler(:z_change,   method(:change_status))
  end
  #--------------------------------------------------------------------------
  # ○ 名前ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_name_window
    wx = 0
    wy = @help_window.height
    ww = Graphics.width - @item_window.width
    wh = Graphics.height - wy
    @name_window = Window_SummonName.new(wx, wy, ww, wh)
    @name_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ○ スロット［決定］
  #--------------------------------------------------------------------------
  def on_slot_ok
    @dummy_window.hide
    @item_window.show.activate
    @item_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ アイテム［決定］
  #--------------------------------------------------------------------------
  def on_item_ok
    Sound.play_equip
    $game_party.summon_members_add(@slot_window.index, @item_window.actor)
    @slot_window.activate
    @slot_window.refresh
    @item_window.hide.unselect
    @item_window.refresh
    @dummy_window.show
    #@skill_window.hide
  end
  #--------------------------------------------------------------------------
  # ○ アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_cancel
    @slot_window.activate
    @item_window.hide.unselect
    @dummy_window.show
    #@skill_window.hide
  end
  #--------------------------------------------------------------------------
  # ○ スキルウィンドウオン
  #--------------------------------------------------------------------------
  def change_skill
    #@viewport.rect.x = @viewport.ox = @item_window.index < 0 ? @skill_window.width : 0
    @viewport.rect.x = @viewport.ox = @item_window.index < 0 ? 0 : @skill_window.width
    @viewport.rect.width = Graphics.width - @skill_window.width
    #@talisman_window.hide
    if @item_window.index < 0 
      @skill_window.window_x(false)
      @skill_window.actor = @slot_window.actor #SummonSystem::summon_obj(@slot_window.item.id)
    else
      @skill_window.window_x(true)
      @skill_window.actor = @item_window.actor #SummonSystem::summon_obj(@item_window.item.id)
    end
    @skill_window.show.activate
    @skill_window.select_last
  end
  #--------------------------------------------------------------------------
  # ○ スキルウィンドウオフ
  #--------------------------------------------------------------------------
  def skill_off
    @viewport.rect.x = @viewport.ox = 0
    @viewport.rect.width = Graphics.width
    @skill_window.hide.deactivate
    @skill_window.actor = nil
    #@talisman_window.show
    if @item_window.index < 0 
      @slot_window.activate
    else
      @item_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ○ 装備ウィンドウオン
  #--------------------------------------------------------------------------
  def change_equip
    @slot_window.hide
    @name_window.hide
    #@viewport.rect.width = Graphics.width - @equip_window.width
    if @item_window.index < 0 
      @talisman_window.actor = @slot_window.actor #SummonSystem::summon_obj(@slot_window.item.id)
      @equip_window.actor = @slot_window.actor #SummonSystem::summon_obj(@slot_window.item.id)
    else
      @talisman_window.actor = @item_window.actor #SummonSystem::summon_obj(@item_window.item.id)
      @equip_window.actor = @item_window.actor #SummonSystem::summon_obj(@item_window.item.id)
    end
    #@talisman_window.show
    status_visible
    @equip_window.show.activate
    @equip_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ 装備ウィンドウオフ
  #--------------------------------------------------------------------------
  def equip_off
    #@viewport.rect.width = Graphics.width
    #@status_window.set_temp_actor(nil)
    @equip_window.hide.deactivate
    #@talisman_window.hide
    @equip_window.actor = nil
    @talisman_window.actor = nil
    @slot_window.show
    @name_window.show
    status_hide
    if @item_window.index < 0 
      @slot_window.activate
    else
      @item_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ○ 護符ウィンドウオン
  #--------------------------------------------------------------------------
  def change_talisman
    @talisman_window.activate
    @talisman_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ 護符ウィンドウオフ
  #--------------------------------------------------------------------------
  def talisman_cancel
    @talisman_window.unselect
    @equip_window.activate
    #@status_window.set_temp_actor(nil)
  end
  #--------------------------------------------------------------------------
  # ○ 護符［決定］
  #--------------------------------------------------------------------------
  def on_talisman_ok
    Sound.play_equip
    @equip_window.equip_actor.change_equip(@equip_window.index, @talisman_window.item)
    @equip_window.activate
    @equip_window.refresh
    @talisman_window.unselect
    @talisman_window.refresh
    @item_window.refresh
    @slot_window.refresh
    @skill_window.refresh
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウオン 表示のみ
  #--------------------------------------------------------------------------
  def status_visible
    @viewport.rect.x = @viewport.ox = 0 #@status_window.width
    @viewport.rect.width = Graphics.width - @status_window.width #@slot_window.width
    if @item_window.index < 0 
      @status_window.actor = @slot_window.actor #SummonSystem::summon_obj(@slot_window.item.id)
    else
      @status_window.actor = @item_window.actor #SummonSystem::summon_obj(@item_window.item.id)
    end
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウオン
  #--------------------------------------------------------------------------
  def change_status
    #@viewport.rect.x = @viewport.ox = 0 #@status_window.width
    #@viewport.rect.width = Graphics.width - @status_window.width #@slot_window.width
    #if @item_window.index < 0 
      #@status_window.actor = SummonSystem::summon_obj(@slot_window.item.id)
    #else
      #@status_window.actor = SummonSystem::summon_obj(@item_window.item.id)
    #end
    status_visible.activate
    #@status_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウオフ
  #--------------------------------------------------------------------------
  def status_hide
    @viewport.rect.x = @viewport.ox = 0
    @viewport.rect.width = Graphics.width
    @status_window.actor = nil
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウオフ
  #--------------------------------------------------------------------------
  def status_off
    #@viewport.rect.x = @viewport.ox = 0
    #@viewport.rect.width = Graphics.width
    #@status_window.actor = nil
    #@status_window.hide.deactivate
    status_hide.deactivate
    if @item_window.index < 0 
      @slot_window.activate
    else
      @item_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ○ 次のアクターに切り替え
  #--------------------------------------------------------------------------
  def next_actor
    if @item_window.index < 0 
      @slot_window.next_actor
    else
      @item_window.next_actor
    end
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ○ 前のアクターに切り替え
  #--------------------------------------------------------------------------
  def prev_actor
    if @item_window.index < 0 
      @slot_window.prev_actor
    else
      @item_window.prev_actor
    end
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ○ アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    if @equip_window.visible
      change_equip
    else
      change_status
    end
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
  alias summonset_add_original_commands add_original_commands
  def add_original_commands
    summonset_add_original_commands
    add_command(Vocab::summon,  :summonset,  summon_commands_enabled)
  end
  #--------------------------------------------------------------------------
  # ○ 召喚コマンドの有効状態を取得
  #--------------------------------------------------------------------------
  def summon_commands_enabled
    $game_party.summon_number > 0 && $game_party.summon_enabled
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
  alias summonset_create_command_window create_command_window
  def create_command_window
    summonset_create_command_window
    @command_window.set_handler(:summonset,     method(:on_summon_set))
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def on_summon_set
    SceneManager.call(Scene_SummonSet)
  end
end

module Vocab
  def self.summon;       "Summon";   end   # 事前召喚 召喚ユニット
  def self.rune;         "Rune";   end   # サーヴァント用装備品
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
  alias summon_call_update_scene update_scene
  def update_scene
    summon_call_update_scene
    update_call_summon unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # ○ 特定ボタンによる召喚セット画面呼び出し判定
  #--------------------------------------------------------------------------
  def update_call_summon
    return if call_disabled #!$game_player.movable? || $game_map.interpreter.running? || Input.dir4 != 0
    return if !summon_commands_enabled
    call_summon if Input.trigger?(:R)
  end
  #--------------------------------------------------------------------------
  # ○ 召喚セット画面の呼び出し
  #--------------------------------------------------------------------------
  def call_summon
    Sound.play_ok
    SceneManager.call(Scene_SummonSet)
  end
  #--------------------------------------------------------------------------
  # ○ 召喚コマンドの有効状態を取得
  #--------------------------------------------------------------------------
  def summon_commands_enabled
    $game_party.summon_number > 0 && $game_party.summon_enabled
  end
end

