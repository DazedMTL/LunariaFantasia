#==============================================================================
# ■ Window_EquipCommand
#------------------------------------------------------------------------------
# 　装備画面で、コマンド（装備変更、最強装備など）を選択するウィンドウです。
#==============================================================================

class Window_EquipCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :item_window
  attr_reader   :slot_window
  attr_reader   :skill_window
  attr_reader   :skillslot_window
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成　※再定義
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::equip2,     :equip)
    add_command(Vocab::optimize,   :optimize)
    add_command(FAKEREAL::ABILITY, :skill)
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @item_window.category = current_symbol      if @item_window
    @slot_window.category = current_symbol      if @slot_window
    @skill_window.category = current_symbol     if @skill_window
    @skillslot_window.category = current_symbol if @skillslot_window
  end
  #--------------------------------------------------------------------------
  # ○ アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def item_window=(item_window)
    @item_window = item_window
    update
  end
  #--------------------------------------------------------------------------
  # ○ スロットウィンドウの設定
  #--------------------------------------------------------------------------
  def slot_window=(slot_window)
    @slot_window = slot_window
    update
  end
  #--------------------------------------------------------------------------
  # ○ スキルスロットウィンドウの設定
  #--------------------------------------------------------------------------
  def skillslot_window=(skillslot_window)
    @skillslot_window = skillslot_window
    update
  end
  #--------------------------------------------------------------------------
  # ○ スキルウィンドウの設定
  #--------------------------------------------------------------------------
  def skill_window=(skill_window)
    @skill_window = skill_window
    update
  end
end

#==============================================================================
# ■ Window_EquipSlot
#------------------------------------------------------------------------------
# 　装備画面で、アクターが現在装備しているアイテムを表示するウィンドウです。
#==============================================================================

class Window_EquipSlot < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_class_initialize initialize
  def initialize(x, y, width)
    equip_class_initialize(x, y, width)
    @category = nil
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    if @category != :skill
      self.show
    else
      self.hide
    end
    refresh
  end
end

#==============================================================================
# ■ Window_EquipItem
#------------------------------------------------------------------------------
# 　装備画面で、装備変更の候補となるアイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias equip_class_initialize initialize
  def initialize(x, y, width, height)
    equip_class_initialize(x, y, width, height)
    @category = nil
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    if @category != :skill
      self.show
    else
      self.hide
    end
    refresh
  end
end

#==============================================================================
# □ Window_EquipSkillSlot
#------------------------------------------------------------------------------
# 　装備画面で、アクターが現在装備している装備技能を表示するウィンドウです。
#==============================================================================

class Window_EquipSkillSlot < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # ステータスウィンドウ
  attr_reader   :item_window              # アイテムウィンドウ
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, window_height)
    @actor = nil
    @category = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    if @category == :skill
      self.show
    else
      self.hide
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ○ 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return ECSystem::EC_NUMBER
  end
  #--------------------------------------------------------------------------
  # ○ アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @item_window.slot_id = index if @item_window
  end
  #--------------------------------------------------------------------------
  # ○ 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    @actor ? ECSystem::EC_NUMBER : 0
  end
  #--------------------------------------------------------------------------
  # ○ 装備スキルの取得
  #--------------------------------------------------------------------------
  def item
    @actor ? @actor.change_skill[index] : nil
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    return unless @actor
    rect = item_rect_for_text(index)
    change_color(normal_color)
    item = @actor.change_skill[index]
    if item
      draw_item_name(item, rect.x + 100, rect.y)
    elsif lock?(index)
      change_color(system_color)
      draw_text(rect.x, rect.y, rect.width, rect.height, lock_text(index), 1)
    else
      draw_text(rect.x + 100, rect.y, rect.width, rect.height, "----------------")
    end
  end
  #--------------------------------------------------------------------------
  # ○ 装備スロットを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(index)
    @actor ? @actor.equip_skill_change_ok?(index) : false
  end
  #--------------------------------------------------------------------------
  # ○ 装備スロットを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def lock?(index)
    !@actor.equip_skill_change_ok?(index)
  end
  #--------------------------------------------------------------------------
  # ○ 装備スロットを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def lock_text(index)
    ss = @actor.skill_slot[index]
    case ss[1].upcase
    when "LV"
      return "解放条件:Lv#{ss[2]}"
    when "SKILL"
      return "解放条件:スキル習得"
    when "SWITCHES"
      return ""
    else
      return ""
    end
  end
  #--------------------------------------------------------------------------
  # ○ 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(index)
  end
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ○ アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def item_window=(item_window)
    @item_window = item_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ○ ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_item(item) if @help_window
    @status_window.set_temp_actor(nil) if @status_window
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画　※オーバーライド
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 196)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    star = ""
    @actor.skill_lv(item.id).times do |i|
      star += "★" unless i == 0
    end
    if $game_system.skill_lv_visible && item.lvup_able? #note =~ /\<スキルレベルAP:(\d+),(\d+)\>/
      draw_text(x + 24, y, width, line_height, item.name + " #{star}")
    else
      draw_text(x + 24, y, width, line_height, item.name)
    end
  end
