module QuestConfig
  LU_H = 122
  SO_H = 576
  MA_H = 576
  HA_H = 577
  EX_H = 576
  #--------------------------------------------------------------------------
  # ○ 表示条件
  #--------------------------------------------------------------------------
  def conditions_met?(h)
    return true unless h
    return true if !h.has_key?("s") && !h.has_key?("v")
    conditions_s(h["s"]) && conditions_v(h["v"])
  end
  #--------------------------------------------------------------------------
  # ○ 表示条件スイッチ
  #--------------------------------------------------------------------------
  def conditions_s(s)
    return true unless s
    s.all? {|id| $game_switches[id] }
  end
  #--------------------------------------------------------------------------
  # ○ 表示条件変数
  #--------------------------------------------------------------------------
  def conditions_v(v)
    return true unless v
    v.all? {|ary| variables(ary) }
  end
  #--------------------------------------------------------------------------
  # ○ 変数の判定
  #--------------------------------------------------------------------------
  def variables(ary)
    case ary[2]
    when -1
      $game_variables[ary[0]] < ary[1]
    when 0
      $game_variables[ary[0]] == ary[1]
    when 1
      $game_variables[ary[0]] > ary[1]
    else
      $game_variables[ary[0]] >= ary[1]
    end
  end
  #--------------------------------------------------------------------------
  # ○ Hイベントの有無
  #--------------------------------------------------------------------------
  def h_event?(h)
    return false unless h
    return h.has_key?("h")
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def heart(num)
    case num
    when 1 ; id = LU_H
    when 2 ; id = SO_H
    when 3 ; id = MA_H
    when 4 ; id = HA_H
    else   ; id = EX_H
    end
    return "\ei[#{id}]"
  end
  #--------------------------------------------------------------------------
  # ○ 期限の有無
  #--------------------------------------------------------------------------
  def limit?(h)
    return false unless h
    return h.has_key?("l")
  end
end

#==============================================================================
# ■ Window_QuestCategory
#------------------------------------------------------------------------------
#　
#　
#==============================================================================

class Window_QuestCategory < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :item_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @item_window.category = current_symbol if @item_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Story",     :main)
    add_command("Side Quest",   :sub)
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def item_window=(item_window)
    @item_window = item_window
    update
  end
end

