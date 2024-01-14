#----------------------------------------------------------------------------
# オプション項目候補
#　・オートスピード速度　・難易度　・登録済みHシーン
#　・音量変更
#　・スキルレベル表記
#　・ダッシュ速度変更
#　・習得済スキルの表示
#
#----------------------------------------------------------------------------

module Option
    Command = [
               Hash[
                    "Difficulty"               => [:difficulty, false],
                    "Dash Button"              => [:dash, false],
                    "Display Skill Level"      => [:skill_lv, false],
                    "Display Learned Skills"   => [:learned, false],
                    "Normal Attack Magic Strike" => [:magic_punch, false],
                    "Simple Item Start Option" => [:item_start, false],
                    "Quick Heal Priority"      => [:quick_heal, false],
                    "Initial Screen Size"      => [:zoom, true],
                    "Volume Adjustment"        => [:volume, true],
    ],
    
               Hash[
                    "Control Button Notation"  => [:button, true],
                    "Registered H-Scenes"      => [:h_event, true],
                    "Auto Speed"               => [:auto_speed, true],
                    "Event Text Skip"          => [:message_skip, true], # Added read confirmation
                    "H-Scene Window Transparency" => [:opacity, true],
                    "Special H-Scenes"         => [:exh_event, true],
                    "Cross-Sectional View Display" => [:dmz, true],
                    "Ejaculation Count"        => [:shot_count, true],
    ]
  
  ]
  H_Opacity  = 39 # エッチイベント中のウィンドウ背景透過率変数
  Scene = 40 # エッチシーンスキップ登録変数

  Button = 35 # 操作表記変数

  Skip  = 89 # 全メッセージスキップ判定スイッチ
  PeopleSkip  = 90 # 町民会話スキップ判定スイッチ
  
  MagicPunch  = 30 # 通常攻撃魔力殴打化スイッチ

  ItemStart  = 37 # 簡易アイテム使用時の設定変数
  
  EASY_HEAL = 42 # クイックヒール回数緩和措置用変数

  EXH_B = 131 # 特殊エッチボテ変数
  EXH_S = 132 # 特殊エッチ出産変数
  EXH_F = 133 # 特殊エッチフタナリ変数
  EXH_SHOT = 134 # 射精カウント変数

  EXH_SWB = 311 # ボテ腹スイッチ
  EXH_SWS = 312 # 出産スイッチ
  EXH_SWF = 313 # フタナリスイッチ
  EXH_D = 314 # 断面図スイッチ
  
  WORD_S = "Spawn"
  
  ScreenZoom = 306 #開始時画面サイズ判定スイッチ

end



#==============================================================================
# □ Window_OptionCommand
#------------------------------------------------------------------------------
# 　オプション画面で、設定項目を選択するウィンドウです。
#==============================================================================

class Window_OptionCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :page_index                     # ページインデックス
  #--------------------------------------------------------------------------
  # 〇 オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    @page_index = 0
    super(x, y)
    select_last
    $game_temp.return_symbol_reset
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 240
  end
  #--------------------------------------------------------------------------
  # ● 標準パディングサイズの取得
  #--------------------------------------------------------------------------
  def standard_padding
    return 6
  end
  #--------------------------------------------------------------------------
  # 〇 高さの取得
  #--------------------------------------------------------------------------
  def line_height
    return 28
  end
  #--------------------------------------------------------------------------
  # 〇 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return Option::Command[@page_index].size
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    Option::Command[@page_index].each do |k, v|
      #add_command(k, v[0], v[1] ? true : !SceneManager.laststack_is?(Scene_Title), v[1])
      add_command(k, v[0], SceneManager.laststack_is?(Scene_Title) ? v[1] : true, v[1])
    end
  end
  #--------------------------------------------------------------------------
  # 〇 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    $game_temp.return_symbol ? select_symbol($game_temp.return_symbol) : select(0)
  end
  #--------------------------------------------------------------------------
  # 〇 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color((public_command?(index) ? power_up_color : system_color), command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # 〇 全データ共通か
  #--------------------------------------------------------------------------
  def public_command?(index)
    @list[index][:ext]
  end
  #--------------------------------------------------------------------------
  # 〇 アライメントの取得
  #--------------------------------------------------------------------------
  def alignment
    return 1
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def page_change
    @page_index += 1
    @page_index = 0 if @page_index > 1
    select(0)
    refresh
    #call_update_help
  end
  
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    Sound.play_cursor
    page_change
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    Sound.play_cursor
    page_change
  end
  
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの設定
  #--------------------------------------------------------------------------
  def info_window=(info_window)
    @info_window = info_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # 〇 ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_text("Select the item you wish to change. Use ← → to switch pages. The items marked with green text will be shared by all saved data.")
    @info_window.set_item(@page_index + 1) if @info_window
  end  
end

#==============================================================================
# □ Window_Option
#------------------------------------------------------------------------------
# 　オプション画面で、共通のウィンドウ設定です。
#==============================================================================

class Window_Option < Window_HorzCommand
  #--------------------------------------------------------------------------
  # 〇 オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    @window_width = width
    super(x, y)
    self.opacity = 0
    select_last
    deactivate
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # 〇 標準パディングサイズの取得
  #--------------------------------------------------------------------------
  def standard_padding
    return 2
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
  end
  #--------------------------------------------------------------------------
  # 〇 ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_text(help_text)
  end
