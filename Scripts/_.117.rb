#==============================================================================
# □ Window_QuestList
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_QuestList_Report < Window_QuestList_Check
  #--------------------------------------------------------------------------
  # ○ クエストを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable_select(item)
    quest_clear?(item)
  end
end

#==============================================================================
# □ Window_YesNoChoice
#------------------------------------------------------------------------------
# 　"はい"か"いいえ"を選択するウィンドウです。
#==============================================================================

class Window_ReportChoice < Window_OrderChoice
  #--------------------------------------------------------------------------
  # ○ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Report this Quest",     :yes_select)
    add_command("Cancel",   :no_select)
  end
end

#==============================================================================
# □ Window_Reword
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_Reword < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    flag_init
    super(0, 0, Graphics.width, Graphics.height)#window_width, fitting_height(3))
    #self.x = Graphics.width / 2 - self.width / 2
    #self.y = Graphics.height / 2 - self.height / 2
    self.z = 300
    self.back_opacity = 255
    self.visible = false
    self.arrows_visible = false
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_reword(@text, 0, 0)
    flag_init
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def flag_init
    @item = {}
    @text = []
    @size = [0]
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の設定
  #--------------------------------------------------------------------------
  def window_width
    [@size.max * 24 + 24 + 24, 6 * 24 + 24 + 24].max
  end
  #--------------------------------------------------------------------------
  # ○ 報酬テキストの設定
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    item_set(@item)
    self.width = window_width
    self.height = fitting_height(2 + @text.size)
    self.x = Graphics.width / 2 - self.width / 2
    self.y = Graphics.height / 2 - self.height / 2
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def item_set(item)
    item.each do |k, v|
      @text.push([$data_items[k.to_i].name, $data_items[k.to_i].icon_index, v, k]) if k.include?("i")
      @text.push([$data_weapons[k.to_i].name, $data_weapons[k.to_i].icon_index, v, k]) if k.include?("w")
      @text.push([$data_armors[k.to_i].name, $data_armors[k.to_i].icon_index, v, k]) if k.include?("a")
      @text.push([v, k]) if k.include?("g")
    end
    @text.each do |i|
      @size.push(i[0].size) if i[0].is_a?(String)
      @size.push(i[0].to_s.size / 2) if i[0].is_a?(Integer)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 報酬の描画
  #--------------------------------------------------------------------------
  def draw_reword(text, x, y)
    change_color(system_color)
    draw_text(x + 4, y, contents_width, line_height, "Reward")
    change_color(normal_color)
    i = 1
    text.each do |ary|
      if ary.include?("g")
        s = ary[0].to_s.size
        draw_text(x + 4, y + 24 * i, contents_width, line_height, ary[0])
        draw_text_ex(x + 4 + s * 10, y + 24 * i, "\eg")
      else
        draw_icon(ary[1], x, y + 24 * i)
        draw_text(x + 24, y + 24 * i, contents_width, line_height, "#{ary[0]}×#{ary[2]}")
      end
      i += 1
    end
    draw_text(x + 4, y + 24 * i, contents_width, line_height, "Received")
  end
  #--------------------------------------------------------------------------
  # ○ カーソルの更新
  #--------------------------------------------------------------------------
  def update_cursor
    cursor_rect.empty
  end
end

#==============================================================================
# □ Scene_Quest
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_QuestReport < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_detail_window
    create_item_window
    create_choice_window
    create_reword_window
  end
  #--------------------------------------------------------------------------
  # ● 現在選択されているアイテムの取得
  #--------------------------------------------------------------------------
  def item
    @item_window.item
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.viewport = @viewport
    @help_window.set_text("Please select the quest you wish to report")
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_choice_window
    @choice_window = Window_ReportChoice.new
    @choice_window.viewport = @viewport
    @choice_window.set_handler(:yes_select, method(:report_ok))
    @choice_window.set_handler(:no_select,  method(:report_cancel))
    @choice_window.set_handler(:cancel,     method(:report_cancel))
  end
  #--------------------------------------------------------------------------
  # ○ 詳細ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_detail_window
    @detail_window = Window_QuestDetail.new
    @detail_window.y = @help_window.height
    @detail_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ○ アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    wh = @detail_window.height
    @item_window = Window_QuestList_Report.new(wh)
    @item_window.y = @detail_window.y
    @item_window.detail_window = @detail_window
    @item_window.viewport = @viewport
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:return_scene))
    @detail_window.set_item(@item_window.item)
  end
  #--------------------------------------------------------------------------
  # ○ 報酬ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_reword_window
    @reword_window = Window_Reword.new
    @reword_window.set_handler(:ok,     method(:return_report))
    @reword_window.set_handler(:cancel, method(:return_report))
  end
  #--------------------------------------------------------------------------
  # ● アイテム［決定］
  #--------------------------------------------------------------------------
  def on_item_ok
    @choice_window.show.activate
    @choice_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ 報告［決定］
  #--------------------------------------------------------------------------
  def report_ok
    play_se
    $game_variables[item[1]] = 6
    $game_party.reword_item(item[10])
    kill_end(item) if kill_quest?(item)
    deliver_end(item) if deliver_quest?(item)
    @choice_window.hide
    @reword_window.item = item[10]
    @reword_window.show.activate
    $game_system.quest_record(item[1])
    #@item_window.refresh
    #@detail_window.refresh
    #@item_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ 報告［キャンセル］
  #--------------------------------------------------------------------------
  def report_cancel
    Sound.play_cancel
    @choice_window.hide
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ 報告を終わる
  #--------------------------------------------------------------------------
  def return_report
    Sound.play_cancel
    @reword_window.hide.deactivate
    @item_window.refresh
    @detail_window.refresh
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ SE 演奏
  #--------------------------------------------------------------------------
  def play_se
    Audio.se_play(*Quest::CLEAR_SE)
  end
  #--------------------------------------------------------------------------
  # ○ 討伐クエストか？
  #--------------------------------------------------------------------------
  def kill_quest?(item)
    item[2] == "Extermination"
  end
  #--------------------------------------------------------------------------
  # ○ 討伐数の消去
  #--------------------------------------------------------------------------
  def kill_end(item)
    item[9].each_key{|k| $game_party.kill_end(k)}
  end
  #--------------------------------------------------------------------------
  # ○ 納品クエストか？
  #--------------------------------------------------------------------------
  def deliver_quest?(item)
    item[2] == "Delivery"
  end
  #--------------------------------------------------------------------------
  # ○ 納品アイテムの減少
  #--------------------------------------------------------------------------
  def deliver_end(item)
    item[9].each{|k, v| $game_party.lose_item($game_party.quest_item(k, k.to_i), v)}
  end
