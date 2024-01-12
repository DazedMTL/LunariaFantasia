
module FRZB
  #--------------------------------------------------------------------------
  # ○ Zの有効状態を取得
  #--------------------------------------------------------------------------
  def z_enabled?
    handle?(:z_change)
  end
  #--------------------------------------------------------------------------
  # ○ Zボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_z
    if ex_current_item_enabled?
      Sound.play_cursor
      Input.update
      deactivate
      call_z_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ○ Zハンドラの呼び出し
  #--------------------------------------------------------------------------
  def call_z_handler
    call_handler(:z_change)
  end
end

#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　ゲーム中の全てのウィンドウのスーパークラスです。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # 〇 アクターの顔グラフィック描画
  #--------------------------------------------------------------------------
  def draw_actor_face_cut(actor, x, y, cut, enabled = true)
    draw_face_cut(actor.face_name, actor.face_index, x, y, cut, enabled)
  end
  #--------------------------------------------------------------------------
  # 〇 顔グラフィックの描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_face_cut(face_name, face_index, x, y, cut, enabled = true)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96 + cut, face_index / 4 * 96 + cut, 96 - cut * 2, 96 - cut * 2)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
end

#==============================================================================
# □ Window_SummonStatus
#------------------------------------------------------------------------------
# 　サーヴァントのステータス
#   
#==============================================================================

