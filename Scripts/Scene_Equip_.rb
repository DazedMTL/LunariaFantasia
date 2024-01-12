#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_class_start start
  def start
    equip_class_start
    create_skillslot_window
    create_skill_window
  end
  #--------------------------------------------------------------------------
  # ○ スキルスロットウィンドウの作成
  #--------------------------------------------------------------------------
  def create_skillslot_window
    wx = @slot_window.x
    wy = @slot_window.y
    ww = @slot_window.width
    @skillslot_window = Window_EquipSkillSlot.new(wx, wy, ww)
    @skillslot_window.viewport = @viewport
    @skillslot_window.help_window = @help_window
    @skillslot_window.status_window = @status_window
    @skillslot_window.actor = @actor
    @skillslot_window.set_handler(:ok,       method(:on_skillslot_ok))
    @skillslot_window.set_handler(:cancel,   method(:on_skillslot_cancel))
    @command_window.skillslot_window = @skillslot_window
  end
  #--------------------------------------------------------------------------
  # ○ 装填用スキルウィンドウの作成
  #--------------------------------------------------------------------------
  def create_skill_window
    wx = @item_window.x
    wy = @skillslot_window.y + @skillslot_window.height
    ww = @item_window.width
    wh = Graphics.height - wy
    @skill_window = Window_EquipSkill.new(wx, wy, ww, wh)
    @skill_window.viewport = @viewport
    @skill_window.help_window = @help_window
    @skill_window.status_window = @status_window
    @skill_window.actor = @actor
    @skill_window.set_handler(:ok,     method(:on_skill_ok))
    @skill_window.set_handler(:cancel, method(:on_skill_cancel))
    @skillslot_window.item_window = @skill_window
    @command_window.skill_window = @skill_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_class_create_command_window create_command_window
  def create_command_window
    equip_class_create_command_window
    @command_window.set_handler(:skill,    method(:command_skill))
  end
  #--------------------------------------------------------------------------
  # ● スロットウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_class_create_slot_window create_slot_window
  def create_slot_window
    equip_class_create_slot_window
    @command_window.slot_window = @slot_window
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_class_create_item_window create_item_window
  def create_item_window
    equip_class_create_item_window
    @command_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # ○ コマンド［能力装填］
  #--------------------------------------------------------------------------
  def command_skill
    @skillslot_window.activate
    @skillslot_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ スキルスロット［決定］
  #--------------------------------------------------------------------------
  def on_skillslot_ok
    @skill_window.activate
    @skill_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ スキルスロット［キャンセル］
  #--------------------------------------------------------------------------
  def on_skillslot_cancel
    @skillslot_window.unselect
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ 装填スキル［決定] 
  #--------------------------------------------------------------------------
  def on_skill_ok
    Sound.play_equip
    @actor.equip_classchange(@skillslot_window.index, @skill_window.item)
    @skillslot_window.activate
    @skillslot_window.refresh
    @skill_window.select(0)
    @skill_window.unselect
    @skill_window.refresh
  end
  #--------------------------------------------------------------------------
  # ○ 装填スキル［キャンセル］
  #--------------------------------------------------------------------------
  def on_skill_cancel
    @skillslot_window.activate
    @skill_window.unselect
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え　※エイリアス
  #--------------------------------------------------------------------------
  alias e_class_se_on_actor_change on_actor_change
  def on_actor_change
    @skillslot_window.actor = @actor
    @skill_window.actor     = @actor
    e_class_se_on_actor_change
  end
end