end

#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ○ クエスト報酬の受け取り
  #--------------------------------------------------------------------------
  def reword_item(item)
    item.each do |k, v|
      gain_item($data_items[k.to_i], v) if k.include?("i")
      gain_item($data_weapons[k.to_i], v) if k.include?("w")
      gain_item($data_armors[k.to_i], v) if k.include?("a")
      gain_gold(v) if k.include?("g")
    end
=begin
    item.each do |ary|
      case ary[0]
      when "i" ; gain_item($data_items[ary[1]], 1)
      when "w" ; gain_item($data_weapons[ary[1]], 1)
      when "a" ; gain_item($data_armors[ary[1]], 1)
      else     ; gain_gold(ary[1])
      end
    end
=end
  end
end


#################################################################

#==============================================================================
# □ Window_Reword
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_RewordSkill < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    flag_init
    super(0, 0, Graphics.width, fitting_height(3))#window_width, fitting_height(3))
    self.z = 300
    self.back_opacity = 255
    self.visible = false
    self.arrows_visible = false
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_reword_skill(@text, 0, 0)
    show unless @text.empty?
    flag_init
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def flag_init
    @item = {}
    @text = []
  end
  #--------------------------------------------------------------------------
  # ○ 報酬テキストの設定
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    item_set(@item)
    self.height = fitting_height(3 * @text.size)
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def adjust(wy)
    self.y = wy
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def item_set(item)
    item.each do |k, v|
      if k.include?("i")
        @text.push([$data_items[k.to_i].name, $data_items[k.to_i].icon_index, v, k]) if $data_items[k.to_i].skill_book?
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ 報酬の描画
  #--------------------------------------------------------------------------
  def draw_reword_skill(text, x, y)
    i = 0
    text.each do |ary|
      change_color(system_color)
      draw_icon(ary[1], x, y + 24 * i)
      draw_text(x + 24, y + 24 * i, contents_width, line_height, ary[0])
      change_color(normal_color)
      desc = convert_escape_characters(item_description_in_text("i", ary[3].to_i, false))
      draw_text_ex(x, y + 24 * (i + 1), desc)
      i += 3
    end
  end
  #--------------------------------------------------------------------------
  # ○ カーソルの更新
  #--------------------------------------------------------------------------
  #def update_cursor
    #cursor_rect.empty
  #end
end

#==============================================================================
# □ Scene_Quest
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_QuestReport < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  alias rs_start start
  def start
    rs_start
    create_skill_window
  end
  #--------------------------------------------------------------------------
  # ○ 報酬ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_skill_window
    @skill_window = Window_RewordSkill.new
  end
  #--------------------------------------------------------------------------
  # ○ 報告［決定］
  #--------------------------------------------------------------------------
  alias skill_report_ok report_ok
  def report_ok
    skill_report_ok
=begin
    play_se
    $game_variables[item[1]] = 6
    $game_party.reword_item(item[10])
    kill_end(item) if kill_quest?(item)
    deliver_end(item) if deliver_quest?(item)
    @choice_window.hide
    @reword_window.item = item[10]
    @reword_window.show.activate
=end
    @skill_window.adjust(@reword_window.y + @reword_window.height)
    @skill_window.item = item[10]
    #@item_window.refresh
    #@detail_window.refresh
    #@item_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ 報告を終わる
  #--------------------------------------------------------------------------
  alias skill_return_report return_report
  def return_report
    skill_return_report
    @skill_window.hide
  end
end