class Window_SummonStatus < Window_Selectable
  include FRZB
  include FRGP
  attr_reader   :actor            # 
  #--------------------------------------------------------------------------
  # ● 各種文字色の取得
  #--------------------------------------------------------------------------
  def next_color;      text_color(4);   end;    # 通常
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(wx, wy, ww, hw_height)
    super(wx, wy, ww, Graphics.height - hw_height)
    @actor = nil
    page_reset
    refresh
    hide
  end
  #--------------------------------------------------------------------------
  # ○ 最大ページ数の取得
  #--------------------------------------------------------------------------
  def page_max
    return @actor && @actor.id == 5 ? 4 : 3
  end
  #--------------------------------------------------------------------------
  # ○ ページの初期化
  #--------------------------------------------------------------------------
  def page_reset
    @page_index = 0
  end
  #--------------------------------------------------------------------------
  # ○ アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return if !@actor
    page_reset if @page_index == 3 && page_max == 3
    draw_page(line_height * 0)
    draw_actor_name(@actor, 4, 0)
    draw_actor_class(@actor, 120, 0)
    draw_actor_sex(@actor, 120, line_height * 1)#contents.width - 120, line_height * 2)
    draw_actor_level(@actor, 4, line_height * 1)
    draw_actor_face(@actor, 32, line_height * 2)
    draw_actor_point(160, line_height * 3)
    case @page_index
    when 0
      6.times {|i| draw_item(4, line_height * (6 + i), 2 + i) }
      3.times {|i| draw_item_ex(160, line_height * (8 + i), i) }
      draw_heal_rate(160, line_height * 11)
      draw_next_skills(50, line_height * 12)
    when 1
      ext = @actor.woman? ? nil : "魅了"
      draw_guard_state(60, line_height * 6, ext)
      draw_magic_elements(180, line_height * 6)
    when 2
      draw_guard_debuff(60, line_height * 6)
      draw_guard_elements(180, line_height * 6)
      draw_bonus(@actor, 4, line_height * 13)
    when 3
      contents.clear
      draw_page(line_height * 0)
      draw_actor_name(@actor, 4, 0)
      draw_stand(@actor, 1, 4, 0)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 習得スキルの描画
  #--------------------------------------------------------------------------
  def draw_next_skills(x, y)
    #change_color(power_up_color)
    change_color(next_color)
    draw_text(x + 8, y, 190, line_height, "NEXT習得スキル")
    draw_skills(x + 8, y, 190) if @actor
  end
  #--------------------------------------------------------------------------
  # ○ スキル一覧の描画
  #--------------------------------------------------------------------------
  def draw_skills(x, y, width)
    change_color(normal_color)
    @actor.next_skills.each_with_index do |learn, i|
      lv = learn.level
      draw_text(x, y + (i + 1) * line_height, 48, line_height, "Lv#{lv}", 2)
      skill = $data_skills[learn.skill_id]
      draw_item_name(skill, x + 52, y + (i + 1) * line_height, true, width / 2 + 24 )
    end
  end
  #--------------------------------------------------------------------------
  # ○ 回復率の描画
  #--------------------------------------------------------------------------
  def draw_heal_rate(x, y)
    change_color(system_color)
    draw_text(x + 4, y, 80, line_height, "回復率")
    draw_current_rate(x + 44, y, 84)
  end
  #--------------------------------------------------------------------------
  # ○ 現在の回復率の描画
  #--------------------------------------------------------------------------
  def draw_current_rate(x, y, width)
    change_color(normal_color)
    draw_text(x, y, width, line_height, "#{@actor.heal_rate}％", 2) if @actor
  end
  #--------------------------------------------------------------------------
  # ○ 名前の描画
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y, width = 112)
    change_color(normal_color)
    draw_text(x, y, width, line_height, actor.name)
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(x, y, param_id)
    draw_param_name(x + 4, y, param_id)
    draw_current_param(x + 94, y, param_id) if @actor
  end
  #--------------------------------------------------------------------------
  # ○ 能力値の名前を描画
  #--------------------------------------------------------------------------
  def draw_param_name(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, Vocab::param(param_id))
  end
  #--------------------------------------------------------------------------
  # ○ 現在の能力値を描画
  #--------------------------------------------------------------------------
  def draw_current_param(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 34, line_height, @actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画　※特殊能力
  #--------------------------------------------------------------------------
  def draw_item_ex(x, y, param_id)
    draw_xparam_name(x + 4, y, param_id)
    draw_current_xparam(x + 4, y, param_id) if @actor
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値の名前を描画
  #--------------------------------------------------------------------------
  def draw_xparam_name(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, FAKEREAL::xparam(param_id))
  end
  #--------------------------------------------------------------------------
  # ○ 現在の特殊能力値を描画
  #--------------------------------------------------------------------------
  def draw_current_xparam(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 124, line_height, "#{format("%.2f",ex_param(param_id, @actor))}", 2)
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値の取得
  #--------------------------------------------------------------------------
  def ex_param(param_id, actor)
    case param_id
    when 0;    return actor.hit * 100
    when 1;    return actor.eva * 100
    when 2;    return actor.cri * 100
    else  ;    return 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ HP の描画
  #--------------------------------------------------------------------------
  def draw_actor_point(x, y, width = 124)
    draw_actor_hp(@actor, x, y + line_height * 0)
    draw_actor_mp(@actor, x, y + line_height * 1)
    draw_actor_tp(@actor, x, y + line_height * 2)
  end
  #--------------------------------------------------------------------------
  # ○ ボーナス名の描画
  #--------------------------------------------------------------------------
  def draw_bonus_name(text, x, y, width = 242)
    change_color(power_up_color)
    draw_text(x, y, width, line_height, text)
  end
  #--------------------------------------------------------------------------
  # ○ ボーナスの種類の描画
  #--------------------------------------------------------------------------
  def draw_bonus(actor, x, y)
    b_name = $game_switches[FAKEREAL::LIBERATE_OPACITY] ? "魔力吸収率100%ボーナス" : "ボーナス"
    draw_bonus_name(b_name, x, y)
    change_color(normal_color)
    draw_text_ex(x + 4, y + line_height, actor.bonus_text)
  end
  #--------------------------------------------------------------------------
  # ○ ページ数の描画
  #--------------------------------------------------------------------------
  def draw_page(y)
    change_color(normal_color)
    draw_text(0, y, contents_width, line_height, "page#{@page_index + 1}/#{page_max}", 2)
    draw_text(-2, y + line_height, contents_width, line_height, "←　→", 2)
  end
  #--------------------------------------------------------------------------
  # 〇 グラフィックの描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_stand(actor, member_size, x, y, enabled = true)
    bitmap = Cache.stand("#{actor.graphic_name}_cos#{actor.costume}")
    space = 0
    rect = Rect.new(actor.stand_ox[member_size - 1] - 25, actor.graphic_status_oy, contents_width - space, contents_height) #Rect.new(stand_index % 4 * 96, stand_index / 4 * 96, item_width, 288)# / num, 288) #272 / num, 288)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ○ 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def ex_current_item_enabled?
    true
  end
  #--------------------------------------------------------------------------
  # ○ Zのハンドリング処理の追加
  #--------------------------------------------------------------------------
  def process_handling
    super
    return unless open? && active
    return process_z if z_enabled? && Input.trigger?(:Z)
  end
  #--------------------------------------------------------------------------
  # ○ ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_item(actor) if @help_window
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_page
  end
  #--------------------------------------------------------------------------
  # ○ ページの更新
  #--------------------------------------------------------------------------
  def update_page
    if visible && Input.trigger?(:RIGHT)
      Sound.play_cursor
      @page_index = (@page_index + 1) % page_max
      refresh
    elsif visible && Input.trigger?(:LEFT)
      Sound.play_cursor
      @page_index = (@page_index - 1) % page_max
      refresh
    end
  end
end

#==============================================================================
# □ Window_SummonSkills
#------------------------------------------------------------------------------
# 　サーヴァントの習得済スキル
#   
#==============================================================================

class Window_SummonSkills < Window_SkillList
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(wy, hw_height)
    super(0, wy, window_width, Graphics.height - hw_height)
    hide
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if skill
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(skill, rect.x, rect.y, enable?(skill), width / col_max - 56)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 200
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def window_x(left)
    if left
      self.x = 0
    else
      self.x = Graphics.width - window_width
    end
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● スキルを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    @actor
  end
  #--------------------------------------------------------------------------
  # ● スキルをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item, stype_id)
    item.stype_id == stype_id
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select(0)
  end
  #--------------------------------------------------------------------------
  # ● スキルリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    if @actor
      s_type = @actor.added_skill_types.sort
      s_type.each {|stype_id| @data += @actor.skills.select {|skill| include?(skill, stype_id) }} 
    end
  end
end

#==============================================================================
# □ Window_SummonSlot
#------------------------------------------------------------------------------
# 　サーヴァント画面で、アクターが現在セットしているサーヴァントを表示するウィンドウです。
#==============================================================================

class Window_SummonSlot < Window_ItemList
  include FRZB
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, window_height)
    refresh
    select(0)
    self.opacity = 0
    activate
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
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
    return 14 
  end
  #--------------------------------------------------------------------------
  # ○ アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_party.summon_members.collect {|actor_id| include?(actor_id) }
  end
  #--------------------------------------------------------------------------
  # 〇 アクターに変換
  #--------------------------------------------------------------------------
  def include?(actor_id)
    actor_id ? $game_actors[actor_id] : nil
  end
  #--------------------------------------------------------------------------
  # 〇 項目の高さを取得
  #--------------------------------------------------------------------------
  def item_height
    line_height * visible_line_number / SummonSystem::SUMMON_SLOT
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
      rect.width -= 4
    change_color(normal_color)
    if item
      draw_summon_actor_simple_status(status_actor(item), rect.x + 1, rect.y)
    else
      change_color(normal_color, enable?(index))
      draw_text(rect.x + 45, rect.y, rect.width, rect.height, "----------------")
    end
  end
  #--------------------------------------------------------------------------
  # ○ 装備スロットを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(index)
    index < $game_party.summon_number && max_member?(index)
  end
  #--------------------------------------------------------------------------
  # ○ 定員オーバーじゃないか
  #--------------------------------------------------------------------------
  def max_member?(index)
    index < ($game_party.max_battle_members - $game_party.members.size)
  end
  #--------------------------------------------------------------------------
  # ○ 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(index)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def actor
    if item 
      actor = item #SummonSystem::summon_obj(item.id)
      actor.summon_level_set($game_actors[1].level) if actor.level != $game_actors[1].level
      return actor
    else
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def status_actor(item)
    if item 
      actor = item #SummonSystem::summon_obj(item.id)
      actor.summon_level_set($game_actors[1].level) if actor.level != $game_actors[1].level
      return actor
    else
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # ● シンプルなステータスの描画
  #--------------------------------------------------------------------------
  def draw_summon_actor_simple_status(actor, x, y, cut = 3)
    draw_actor_face_cut(actor, x + 8, y + 12 + cut, cut)
    draw_actor_name(actor, x, y)
    draw_actor_class(actor, x + 112, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_hp(actor, x + 112, y + line_height * 1 + 12)
    draw_actor_mp(actor, x + 112, y + line_height * 2 + 12)
    draw_actor_tp(actor, x + 112, y + line_height * 3 + 12)
  end
  #--------------------------------------------------------------------------
  # ○ ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_summon_text(nil) if @help_window
  end
  #--------------------------------------------------------------------------
  # ○ Xボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_x
    if ex_current_item_enabled?
      Sound.play_cursor
      Input.update
      deactivate
      call_x_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ○ Yボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_y
    if ex_current_item_enabled?
      Sound.play_cursor
      Input.update
      deactivate
      call_y_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ○ 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def ex_current_item_enabled?
    item
  end
  #--------------------------------------------------------------------------
  # ○ Zのハンドリング処理の追加
  #--------------------------------------------------------------------------
  def process_handling
    super
    return unless open? && active
    return process_z if z_enabled? && Input.trigger?(:Z)
  end
  #--------------------------------------------------------------------------
  # ○ 次のサーヴァント
  #--------------------------------------------------------------------------
  def next_actor
    return if !@data[index]
    self.index += 1
    until @data[index]
      self.index += 1
      self.index = 0 if index > 2
    end
  end
  #--------------------------------------------------------------------------
  # ○ 前のサーヴァント
  #--------------------------------------------------------------------------
  def prev_actor
    return if !@data[index]
    self.index -= 1
    #self.index = 2 if index < 0
    until @data[index] && index >= 0
      self.index -= 1
      self.index = 2 if index < 0
    end
  end
end

#==============================================================================
# □ Window_SummonList
#------------------------------------------------------------------------------
# 　サーヴァント候補の一覧
#==============================================================================

class Window_SummonList < Window_ItemList
  include FRZB
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  #attr_reader   :status_window            # ステータスウィンドウ
  #attr_reader   :data                    # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, window_width, height)
    refresh
    hide
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 項目の幅を取得
  #--------------------------------------------------------------------------
  def window_width
    360
  end
  #--------------------------------------------------------------------------
  # ● 項目の幅を取得
  #--------------------------------------------------------------------------
  #def item_width
    #(width - standard_padding * 2 + spacing) / col_max - spacing
  #end
  #--------------------------------------------------------------------------
  # ● 項目の高さを取得
  #--------------------------------------------------------------------------
  def item_height
    line_height * 4
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画　※オーバーライド
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_summon_actor_simple_status(summon_actor(item), rect.x + 1, rect.y, item)
      #draw_item_name(item, rect.x, rect.y, enable?(item), width / col_max - 56)
    else
      rect = item_rect(index)
      rect.width -= 4
      draw_nil_name(rect.x, rect.y, enable?(item))
    end
  end
  #--------------------------------------------------------------------------
  # ● シンプルなステータスの描画
  #--------------------------------------------------------------------------
  def draw_summon_actor_simple_status(actor, x, y, item, cut = 3)
    draw_actor_face_cut(actor, x + 96, y + cut, cut, enable?(item))
    draw_actor_name(actor, x, y)
    draw_actor_class(actor, x, y + line_height * 1)
    draw_actor_level(actor, x, y + line_height * 2)
    draw_actor_hp(actor, x + 200, y + line_height * 1)
    draw_actor_mp(actor, x + 200, y + line_height * 2)
    draw_actor_tp(actor, x + 200, y + line_height * 3)
  end
  #--------------------------------------------------------------------------
  # ○ アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::Skill)
    return false if $game_party.summon_members.include?(item.summon_unit_id)
    return item.stype_id == SummonSystem::S_S_ID
  end
  #--------------------------------------------------------------------------
  # ○ アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_actors[1].skills.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    #return true
    return summon_actor(item) ? !$game_party.members.include?(summon_actor(item)) : true
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  #def status_window=(status_window)
    #@status_window = status_window
    #call_update_help
  #end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def actor
    if item
      actor = SummonSystem::summon_obj(item.id)
      actor.summon_level_set($game_actors[1].level) if actor.level != $game_actors[1].level
      return actor
    else
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def summon_actor(item)
    if item
      actor = SummonSystem::summon_obj(item.id)
      actor.summon_level_set($game_actors[1].level) if actor.level != $game_actors[1].level
      return actor
    else
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    #@help_window.clear
    @help_window.set_item(summon_actor(item))    if @help_window
  end
  #--------------------------------------------------------------------------
  # ○ Xボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_x
    if ex_current_item_enabled?
      Sound.play_cursor
      Input.update
      deactivate
      call_x_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ○ Yボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_y
    if ex_current_item_enabled?
      Sound.play_cursor
      Input.update
      deactivate
      call_y_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ○ 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def ex_current_item_enabled?
    item
  end
  #--------------------------------------------------------------------------
  # ○ Zのハンドリング処理の追加
  #--------------------------------------------------------------------------
  def process_handling
    super
    return unless open? && active
    return process_z if z_enabled? && Input.trigger?(:Z)
  end
  #--------------------------------------------------------------------------
  # ○ 次のサーヴァント
  #--------------------------------------------------------------------------
  def next_actor
    self.index += 1
    if index > item_max - 2
      select(0)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 前のサーヴァント
  #--------------------------------------------------------------------------
  def prev_actor
    self.index -= 1
    if index < 0
      select(item_max - 2)
    end
  end
end

#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　スキルやアイテムの説明、アクターのステータスなどを表示するウィンドウです。
#==============================================================================

class Window_Help < Window_Base
  def set_summon_text(item)
    #set_text(item ? item.description : "戦闘開始時に召喚するサーヴァントを選択して下さい。\n※\e}キーボードAでスキルの確認、Sで#{Vocab::rune}のセット、Dでステータス表示\e{")
    set_text("戦闘開始時に召喚するサーヴァントをスロットにセットして下さい。\n\e}※\ekb[a]でスキルの確認、\ekb[s]で#{Vocab::rune}のセット、\ekb[d]でステータス表示\e{")
  end
end

#==============================================================================
# □ Window_SummonEquipSlot
#------------------------------------------------------------------------------
# 　サーヴァントが現在装備しているルーンを表示するウィンドウです。
#==============================================================================

class Window_SummonEquipSlot < Window_EquipSlot
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super
    hide
  end
  #--------------------------------------------------------------------------
  # 〇 装備用アクター
  #--------------------------------------------------------------------------
  def equip_actor
    @actor
  end
  #--------------------------------------------------------------------------
  # 〇 カーソルの更新　※オーバーライド
  #--------------------------------------------------------------------------
  def update_cursor
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index + 1))
    end
  end
  #--------------------------------------------------------------------------
  # 〇　リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    change_color(normal_color)
    draw_text(item_rect_for_text(0), @actor.name) if @actor
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    return unless @actor
    rect = item_rect_for_text(index + 1)
    change_color(system_color, enable?(index))
    draw_text(rect.x, rect.y, 92, line_height, slot_name(index))
    draw_item_name(@actor.equips[index], rect.x + 68, rect.y, enable?(index), 164)
  end
  #--------------------------------------------------------------------------
  # ● 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    @actor ? @actor.equip_slots.select{|type| type == 4}.size : 0
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットの名前を取得
  #--------------------------------------------------------------------------
  def slot_name(index)
    Vocab::rune
    #@actor ? Vocab::etype(@actor.equip_slots[index]) : ""
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(index)
    @actor ? true : false
  end