end

#==============================================================================
# □ Window_EquipSkill
#------------------------------------------------------------------------------
# 　装備画面で、装備変更の候補となる装備技能の一覧を表示するウィンドウです。
#==============================================================================

class Window_EquipSkill < Window_ItemList
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  Skill_Visible = false              # 装備したスキルを表示するかどうか
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # ステータスウィンドウ
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @actor = nil
    @slot_id = 0
    @category = nil
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    if @category == :skill
      self.show
    else
      self.hide
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画　※オーバーライド
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
    else
      rect = item_rect(index)
      rect.width -= 4
      draw_nil_name(rect.x, rect.y, enable?(item))
    end
  end
  #--------------------------------------------------------------------------
  # ○ 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ○ アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ○ 装備スロット ID の設定
  #--------------------------------------------------------------------------
  def slot_id=(slot_id)
    return if @slot_id == slot_id
    @slot_id = slot_id
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ○ アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::Skill)
    unless Skill_Visible
      return false if @actor.skill_equip?(item)
    end
    return item.stype_id == ECSystem::EC_S_ID
  end
  #--------------------------------------------------------------------------
  # ○ アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = @actor.skills.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end
  #--------------------------------------------------------------------------
  # ○ アイテムを許可状態で表示するかどうか ★
  #--------------------------------------------------------------------------
=begin
  def enable?(item)
    if Skill_Visible
      return true if item.is_a?(NilClass)
      !@actor.skill_equip?(item)
    else
      return true
    end
  end
=end
  def enable?(item)
    if Skill_Visible
      return true if item.is_a?(NilClass)
      return true if skill_change_ok?(item)
      #!@actor.skill_equip?(item) && !@actor.skill_type_equip?(item)
      !@actor.skill_equip?(item)
    else
      return true if item.is_a?(NilClass)
      return true if skill_change_ok?(item)
      false
      #!@actor.skill_type_equip?(item)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 選択スロットと交換可能か ★
  #--------------------------------------------------------------------------
  def skill_change_ok?(skill)
    list = @actor.equip_skill_type_all - @actor.equip_skill_type[@slot_id]
    return !skill.ab_type.any? {|es| list.include?(es)}
    #return true if ECSystem.ab_type(skill) == @actor.equip_skill_type[@slot_id]
  end
  #--------------------------------------------------------------------------
  # ○ 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
  end
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ○ ヘルプテキスト更新
  #--------------------------------------------------------------------------
  #def update_help
    #super
    #if @actor && @status_window
      #temp_actor = Marshal.load(Marshal.dump(@actor))
      #temp_actor.force_change_equip_class(@slot_id, item)
      #@status_window.set_temp_actor(temp_actor)
    #end
  #end
  #--------------------------------------------------------------------------
  # 〇 ヘルプウィンドウ更新メソッドの呼び出し
  #--------------------------------------------------------------------------
  def call_update_help
    super
    update_status if active && @actor && @status_window
  end
  #--------------------------------------------------------------------------
  # 〇 ステータス更新
  #--------------------------------------------------------------------------
  def update_status
    temp_actor = Marshal.load(Marshal.dump(@actor))
    temp_actor.force_change_equip_class(@slot_id, item)
    @status_window.set_temp_actor(temp_actor)
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画　※オーバーライド
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 196)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    star = ""
    @actor.skill_lv(item.id).times do |i|
      star += "★" unless i == 0
    end
    if $game_system.skill_lv_visible && item.lvup_able? #note =~ /\<スキルレベルAP:(\d+),(\d+)\>/
      draw_text(x + 24, y, width, line_height, item.name + " #{star}")
    else
      draw_text(x + 24, y, width, line_height, item.name)
    end
  end
end