#==============================================================================
# □ Window_QuestList
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_QuestList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :detail_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(height)
    super(0, 0, window_width, height)
    @category = :none
    @data = []
  end
  #--------------------------------------------------------------------------
  # ● カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
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
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def window_width
    160
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● アイテムの取得
  #--------------------------------------------------------------------------
  def item
    return @data && index >= 0 ? $game_temp.story[@data[index]] : nil if @category == :main
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # ○ クエストを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    return true if @category == :main
    enable_quest(item[1], item[11])
  end
  #--------------------------------------------------------------------------
  # ○ サブクエストの許可状態判定 v = 変数
  #--------------------------------------------------------------------------
  def enable_quest(v, c)
    $game_variables[v] >= 1
  end
  #--------------------------------------------------------------------------
  # ○ アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    case @category
    when :main
      @data = $game_party.main_story
    when :sub
      @data = $game_temp.sub_quest
      @data += $game_temp.true_quest if $game_system.true_route?
      @data.sort! {|a, b| a[0] - b[0]}
    else
      @data.push(nil)
    end
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      #rect.width -= 4
      progress_color(item)
      draw_text(-8, rect.y, 152, line_height, "Quest No.#{format("%02d",item[0])}", 1) if @category == :sub
      #draw_text(-8, rect.y, 152, line_height, "#{format("%02d",index + 1)}-" + $game_temp.story[item][0], 1) if @category == :main
      draw_text(-8, rect.y, 152, line_height, $game_temp.story[item][0], 1) if @category == :main
    end
  end
  #--------------------------------------------------------------------------
  # ○ 条件達成してるか？
  #--------------------------------------------------------------------------
  def quest_clear?(item)
    item && ($game_variables[item[1]] == 5 || ($game_variables[item[1]] == 3 && clear_conditions(item)))
  end
  #--------------------------------------------------------------------------
  # ○ 期限切れか？
  #--------------------------------------------------------------------------
  def limit_over?(item)
    if limit?(item[11]) && $game_variables[item[1]] > 0 && $game_variables[item[1]] < 6
      return false if $game_variables[21] < item[11]["l"][1]
      return true
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ○ 期限の有無
  #--------------------------------------------------------------------------
  def limit?(h)
    return false unless h
    return h.has_key?("l")
  end
  #--------------------------------------------------------------------------
  # ○ 達成条件
  #--------------------------------------------------------------------------
  def clear_conditions(item)
    if item[2] == "Suppression"
      key = item[9].keys
      key.all?{|id| $game_party.kill_list(id) == 0 }
    elsif item[2] == "Delivery"
      key = item[9].keys
      key.all?{|c| quest_item_number?(c, item[9][c])}
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def quest_item_number?(c, num)
    return $game_party.item_number($data_items[c.to_i]) >= num if c.include?("i")
    return $game_party.item_number($data_weapons[c.to_i]) >= num if c.include?("w")
    return $game_party.item_number($data_armors[c.to_i]) >= num if c.include?("a")
  end
  #--------------------------------------------------------------------------
  # ○ クエスト進捗カラー
  #--------------------------------------------------------------------------
  def progress_color(item)
    return change_color(normal_color, enable?(item)) if @category == :main
    return change_color(power_up_color) if quest_clear?(item) #達成
    return change_color(knockout_color) if limit_over?(item) #期限切れ
    case $game_variables[item[1]]
    when 0..2; change_color(normal_color, enable?(item)) #受注前
    when 3..4; change_color(crisis_color) #受注中
    #when 5   ; change_color(power_up_color) #達成
    else     ; change_color(system_color) #クリア
    end
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウ更新メソッドの呼び出し
  #--------------------------------------------------------------------------
  def call_update_help
    update_help if active && @detail_window
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @detail_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def detail_window=(detail_window)
    @detail_window = detail_window
    update
  end
end


#==============================================================================
# ■ Window_QuestDetail
#------------------------------------------------------------------------------
#　
#==============================================================================

class Window_QuestDetail < Window_Base
  include QuestConfig
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(line_number = 17)
    super(Graphics.width - window_width, 0, window_width, fitting_height(line_number))
    @item = []
  end
  #--------------------------------------------------------------------------
  # ● クリア
  #--------------------------------------------------------------------------
  def clear
    contents.clear
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def window_width
    480
  end
  #--------------------------------------------------------------------------
  # ○ サブクエストの許可状態判定 v = 変数
  #--------------------------------------------------------------------------
  #def enable_quest(v)
    #$game_variables[v] >= 1
  #end
=begin
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def conditions_met?(h)
    return true unless h
    conditions_s(h["s"]) && conditions_v(h["v"])
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def conditions_s(s)
    return true unless s
    s.all? {|id| $game_switches[id] }
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def conditions_v(v)
    return true unless v
    v.all? {|ary| variables(ary) }
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def variables(ary)
    case ary[2]
    when -1
      $game_variables[ary[0]] < ary[1]
    when 0
      $game_variables[ary[0]] == ary[1]
    when 1
      $game_variables[ary[0]] > ary[1]
    else
      $game_variables[ary[0]] >= ary[1]
    end
  end