end

#==============================================================================
# □ Window_Talisman
#------------------------------------------------------------------------------
# 　装備画面で、装備変更の候補となるルーンの一覧を表示するウィンドウです。
#==============================================================================

class Window_Talisman < Window_EquipItem
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    @actor ? show : hide
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return false unless @actor
    super
  end
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    return true if item.is_a?(NilClass)
    return true if rune_change_ok?(item)
    !@actor.rune_type_equip?(item)
  end
  #--------------------------------------------------------------------------
  # ○ 選択スロットと交換可能か ★
  #--------------------------------------------------------------------------
  def rune_change_ok?(item)
    list = @actor.equip_rune_type_all - @actor.equip_rune_type[@slot_id]
    return !item.rune_type.any? {|rt| list.include?(rt)}
  end
end

#==============================================================================
# ■ Window_SummonName
#------------------------------------------------------------------------------
# 　召喚スロットの名前描写専用ウィンドウです
#==============================================================================

class Window_SummonName < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(wx, wy, ww, wh)
    super(wx, wy, ww, wh)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def draw_name(x, y)
    change_color(system_color)
    draw_text(x, y, contents_width, line_height, "召喚スロット")
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_name(0, 0)
  end
end


#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○同タイプのルーンを装備しているか？★
  #--------------------------------------------------------------------------
  def rune_type_equip?(rune)
    return false unless rune
    all = equip_rune_type_all
    type = rune.rune_type
    val = false
    type.each do |rt|
      val = all.include?(rt)
      return val if val
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ○装備ルーンタイプの配列★
  #--------------------------------------------------------------------------
  def equip_rune_type
    rt = []
    rune = equip_slots.select{|type| type == 4}
    rune.size.times do |i|
      ob = @equips[i].object
      rt[i] = ob ? ob.rune_type : []
    end
    return rt
  end
  #--------------------------------------------------------------------------
  # ○装備ルーンタイプの全配列★
  #--------------------------------------------------------------------------
  def equip_rune_type_all
    equip_rune_type.inject([]) {|r, type| r += type }
  end
end

class RPG::EquipItem < RPG::BaseItem
  def rune_type
    @rune_type ||= rune_type_set
  end
  def rune_type_set
    type = []
    self.note.each_line do |line|
      case line
      when /\<ルーンタイプ:(\D+?)\>/
        type.push($1)
      end
    end
    return type
  end
end