end


#==============================================================================
# □ Window_Difficulty
#------------------------------------------------------------------------------
# 　オプション画面で、難易度を選択するウィンドウです。
#==============================================================================

class Window_Difficulty < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Easy",   :easy)
    add_command("Normal",   :normal)
    add_command("Hard",     :hard)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    select_symbol($game_system.difficulty)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    case current_symbol
    when :normal ; "Normal: No change to the enemy's strength. This is the normal difficulty."
    when :easy ; "Easy: The enemy's HP is reduced to 0.8 times, and other abilities to 0.9 times.\nAdditionally, some stronger enemies will act one less time, and their powerful moves will be sealed.\nFurthermore, damage from enemies is reduced by 20%,\nand the damage you deal is increased by 20%."
    when :hard ; "Hard: The enemy's HP is increased to 1.5 times, and other abilities to 1.2 times.\nIf normal is not satisfying enough for you, we recommend this mode."
    else ; ""
    end
  end
  #--------------------------------------------------------------------------
  # 〇 ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  #def update_help
    #super
    #@help_window.set_text(difficulty_text)
  #end
end

#==============================================================================
# □ Window_Dash
#------------------------------------------------------------------------------
# 　オプション画面で、シフトキー機能を選択するウィンドウです。
#==============================================================================

class Window_Dash < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Fast Dash",   :dash)
    add_command("Walk",   :walk)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    $game_switches[FAKEREAL::IDATEN] ? select(0) : select(1)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "#{key_button("SHIFT")} to dash or walk."
  end
end

#==============================================================================
# □ Window_SkillLevel
#------------------------------------------------------------------------------
# 　オプション画面で、スキルレベルの表示非表示を選択するウィンドウです。
#==============================================================================

class Window_SkillLevel < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Show",   :show)
    add_command("Hide", :hide)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    $game_system.skill_lv_visible ? select(0) : select(1)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "You can choose whether or not to display the skill level * on the skill screen"
  end
end

#==============================================================================
# □ Window_Learned
#------------------------------------------------------------------------------
# 　オプション画面で、習得済みスキルの表示非表示を選択するウィンドウです。
#==============================================================================

class Window_Learned < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Show",   :show)
    add_command("Hide", :hide)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    $game_switches[Learn::HIDE] ? select(1) : select(0)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "You can choose whether or not to display ɑn for skills that have already been learned or are at level MAX on the skill learning screen."
  end
end

#==============================================================================
# □ Window_MagicPunch
#------------------------------------------------------------------------------
# 　オプション画面で、通常攻撃を魔力殴打に変更するかを選択するウィンドウです。
#==============================================================================

class Window_MagicPunch < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Change",   :change)
    add_command("No Change", :no_change)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    $game_switches[Option::MagicPunch] ? select(0) : select(1)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "If you have learned the skill \edb[s,106], the normal attack will be changed to \edb[s,106]. If you do not meet the conditions for using the skill, the attack will be a normal attack"
  end
end

#==============================================================================
# □ Window_ItemStart
#------------------------------------------------------------------------------
# 　オプション画面で、簡易アイテム使用時の開始項目を設定。
#==============================================================================

class Window_ItemStart < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Potion-type", :ok)
    add_command("Bottle", :ok)
    add_command("Cooking", :ok)
    add_command("All", :ok)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    select($game_variables[Option::ItemStart])
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "You can change the start item when using a simple item. Simple items can be used by entering #{key_button("D")} on the \nmap screen."
  end
end

#==============================================================================
# □ Window_HealOption
#------------------------------------------------------------------------------
# 　オプション画面で、クイックヒール使用時の優先項目を設定。
#==============================================================================

class Window_HealOption < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("MP Consumption", :ok)
    add_command("Intermediate", :ok)
    add_command("Speed", :ok)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    select($game_variables[Option::EASY_HEAL])
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "You can change the priority items during a quick heal. \nIf you prioritize speed, you can use a skill with a large amount of recovery, or use a total recovery, etc., to finish the recovery as quickly as possible."
  end
end

#==============================================================================
# □ Window_KeyButton
#------------------------------------------------------------------------------
# 　オプション画面で、操作表記を選択するウィンドウです。
#==============================================================================

class Window_KeyButton < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Keyboard",   :keyboard)
    add_command("Gamepad (Alphabet)",   :pad_a)
    add_command("Gamepad (Numbers)",   :pad_b)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def select_last
    select($game_variables[Option::Button])
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def help_text
    return "You can change the control instructions displayed in the game to either keyboard or pad.\nThe notation for the gamepad is compliant with RPG Maker, so please be aware that\nit does not necessarily match the buttons on the pad you are using.\n(Especially the alphabet letters)\n※ Some special operations such as #{key_button("CTRL")} are fixed to keyboard notation."
  end
end


#==============================================================================
# □ Window_H_Event
#------------------------------------------------------------------------------
#   A window on the options screen for selecting whether to view H scenes.
#==============================================================================

class Window_H_Event < Window_Option
  #--------------------------------------------------------------------------
  # ○ Number of columns
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # ○ Creating command list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("View",   :scene)
    add_command("Skip",   :skip)
    add_command("Choose Each Time",   :select)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def select_last
    select($game_variables[Option::Scene])
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def help_text
    return "You can choose whether to skip already registered H scenes in recollection."
  end