=end
  #--------------------------------------------------------------------------
  # ● アイテム設定
  #     item : スキル、アイテム等
  #--------------------------------------------------------------------------
  def set_item(item)
    if item != @item
      @item = item
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def draw_quest(item)
    return unless item 
    if item[0].is_a?(Numeric)
      half = line_height / 2
      #サブクエスト処理
      change_color(system_color)
      draw_text(16, line_height * 2 + half, window_width, line_height, "Quest")
      draw_text(16, line_height * 5, window_width, line_height, "Client:")
      draw_text(16, line_height * 6 + half, window_width, line_height, "Reward:")
      draw_text(16, line_height * 9, window_width, line_height, "Details")
      pr = progress(item)
      title  = pr < 2 ? item[7].gsub(/./) {"？"} : item[7]
      lv     = pr < 1 ? "？？" : item[6]
      place  = pr < 1 ? item[3].gsub(/./) {"？"} : item[3]
      name   = pr < 2 ? "？？？？" : item[4] 
      reword = pr < 2 ? "？？？？" : item[5]
      if pr == 0
        detail = "？？？？？？？？？？？？"
      elsif !conditions_met?(item[11])
        detail = item[11]["t"]
      else
        detail = pr < 2 ? "？？？？？？？？？？？？" : item[8]
      end
      #クエスト名
      change_color(hp_gauge_color2)
      draw_text(4, line_height * 0, window_width, line_height, title)
      change_color(normal_color)
      #依頼種別
      draw_text(16, line_height * 1, window_width, line_height, "Quest: #{item[2]}")
      #推奨Lv
      draw_text(180, line_height * 1, window_width, line_height, "Advised LV:#{lv}")
      l_text = ""
      if pr > 0
        #期限の有無
        if limit?(item[11]) && pr < 4
          if $game_variables[21] < item[11]["l"][0]
            l_text = "Deadline"
          elsif $game_variables[21] < item[11]["l"][1]
            change_color(crisis_color)
            l_text = "Deadline"
          else
            change_color(knockout_color)
            l_text = "Expired"
          end
          draw_text(320, line_height * 0, window_width, line_height, l_text)
        end
        #Hイベントの有無
        draw_text_ex(416, line_height * 0, heart(item[11]["h"])) if h_event?(item[11])
      end
      change_color(normal_color)
      #受注状況
      text = ""
      unless l_text == "Expired"
        case pr
        when 1..2; text = "Available"
        when 3; text = "In Progress"
        when 4; text = "Cleared"
        end
      end
      draw_text(320, line_height * 1, window_width, line_height, text)
      #場所
      draw_text(28, line_height * 3 + half, window_width, line_height, place)
      #依頼人
      draw_text_ex(84, line_height * 5, name)#(28, line_height * 5 + line_height / 2, name)#
      #報酬
      draw_text_ex(66, line_height * 6 + half, reword)
      #詳細
      draw_text_ex(28, line_height * 10, detail) unless l_text == "Expired"
    elsif item[0].is_a?(String)
      #メインストーリー処理
      change_color(system_color)
      draw_text(4, 0, window_width, line_height, chapter(item[1]))
      change_color(normal_color)
      draw_text_ex(28, line_height * 2, item[2])
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # 〇 通常文字の処理　
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    text_width = text_size(c).width
    th = text_size(c).height
    ty = 24 > th ? 24 - th - 2 : 0
    draw_text(pos[:x], pos[:y] + ty, text_width * 2, pos[:height], c)
    pos[:x] += text_width
  end
  #--------------------------------------------------------------------------
  # ○ サブクエスト進捗
  #--------------------------------------------------------------------------
  def progress(item)
    case $game_variables[item[1]]
    when 0;    0 #受注不可
    when 1;    1 #受注可能
    when 2;    2 #受注可能(内容判明)
    when 3..5; 3 #受注中
    else     ; 4 #クリア
    end
  end
  #--------------------------------------------------------------------------
  # ○ 章名変換
  #--------------------------------------------------------------------------
  def chapter(str)
    $game_system.chapter_name(str.to_i)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_quest(@item)
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
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :main_story                 # ストーリー配列
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias quest_initialize initialize
  def initialize
    quest_initialize
    init_quest
  end
  #--------------------------------------------------------------------------
  # ○ クエストリストの初期化
  #--------------------------------------------------------------------------
  def init_quest
    @main_story = []
  end
  #--------------------------------------------------------------------------
  # ○ メインストーリーの追加
  #--------------------------------------------------------------------------
  def story_add(key)
    @main_story.push(key)
  end
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ○ メインストーリーの追加
  #--------------------------------------------------------------------------
  def story_add(key)
    $game_party.story_add(key)
  end
  #--------------------------------------------------------------------------
  # ○ クエスト受注　町民用
  #--------------------------------------------------------------------------
  def quest_on(n)
    $game_variables[Quest.variables(n)] = 3
    Quest.q_start(n)
  end
  #--------------------------------------------------------------------------
  # ○ クエストクリア　町民用
  #--------------------------------------------------------------------------
  def quest_clear(n)
    $game_variables[Quest.variables(n)] = 6
    $game_party.reword_item(Quest.reword(n))
    $game_system.quest_record(Quest.variables(n))
    Quest.q_end(n)
  end
  #--------------------------------------------------------------------------
  # ○ クエストリスト作成　※ n は 1 から
  #--------------------------------------------------------------------------
  def quest_set(n)
    $game_temp.quest_select_set(n)
  end
  #--------------------------------------------------------------------------
  # ○ クエストリスト作成 トゥルー用　※ n は 101 ではなく 1 から
  #--------------------------------------------------------------------------
  def quest_true_set(n)
    $game_temp.quest_select_true_set(n)
  end
  #--------------------------------------------------------------------------
  # ○ クエスト受注可能化
  #--------------------------------------------------------------------------
  def quest_pre_on(n)
    return n.each{|i| $game_variables[Quest.variables(i)] = 1 if $game_variables[Quest.variables(i)] < 1 } if n.is_a?(Range)
    $game_variables[Quest.variables(n)] = 1 if $game_variables[Quest.variables(n)] < 1
  end
  #--------------------------------------------------------------------------
  # ○ クエスト周回リセット
  #--------------------------------------------------------------------------
  def quest_loop_reset
    $game_temp.sub_quest.each_with_index do |q, i|
      $game_variables[q[1]] = 0 if !Quest::NO_RESET.include?(i + 1)
    end
    $game_temp.true_quest.each_with_index do |q, i|
      $game_variables[q[1]] = 0 if !Quest::NO_RESET_TRUE.include?(i + 1)
    end
  end
