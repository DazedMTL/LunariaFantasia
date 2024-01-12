#==============================================================================
# ■ Scene_Learn
#------------------------------------------------------------------------------
# 　技習得画面の処理を行うクラスです。
#==============================================================================

class Scene_Learn < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_point_window
    create_category_window
    create_item_window
    create_result_window
    create_yesno_window
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    super
    @help_window.y = Graphics.height - @help_window.height
  end
  #--------------------------------------------------------------------------
  # ● カテゴリウィンドウの作成
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_LearnCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @point_window.height
    @category_window.set_handler(:learn,      method(:on_category_ok))
    @category_window.set_handler(:skillup,  method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:return_scene))
    @category_window.set_handler(:pagedown, method(:next_actor))
    @category_window.set_handler(:pageup,   method(:prev_actor))
    @category_window.point_window = @point_window
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 0
    wy = @category_window.y + @category_window.height
    ww = Graphics.width
    wh = Graphics.height - wy - @help_window.height
    @item_window = Window_SkillUpList.new(wx, wy, ww, wh)
    @item_window.actor = @actor
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.point_window = @point_window
    @item_window.set_handler(:ok,     method(:item_select))
    @item_window.set_handler(:cancel, method(:return_category))
    @item_window.set_handler(:hide_change,      method(:hide_skill))
    @category_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # ● ポイントウィンドウの作成
  #--------------------------------------------------------------------------
  def create_point_window
    wy = 0 #@help_window.height
    @point_window = Window_LearnPoint.new(wy)
    @point_window.actor = @actor
    @point_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # ● リザルトウィンドウの作成
  #--------------------------------------------------------------------------
  def create_result_window
    @result_window = Window_LearnResult.new
    @result_window.viewport = @viewport
    @category_window.result_window = @result_window
  end
  #--------------------------------------------------------------------------
  # ● はい、いいえウィンドウの作成
  #--------------------------------------------------------------------------
  def create_yesno_window
    @yesno_window = Window_YesNoChoice.new
    @yesno_window.viewport = @viewport
    @yesno_window.y = @result_window.y + @result_window.height
    @yesno_window.set_handler(:yes_select,     method(:on_item_ok))
    @yesno_window.set_handler(:no_select,      method(:on_item_cancel))
    @yesno_window.set_handler(:cancel,         method(:on_item_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 現在選択されているアイテムの習得値取得
  #--------------------------------------------------------------------------
  def skill_ap
    if @category_window.current_symbol == :learn
      Learn.l_flag(item)[0]
    else
      return 0 if !item
      base = Learn.lvup_point(item)[0]
      plus = Learn.lvup_point(item)[1]
      return base + plus * (@actor.skill_lv(item.id) - 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム［選択］
  #--------------------------------------------------------------------------
  def item_select
    @result_window.learn_skill = item
    @result_window.point = skill_ap
    @result_window.show
    @yesno_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ［決定］
  #--------------------------------------------------------------------------
  def on_category_ok
    @item_window.activate
    @item_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● カテゴリ［キャンセル］
  #--------------------------------------------------------------------------
  def return_category
    @item_window.unselect
    @point_window.set_item_point(0)
    @category_window.activate
  end
  #--------------------------------------------------------------------------
  # ● アイテム［決定］
  #--------------------------------------------------------------------------
  def on_item_ok
    play_se_for_learn
    @result_window.hide
    @yesno_window.hide
    @actor.ap -= skill_ap
    @point_window.point = @actor.ap
    if @category_window.current_symbol == :learn
      @actor.learn_skill(item.id)
    else
      @actor.skill_lv_up(item.id, 1)
    end
    @item_window.refresh
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ● アイテム［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_cancel
    Sound.play_cancel
    @result_window.hide
    @yesno_window.select(0)
    @yesno_window.hide.deactivate
    @item_window.refresh
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    @point_window.actor = @actor
    @point_window.set_item_point(0)
    @item_window.actor = @actor
    @item_window.refresh
    @category_window.activate
    @category_window.index = 0
  end
  #--------------------------------------------------------------------------
  # ● スキル表示の切り替え
  #--------------------------------------------------------------------------
  def hide_skill
    @item_window.hide_change
    @item_window.index = 0
    #@item_window.refresh
    #@item_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 技習得時の SE 演奏
  #--------------------------------------------------------------------------
  def play_se_for_learn
    Sound.play_use_skill
  end
end

#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　メニュー画面で表示するコマンドウィンドウです。
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成　※再定義　並び替え削除
  #--------------------------------------------------------------------------
  def make_command_list
    add_main_commands
    #add_formation_command
    add_original_commands
    add_save_command
    add_game_end_command
  end
  #--------------------------------------------------------------------------
  # ● 主要コマンドをリストに追加　※エイリアス
  #--------------------------------------------------------------------------
  alias learn_add_main_commands add_main_commands
  def add_main_commands
    learn_add_main_commands
    add_command(Vocab::learn,  :learn,  main_commands_enabled)
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
  alias learn_create_command_window create_command_window
  def create_command_window
    learn_create_command_window
    @command_window.set_handler(:learn,     method(:command_personal))
  end
  #--------------------------------------------------------------------------
  # ● 個人コマンド［決定］　※再定義
  #--------------------------------------------------------------------------
  def on_personal_ok
    case @command_window.current_symbol
    when :skill
      SceneManager.call(Scene_Skill)
    when :equip
      SceneManager.call(Scene_Equip)
    when :status
      SceneManager.call(Scene_Status)
    when :learn
      SceneManager.call(Scene_Learn)
    end
  end
end