end

#==============================================================================
# □ Window_
#------------------------------------------------------------------------------
#   A window on the options screen for selecting .
#==============================================================================

class Window_AutoSpeed < Window_Option
  #--------------------------------------------------------------------------
  # ○ Number of columns
  #--------------------------------------------------------------------------
  def col_max
    return 9
  end
  #--------------------------------------------------------------------------
  # ○ Creating command list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("１",   :ok)
    add_command("２", :ok)
    add_command("３",   :ok)
    add_command("４", :ok)
    add_command("５",   :ok)
    add_command("６", :ok)
    add_command("７",   :ok)
    add_command("８", :ok)
    add_command("９",   :ok)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def select_last
    select($game_variables[MessageEnhance::V] - 1)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def help_text
    return "You can set the speed for the automatic message progression that starts when you press #{key_button("ALT")} during an event scene. The smaller the number, the faster it goes.\n※ During event scenes, the beads in the four corners of the message window turn blue.\n  When the beads are blue, automatic progression is available.\n(All H scenes can be auto-progressed)"
  end
end

#==============================================================================
# □ Window_
#------------------------------------------------------------------------------
#   A window on the options screen for selecting .
#==============================================================================

class Window_MessageSkip < Window_Option # Added read recognition
  #--------------------------------------------------------------------------
  # ○ Number of columns
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # ○ Creating command list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Only Read Events",   :kidoku)
    add_command("Read + Non-Events",     :people)
    add_command("All", :full)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def select_last
    select($game_switches[Option::Skip] ? 2 : ($game_switches[Option::PeopleSkip] ? 1 : 0))
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def help_text
    return "You can choose the type of text to skip with #{key_button("CTRL")}.\nOnly event conversations that have been seen once will be treated as read.\n'Non-Events' refers to conversations with people in town, combat conversations, etc."
  end
end

#==============================================================================
# □ Window_
#------------------------------------------------------------------------------
#   A window on the options screen for selecting .
#==============================================================================

class Window_H_Opacity < Window_Option
  #--------------------------------------------------------------------------
  # ○ Number of columns
  #--------------------------------------------------------------------------
  def col_max
    return 9
  end
  #--------------------------------------------------------------------------
  # ○ Creating command list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("０",   :ok)
    add_command("１",   :ok)
    add_command("２", :ok)
    add_command("３",   :ok)
    add_command("４", :ok)
    add_command("５",   :ok)
    add_command("６", :ok)
    add_command("７",   :ok)
    add_command("８", :ok)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def select_last
    select($game_variables[Option::H_Opacity] - 1)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def help_text
    return "You can set the opacity of the H scene window background. The smaller the number, the higher the opacity, with '0' being transparent and '8' allowing no transparency."
  end
end

#==============================================================================
# □ Window_
#------------------------------------------------------------------------------
# 　オプション画面で、を選択するウィンドウです。
#==============================================================================

class Window_ExtraH < Window_Option
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :last_b            # 
  attr_accessor :last_s            # 
  attr_accessor :last_f            # 
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # ○ 横に項目が並ぶときの空白の幅を取得
  #--------------------------------------------------------------------------
  #def spacing
    #return 6
  #end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Pregnant Belly:#{v_change($game_variables[Option::EXH_B])}",   :ok)
    add_command("#{Option::WORD_S}:#{v_change($game_variables[Option::EXH_S])}",   :ok)
    add_command("Futanari:#{v_change($game_variables[Option::EXH_F])}",   :ok)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def v_change(v)
    case v
    when 1 ; "View"
    when 2 ; "CG swap"
    when 3 ; "Skip"
    when 4 ; "Confirm"
    else   ; "Not set"
    end
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def last_reset
    @last_b = 0
    @last_s = 0
    @last_f = 0
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    unselect
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "Set up some H scenes with the ↑↓ keys. CG swap replaces the CG\nwith a different version (e.g. a non-futanari version for futanari scenes)\n※Text remains unchanged. Pregnant belly CG cannot be replaced.\nAfter setting all items, confirm with the decision key, or return to the original settings with cancel. Number of each scene: Pseudo Pregnant: 2  Pregnant: 1  #{Option::WORD_S}: 1  Futanari: 1"
  end
  #--------------------------------------------------------------------------
  # 〇 Alignment retrieval
  #--------------------------------------------------------------------------
  def alignment
    return 0
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def num_max
    return 4
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    Sound.play_cursor
    $game_variables[Option::EXH_B + index] -= 1
    $game_variables[Option::EXH_B + index] -= 1 if index == 0 && $game_variables[Option::EXH_B + index] == 2
    $game_variables[Option::EXH_B + index] = num_max if $game_variables[Option::EXH_B + index] < 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    Sound.play_cursor
    $game_variables[Option::EXH_B + index] += 1
    $game_variables[Option::EXH_B + index] += 1 if index == 0 && $game_variables[Option::EXH_B + index] == 2
    $game_variables[Option::EXH_B + index] = 1 if $game_variables[Option::EXH_B + index] > num_max
    refresh
  end
  
end


#==============================================================================
# □ Window_
#------------------------------------------------------------------------------
# 　Select window for options menu.
#==============================================================================