end

#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :quest_select          # 
  attr_reader   :quest_select_true          # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias quest_initialize initialize
  def initialize
    quest_initialize
    quest_reset
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  #def quest_copy(quest)
    #tmp = Marshal.dump(quest)
    #Marshal.load(tmp)
  #end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def story
    @story ||= FAKEREAL.deep_copy(Quest::MAIN)#quest_copy(Quest::MAIN)#Quest::MAIN.dup
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def sub_quest
    @sub_quest ||= FAKEREAL.deep_copy(Quest::SUB)#.dup
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def true_quest
    @true_quest ||= FAKEREAL.deep_copy(Quest::SUB_TRUE)#.dup
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def quest_select_set(num)
    return num.each{|i| @quest_select.push(i - 1) } if num.is_a?(Range)
    @quest_select.push(num - 1)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def quest_select_true_set(num)
    return num.each{|i| @quest_select_true.push(i - 1) } if num.is_a?(Range)
    @quest_select_true.push(num - 1)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def quest_reset
    @quest_select = []
    @quest_select_true = []
  end
end

#==============================================================================
# □ Window_QuestList
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_QuestList_Check < Window_QuestList
  include QuestConfig
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(height)
    super(height)
    @category = :sub
    refresh
    select(0)
    activate
  end
  #--------------------------------------------------------------------------
  # ○ アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    $game_temp.quest_select.each {|num|
      quest = $game_temp.sub_quest[num]
      @data.push(quest) if $game_variables[quest[1]] >= 1
      $game_variables[quest[1]] += 1 if $game_variables[quest[1]] == 1 && conditions_met?(quest[11])
    }
    $game_temp.quest_select_true.each {|num|
      t_quest = $game_temp.true_quest[num]
      @data.push(t_quest) if $game_variables[t_quest[1]] >= 1
      $game_variables[t_quest[1]] += 1 if $game_variables[t_quest[1]] == 1 && conditions_met?(t_quest[11])
    }
    @data.sort! {|a, b| a[0] - b[0] }
    #$game_temp.quest_select.each {|num| @data.push($game_temp.sub_quest[num]) }
    #$game_temp.quest_select_true.each {|num| @data.push($game_temp.true_quest[num])}
    $game_temp.quest_reset
    #@data = [$game_temp.sub_quest[$game_variables[11] - 1]]
  end
  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable_select(@data[index])
  end
  #--------------------------------------------------------------------------
  # ○ クエストを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable_select(item)
    item && $game_variables[item[1]] == 2 && conditions_met?(item[11]) && !limit_over?(item)
  end
=begin
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def conditions_met?(h)
    return true unless h
    conditions_s(h["s"]) && conditions_v(h["v"])
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def conditions_s(s)
    return true unless s
    s.all? {|id| $game_switches[id] }
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def conditions_v(v)
    return true unless v
    v.all? {|ary| variables(ary) }
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def variables(ary)
    case ary[2]
    when -1
      $game_variables[ary[0]] < ary[1]
    when 0
      $game_variables[ary[0]] == ary[1]
    when 1
      $game_variables[ary[0]] > ary[1]
    else
      $game_variables[ary[0]] >= ary[1]
    end
  end
=end
end

#==============================================================================
# □ Window_YesNoChoice
#------------------------------------------------------------------------------
# 　"はい"か"いいえ"を選択するウィンドウです。
#==============================================================================

class Window_OrderChoice < Window_Command
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    self.x = Graphics.width / 2 - self.width / 2
    self.y = Graphics.height / 2 - self.height / 2
    self.visible = false
    self.z = 300
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 240
  end
  #--------------------------------------------------------------------------
  # ○ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Accept Quest",     :yes_select)
    add_command("Cancel",   :no_select)
  end
  #--------------------------------------------------------------------------
  # ○ 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    Input.update
    deactivate
    call_ok_handler
  end
  #--------------------------------------------------------------------------
  # ○ キャンセルボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_cancel
    Input.update
    deactivate
    call_cancel_handler
  end
end

#==============================================================================
# □ Scene_Quest
#------------------------------------------------------------------------------
# 　クエスト選択画面の処理を行うクラスです。
#==============================================================================

class Scene_QuestSelect < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_detail_window
    create_item_window
    create_choice_window
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
    @help_window.set_text("Please select a quest.")
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_choice_window
    @choice_window = Window_OrderChoice.new
    @choice_window.viewport = @viewport
    @choice_window.set_handler(:yes_select, method(:order_ok))
    @choice_window.set_handler(:no_select,  method(:order_cancel))
    @choice_window.set_handler(:cancel,     method(:order_cancel))
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
    @item_window = Window_QuestList_Check.new(wh)
    @item_window.y = @detail_window.y
    @item_window.detail_window = @detail_window
    @item_window.viewport = @viewport
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:return_scene))
    @detail_window.set_item(@item_window.item)
  end
  #--------------------------------------------------------------------------
  # ● アイテム［決定］
  #--------------------------------------------------------------------------
  def on_item_ok
    @choice_window.show.activate
    @choice_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ○ オーダー［決定］
  #--------------------------------------------------------------------------
  def order_ok
    play_se
    $game_variables[item[1]] = 3
    kill_set(item) if kill_quest?(item)
    @choice_window.hide
    @item_window.refresh
    @detail_window.refresh
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ オーダー［キャンセル］
  #--------------------------------------------------------------------------
  def order_cancel
    Sound.play_cancel
    @choice_window.hide
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ○ SE 演奏
  #--------------------------------------------------------------------------
  def play_se
    Audio.se_play(*Quest::SE)
  end
  #--------------------------------------------------------------------------
  # ○ 討伐クエストか？
  #--------------------------------------------------------------------------
  def kill_quest?(item)
    item[2] == "討伐"
  end
  #--------------------------------------------------------------------------
  # ○ 討伐数のセット
  #--------------------------------------------------------------------------
  def kill_set(item)
    #item[9].each{|k, v| $game_party.kill_list_set(k, v)}
    $game_party.kill_list_fullset(item[9])
  end
end