class Window_Danmenzu < Window_Option
  #--------------------------------------------------------------------------
  # 〇 Number of digits retrieval
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # 〇 Command list creation
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Show",   :show)
    add_command("Do not show", :hide)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    $game_switches[Option::EXH_D] ? select(1) : select(0)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "Set whether or not to display cross-sectional views in some penetration H scenes.\nThere are not many scenes with cross-sectional views."
  end
end


#==============================================================================
# □ Window_
#------------------------------------------------------------------------------
# 　Select window for options menu.
#==============================================================================

class Window_ShotCount < Window_Option
  #--------------------------------------------------------------------------
  # 〇 Number of digits retrieval
  #--------------------------------------------------------------------------
  def col_max
    return 11 #4
  end
  #--------------------------------------------------------------------------
  # 〇 Width of blank space when items are aligned horizontally
  #--------------------------------------------------------------------------
  def spacing
    return 2
  end
  #--------------------------------------------------------------------------
  # 〇 Command list creation
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("０",   :ok)
    add_command("１",   :ok)
    add_command("２", :ok)
    add_command("３",   :ok)
    add_command("４", :ok)
    add_command("５",   :ok)
    add_command("６", :ok)
    add_command("７",   :ok)
    add_command("８", :ok)
    add_command("９",   :ok)
    add_command("10", :ok)
=begin
    add_command("8",   :ok)
    add_command("5",   :ok)
    add_command("3", :ok)
    add_command("No count", :ok)
=end
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    select($game_variables[Option::EXH_SHOT] - 1)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "Set how many pages before ejaculation to start counting\nin H scenes with ejaculation (1 page is 1 window).\nIf ejaculation intervals are close (e.g. gangbang), it starts with a lower number\nthan the set value. Also, the last ejaculation in a scene is counted with yellow numbers.\n※\"0\" setting does not perform counting"
  end
end



#==============================================================================
# □ Window_
#------------------------------------------------------------------------------
# 　オプション画面で、を選択するウィンドウです。
#==============================================================================

class Window_Volume < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 6
  end
  #--------------------------------------------------------------------------
  # ○ 横に項目が並ぶときの空白の幅を取得
  #--------------------------------------------------------------------------
  def spacing
    return 0
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("BGM:#{Audio.bgm_vol}",   :ok)
    add_command("BGS:#{Audio.bgs_vol}", :ok)
    add_command("SE:#{Audio.se_vol}",   :ok)
    add_command("ME:#{Audio.me_vol}", :ok)
    add_command("HBG:#{Audio.h_bgs_vol}", :ok)
    add_command("HSE:#{Audio.h_se_vol}",   :ok)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    unselect
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return ""
  end
  #--------------------------------------------------------------------------
  # 〇 標準パディングサイズの取得
  #--------------------------------------------------------------------------
  def standard_padding
    return 0
  end
  #--------------------------------------------------------------------------
  # 〇 アライメントの取得
  #--------------------------------------------------------------------------
  def alignment
    return 0
  end
end

#==============================================================================
# □ Window_
#------------------------------------------------------------------------------
# 　オプション画面で、を選択するウィンドウです。
#==============================================================================

class Window_ScreenZoom < Window_Option
  #--------------------------------------------------------------------------
  # 〇 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Zoom",  :zoom)
    add_command("Normal",  :normal)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def select_last
    $game_switches[Option::ScreenZoom] ? select(1) : select(0)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def help_text
    return "At the start of the game, you can choose whether to begin with an enlarged screen size.\nScreen size changes during the game can be performed with \ekb[f5],\nand will vary up to three levels depending on the display resolution.\n"
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
  alias option_add_original_commands add_original_commands
  def add_original_commands
    option_add_original_commands
    add_command("Options",  :option)
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
  alias option_create_command_window create_command_window
  def create_command_window
    option_create_command_window
    @command_window.set_handler(:option,     method(:on_option))
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def on_option
    SceneManager.call(Scene_Option)
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
  # 〇 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :return_symbol                # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias return_initialize initialize
  def initialize
    return_initialize
    return_symbol_reset
  end
  #--------------------------------------------------------------------------
  # 〇 リターンシンボル初期化
  #--------------------------------------------------------------------------
  def return_symbol_reset
    @return_symbol = nil
  end
end


#==============================================================================
# □ Scene_Option
#------------------------------------------------------------------------------
# 　オプション画面の処理を行うクラスです。
#==============================================================================

class Scene_Option < Scene_MenuBase
  #--------------------------------------------------------------------------
  # 〇 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_viewport_sub
    create_help_window
    create_info_window
    create_command_window
    create_dummy_window
    create_difficulty_window
    create_dash_window
    create_skill_window
    create_learned_window
    create_magic_window
    create_item_window
    create_heal_window
    create_zoom_window
    create_button_window
    create_event_window
    create_auto_window
    create_skip_window # 既読判定追加
    create_opacity_window
    create_extrah_window
    create_dmz_window
    create_count_window
    create_volume_window
  end
  #--------------------------------------------------------------------------
  # 〇 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # 〇 フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    case @command_window.page_index
    when 0
      @viewport2.visible = true
      @viewport3.visible = false
    else
      @viewport3.visible = true
      @viewport2.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # 〇 サブビューポートの作成
  #--------------------------------------------------------------------------
  def create_viewport_sub
    @viewport2 = Viewport.new
    @viewport2.z = 300
    @viewport3 = Viewport.new
    @viewport3.z = 300
    @viewport3.visible = false
  end
  #--------------------------------------------------------------------------
  # 〇 ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(5)
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    y = @info_window.height
    @command_window = Window_OptionCommand.new(0, y)
    @command_window.set_handler(:difficulty,      method(:select_difficulty))
    @command_window.set_handler(:dash,      method(:select_dash))
    @command_window.set_handler(:skill_lv,      method(:select_skill))
    @command_window.set_handler(:learned,      method(:select_learned))
    @command_window.set_handler(:magic_punch,      method(:select_magic))
    @command_window.set_handler(:item_start,      method(:select_item))
    @command_window.set_handler(:quick_heal,      method(:select_heal))    

    @command_window.set_handler(:button,      method(:select_button))
    @command_window.set_handler(:h_event,      method(:select_event))
    @command_window.set_handler(:auto_speed,      method(:select_auto))
    @command_window.set_handler(:message_skip,      method(:select_skip)) # 既読判定追加
    @command_window.set_handler(:opacity,      method(:select_opacity))
    @command_window.set_handler(:exh_event,      method(:select_extrah))
    @command_window.set_handler(:dmz,      method(:select_dmz))
    @command_window.set_handler(:shot_count,      method(:select_count))

    @command_window.set_handler(:volume,      method(:select_volume))
    @command_window.set_handler(:zoom,      method(:select_zoom))
    @command_window.set_handler(:cancel,    method(:return_scene))
    @command_window.info_window = @info_window
    @command_window.help_window = @help_window
    @command_window.viewport = @viewport
    @help_window.y = @command_window.y + @command_window.height
  end
  #--------------------------------------------------------------------------
  # 〇 ダミーウィンドウの作成
  #--------------------------------------------------------------------------
  def create_dummy_window
    wx = @command_window.width
    wy = @command_window.y
    ww = Graphics.width - wx
    wh = @command_window.height
    @dummy_window = Window_Base.new(wx, wy, ww, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # 〇 インフォウィンドウの作成
  #--------------------------------------------------------------------------
  def create_info_window
    wy = 0#@command_window.y + @command_window.height
    @info_window = Window_OptionInfo.new(wy)
    @info_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # 〇 難易度ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_difficulty_window
    x = @command_window.width + 12
    y = @command_window.y + 6
    ww = Graphics.width - @command_window.width - 24
    @difficulty_window = Window_Difficulty.new(x, y, ww)
    @difficulty_window.set_handler(:ok,     method(:on_difficulty_ok))
    @difficulty_window.set_handler(:cancel, method(:on_difficulty_cancel))
    @difficulty_window.help_window = @help_window
    @difficulty_window.viewport = @viewport2
  end
  #--------------------------------------------------------------------------
  # 〇 ダッシュウィンドウの作成
  #--------------------------------------------------------------------------
  def create_dash_window
    base = @difficulty_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @dash_window = Window_Dash.new(x, y, ww)
    @dash_window.set_handler(:ok,     method(:on_dash_ok))
    @dash_window.set_handler(:cancel, method(:on_dash_cancel))
    @dash_window.help_window = @help_window
    @dash_window.viewport = @viewport2
  end
  #--------------------------------------------------------------------------
  # 〇 スキルLVウィンドウの作成
  #--------------------------------------------------------------------------
  def create_skill_window
    base = @dash_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @skill_window = Window_SkillLevel.new(x, y, ww)
    @skill_window.set_handler(:ok,     method(:on_skill_ok))
    @skill_window.set_handler(:cancel, method(:on_skill_cancel))
    @skill_window.help_window = @help_window
    @skill_window.viewport = @viewport2
  end
  #--------------------------------------------------------------------------
  # 〇 習得済みウィンドウの作成
  #--------------------------------------------------------------------------
  def create_learned_window
    base = @skill_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @learned_window = Window_Learned.new(x, y, ww)
    @learned_window.set_handler(:ok,     method(:on_learned_ok))
    @learned_window.set_handler(:cancel, method(:on_learned_cancel))
    @learned_window.help_window = @help_window
    @learned_window.viewport = @viewport2
  end
  #--------------------------------------------------------------------------
  # 〇 魔力殴打ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_magic_window
    base = @learned_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @magic_window = Window_MagicPunch.new(x, y, ww)
    @magic_window.set_handler(:ok,     method(:on_magic_ok))
    @magic_window.set_handler(:cancel, method(:on_magic_cancel))
    @magic_window.help_window = @help_window
    @magic_window.viewport = @viewport2
  end
  #--------------------------------------------------------------------------
  # 〇 簡易アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    base = @magic_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @item_window = Window_ItemStart.new(x, y, ww)
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @item_window.help_window = @help_window
    @item_window.viewport = @viewport2
  end
  #--------------------------------------------------------------------------
  # 〇 クイックヒールウィンドウの作成
  #--------------------------------------------------------------------------
  def create_heal_window
    base = @item_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @heal_window = Window_HealOption.new(x, y, ww)
    @heal_window.set_handler(:ok,     method(:on_heal_ok))
    @heal_window.set_handler(:cancel, method(:on_heal_cancel))
    @heal_window.help_window = @help_window
    @heal_window.viewport = @viewport2
  end
  #--------------------------------------------------------------------------
  # 〇 拡大表示ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_zoom_window
    base = @heal_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @zoom_window = Window_ScreenZoom.new(x, y, ww)
    @zoom_window.set_handler(:ok,     method(:on_zoom_ok))
    @zoom_window.set_handler(:cancel, method(:on_zoom_cancel))
    @zoom_window.help_window = @help_window
    @zoom_window.viewport = @viewport2
  end
  #--------------------------------------------------------------------------
  # 〇 音量ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_volume_window
    base = @zoom_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @volume_window = Window_Volume.new(x, y, ww)
    @volume_window.help_window = @help_window
    @volume_window.viewport = @viewport2
  end
  #--------------------------------------------------------------------------
  # 〇 ボタンウィンドウの作成
  #--------------------------------------------------------------------------
  def create_button_window
    x = @command_window.width + 12
    y = @command_window.y + 6
    ww = Graphics.width - @command_window.width - 24
    @button_window = Window_KeyButton.new(x, y, ww)
    @button_window.set_handler(:ok,     method(:on_button_ok))
    @button_window.set_handler(:cancel, method(:on_button_cancel))
    @button_window.help_window = @help_window
    @button_window.viewport = @viewport3
  end
  #--------------------------------------------------------------------------
  # 〇 Hイベントウィンドウの作成
  #--------------------------------------------------------------------------
  def create_event_window
    base = @button_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @event_window = Window_H_Event.new(x, y, ww)
    @event_window.set_handler(:ok,     method(:on_event_ok))
    @event_window.set_handler(:cancel, method(:on_event_cancel))
    @event_window.help_window = @help_window
    @event_window.viewport = @viewport3
  end
  #--------------------------------------------------------------------------
  # 〇 オートモードウィンドウの作成
  #--------------------------------------------------------------------------
  def create_auto_window
    base = @event_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @auto_window = Window_AutoSpeed.new(x, y, ww)
    @auto_window.set_handler(:ok,     method(:on_auto_ok))
    @auto_window.set_handler(:cancel, method(:on_auto_cancel))
    @auto_window.help_window = @help_window
    @auto_window.viewport = @viewport3
  end
  #--------------------------------------------------------------------------
  # 〇 メッセージスキップウィンドウの作成 # 既読判定追加
  #--------------------------------------------------------------------------
  def create_skip_window
    base = @auto_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @skip_window = Window_MessageSkip.new(x, y, ww)
    @skip_window.set_handler(:ok,     method(:on_skip_ok))
    @skip_window.set_handler(:cancel, method(:on_skip_cancel))
    @skip_window.help_window = @help_window
    @skip_window.viewport = @viewport3
  end
  #--------------------------------------------------------------------------
  # 〇 背景透過率ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_opacity_window
    base = @skip_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @opacity_window = Window_H_Opacity.new(x, y, ww)
    @opacity_window.set_handler(:ok,     method(:on_opacity_ok))
    @opacity_window.set_handler(:cancel, method(:on_opacity_cancel))
    @opacity_window.help_window = @help_window
    @opacity_window.viewport = @viewport3
  end
  #--------------------------------------------------------------------------
  # 〇 性癖ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_extrah_window
    base = @opacity_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @extrah_window = Window_ExtraH.new(x, y, ww)
    @extrah_window.set_handler(:ok,     method(:on_extrah_ok))
    @extrah_window.set_handler(:cancel, method(:on_extrah_cancel))
    @extrah_window.help_window = @help_window
    @extrah_window.viewport = @viewport3
  end
  #--------------------------------------------------------------------------
  # 〇 DMZウィンドウの作成
  #--------------------------------------------------------------------------
  def create_dmz_window
    base = @extrah_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @dmz_window = Window_Danmenzu.new(x, y, ww)
    @dmz_window.set_handler(:ok,     method(:on_dmz_ok))
    @dmz_window.set_handler(:cancel, method(:on_dmz_cancel))
    @dmz_window.help_window = @help_window
    @dmz_window.viewport = @viewport3
  end
  #--------------------------------------------------------------------------
  # 〇 射精カウントウィンドウの作成
  #--------------------------------------------------------------------------
  def create_count_window
    base = @dmz_window
    x = base.x
    y = base.y + base.height
    ww = base.width
    @count_window = Window_ShotCount.new(x, y, ww)
    @count_window.set_handler(:ok,     method(:on_count_ok))
    @count_window.set_handler(:cancel, method(:on_count_cancel))
    @count_window.help_window = @help_window
    @count_window.viewport = @viewport3
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［難易度］
  #--------------------------------------------------------------------------
  def select_difficulty
    @difficulty_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［ダッシュ］
  #--------------------------------------------------------------------------
  def select_dash
    @dash_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［スキルLV］
  #--------------------------------------------------------------------------
  def select_skill
    @skill_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［習得済みスキル］
  #--------------------------------------------------------------------------
  def select_learned
    @learned_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［魔力殴打］
  #--------------------------------------------------------------------------
  def select_magic
    @magic_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［簡易アイテム］
  #--------------------------------------------------------------------------
  def select_item
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［クイックヒール］
  #--------------------------------------------------------------------------
  def select_heal
    @heal_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［ボタン］
  #--------------------------------------------------------------------------
  def select_button
    @button_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［Hイベント］
  #--------------------------------------------------------------------------
  def select_event
    @event_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［オート］
  #--------------------------------------------------------------------------
  def select_auto
    @auto_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［スキップ］ # 既読判定追加
  #--------------------------------------------------------------------------
  def select_skip
    @skip_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［背景透過率］
  #--------------------------------------------------------------------------
  def select_opacity
    @opacity_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［性癖］
  #--------------------------------------------------------------------------
  def select_extrah
    @extrah_window.activate
    @extrah_window.select(0)
    
    @extrah_window.last_b = $game_variables[Option::EXH_B]
    @extrah_window.last_s = $game_variables[Option::EXH_S]
    @extrah_window.last_f = $game_variables[Option::EXH_F]
    #$game_temp.return_symbol = :exh_event
    #SceneManager.call(HZM_VXA::AudioVol::Scene_VolConfig)
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［断面図］
  #--------------------------------------------------------------------------
  def select_dmz
    @dmz_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［射精カウント］
  #--------------------------------------------------------------------------
  def select_count
    @count_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［音量変更］
  #--------------------------------------------------------------------------
  def select_volume
    $game_temp.return_symbol = :volume
    SceneManager.call(HZM_VXA::AudioVol::Scene_VolConfig)
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［拡大表示］
  #--------------------------------------------------------------------------
  def select_zoom
    @zoom_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 難易度［決定］
  #--------------------------------------------------------------------------
  def on_difficulty_ok
    $game_system.difficulty_set(@difficulty_window.current_symbol)
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 難易度［キャンセル］
  #--------------------------------------------------------------------------
  def on_difficulty_cancel
    @difficulty_window.select_last
    @difficulty_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 ダッシュ［決定］
  #--------------------------------------------------------------------------
  def on_dash_ok
    $game_switches[FAKEREAL::IDATEN] = @dash_window.current_symbol == :dash
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 ダッシュ［キャンセル］
  #--------------------------------------------------------------------------
  def on_dash_cancel
    @dash_window.select_last
    @dash_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 スキルLV［決定］
  #--------------------------------------------------------------------------
  def on_skill_ok
    $game_system.skill_lv_visible = @skill_window.current_symbol == :show
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 スキルLV［キャンセル］
  #--------------------------------------------------------------------------
  def on_skill_cancel
    @skill_window.select_last
    @skill_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 習得済みスキル［決定］
  #--------------------------------------------------------------------------
  def on_learned_ok
    $game_switches[Learn::HIDE] = @learned_window.current_symbol == :hide
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 習得済みスキル［キャンセル］
  #--------------------------------------------------------------------------
  def on_learned_cancel
    @learned_window.select_last
    @learned_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 魔力殴打［決定］
  #--------------------------------------------------------------------------
  def on_magic_ok
    $game_switches[Option::MagicPunch] = @magic_window.current_symbol == :change
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 魔力殴打［キャンセル］
  #--------------------------------------------------------------------------
  def on_magic_cancel
    @magic_window.select_last
    @magic_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 簡易アイテム［決定］
  #--------------------------------------------------------------------------
  def on_item_ok
    $game_variables[Option::ItemStart] = @item_window.index
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 簡易アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.select_last
    @item_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 クイックヒール［決定］
  #--------------------------------------------------------------------------
  def on_heal_ok
    $game_variables[Option::EASY_HEAL] = @heal_window.index
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 クイックヒール［キャンセル］
  #--------------------------------------------------------------------------
  def on_heal_cancel
    @heal_window.select_last
    @heal_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 ボタン［決定］
  #--------------------------------------------------------------------------
  def on_button_ok
    $game_variables[Option::Button] = @button_window.index
    PUBLIC_DATA.write_option_data
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 ボタン［キャンセル］
  #--------------------------------------------------------------------------
  def on_button_cancel
    @button_window.select_last
    @button_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 Hイベント［決定］
  #--------------------------------------------------------------------------
  def on_event_ok
    $game_variables[Option::Scene] = @event_window.index
    PUBLIC_DATA.write_option_data
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 Hイベント［キャンセル］
  #--------------------------------------------------------------------------
  def on_event_cancel
    @event_window.select_last
    @event_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 オートモード［決定］
  #--------------------------------------------------------------------------
  def on_auto_ok
    $game_variables[MessageEnhance::V] = @auto_window.index + 1
    PUBLIC_DATA.write_option_data
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 オートモード［キャンセル］
  #--------------------------------------------------------------------------
  def on_auto_cancel
    @auto_window.select_last
    @auto_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 スキップ［決定］ # 既読判定追加
  #--------------------------------------------------------------------------
  def on_skip_ok
    case @skip_window.current_symbol
    when :full
      $game_switches[Option::Skip] = true
      $game_switches[Option::PeopleSkip] = false
    when :people
      $game_switches[Option::Skip] = false
      $game_switches[Option::PeopleSkip] = true
    else
      $game_switches[Option::Skip] = false
      $game_switches[Option::PeopleSkip] = false
    end
    PUBLIC_DATA.write_option_data
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 スキップ［キャンセル］ # 既読判定追加
  #--------------------------------------------------------------------------
  def on_skip_cancel
    @skip_window.select_last
    @skip_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 背景透過率［決定］
  #--------------------------------------------------------------------------
  def on_opacity_ok
    $game_variables[Option::H_Opacity] = @opacity_window.index + 1
    PUBLIC_DATA.write_option_data
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 背景透過率［キャンセル］
  #--------------------------------------------------------------------------
  def on_opacity_cancel
    @opacity_window.select_last
    @opacity_window.deactivate
    @command_window.activate
  end
  
  
  #--------------------------------------------------------------------------
  # 〇 性癖［決定］
  #--------------------------------------------------------------------------
  def on_extrah_ok
    @extrah_window.select_last
    PUBLIC_DATA.write_option_data
    @command_window.activate
    @extrah_window.last_reset
  end
  #--------------------------------------------------------------------------
  # 〇 性癖［キャンセル］
  #--------------------------------------------------------------------------
  def on_extrah_cancel
    @extrah_window.select_last
    @extrah_window.deactivate
    $game_variables[Option::EXH_B] = @extrah_window.last_b
    $game_variables[Option::EXH_S] = @extrah_window.last_s
    $game_variables[Option::EXH_F] = @extrah_window.last_f
    @extrah_window.refresh
    PUBLIC_DATA.write_option_data
    @command_window.activate
    @extrah_window.last_reset
  end
  

  #--------------------------------------------------------------------------
  # 〇 断面図［決定］
  #--------------------------------------------------------------------------
  def on_dmz_ok
    $game_switches[Option::EXH_D] = @dmz_window.current_symbol == :hide
    PUBLIC_DATA.write_option_data
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 断面図［キャンセル］
  #--------------------------------------------------------------------------
  def on_dmz_cancel
    @dmz_window.select_last
    @dmz_window.deactivate
    @command_window.activate
  end
  
  #--------------------------------------------------------------------------
  # 〇 射精カウント［決定］
  #--------------------------------------------------------------------------
  def on_count_ok
    $game_variables[Option::EXH_SHOT] = @count_window.index + 1 #.current_symbol == :no_count
    PUBLIC_DATA.write_option_data
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 射精カウント［キャンセル］
  #--------------------------------------------------------------------------
  def on_count_cancel
    @count_window.select_last
    @count_window.deactivate
    @command_window.activate
  end
  
  #--------------------------------------------------------------------------
  # 〇 拡大［決定］
  #--------------------------------------------------------------------------
  def on_zoom_ok
    $game_switches[Option::ScreenZoom] = @zoom_window.current_symbol != :zoom
    PUBLIC_DATA.write_option_data
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 拡大［キャンセル］
  #--------------------------------------------------------------------------
  def on_zoom_cancel
    @zoom_window.select_last
    @zoom_window.deactivate
    @command_window.activate
  end
  
  
end

#==============================================================================
# ■ PUBLIC_DATA
#------------------------------------------------------------------------------
# 　共有データの書き込み、読み込みを実行するモジュール
#==============================================================================
module PUBLIC_DATA
  OPTION_S = [89, 90, 314, 306] #オプション項目スイッチ # 既読判定等追加
  OPTION_V = [35, *(39..41), *(131..134)] #オプション項目変数
  #--------------------------------------------------------------------------
  # 〇 オプションデータの書き込み
  #--------------------------------------------------------------------------
  def self.write_option_data
    OPTION_S.each{|i| $public[0][i] = $game_switches[i]}
    OPTION_V.each{|i| $public[1][i] = $game_variables[i]}
    #OPTION_S.each{|i| $public.memory(0, i, $game_switches[i]) }
    #OPTION_V.each{|i| $public.memory(1, i, $game_variables[i])}
    save_data($public, FILE_NAME)
  end
end

#==============================================================================
# ■ Window_TitleCommand
#------------------------------------------------------------------------------
# 　タイトル画面で、ニューゲーム／コンティニューを選択するウィンドウです。
#==============================================================================

class Window_TitleCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::new_game, :new_game)
    add_command(Vocab::continue, :continue, continue_enabled)
    add_command("Options", :option)
    add_command(Vocab::shutdown, :shutdown)
  end
end

#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　タイトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias opt_start start
  def start
    opt_start
    PUBLIC_DATA.read_public_data
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias opt_create_command_window create_command_window
  def create_command_window
    opt_create_command_window
    @command_window.set_handler(:option, method(:command_option))
  end
  #--------------------------------------------------------------------------
  # 〇 コマンド［オプション］
  #--------------------------------------------------------------------------
  def command_option
    close_command_window
    SceneManager.call(Scene_Option)
  end
end



#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　スキルやアイテムの説明、アクターのステータスなどを表示するウィンドウです。
#==============================================================================

class Window_OptionInfo < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(y, line_number = 2)
    super(0, y, Graphics.width, fitting_height(line_number))
    #self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● クリア
  #--------------------------------------------------------------------------
  def clear
    set_text("")
  end
  #--------------------------------------------------------------------------
  # ● アイテム設定
  #     item : スキル、アイテム等
  #--------------------------------------------------------------------------
  def set_item(item)
    set_text("#{item}/2 Page")
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(important_color)
    draw_text(0, 0, contents.width, line_height, @text, 1)
    draw_text(0, line_height, contents.width, line_height, "Change page with ← → when selecting item", 1)
    change_color(normal_color)
  end
end
