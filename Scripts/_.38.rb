#==============================================================================
# ■ Window_SkillCommand
#------------------------------------------------------------------------------
# 　スキル画面で、コマンド（特技や魔法など）を選択するウィンドウです。
#==============================================================================

class Window_OptimizeCommand < Window_Command
  #--------------------------------------------------------------------------
  # 〇 オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
    @actor = nil
    self.openness = 0
    deactivate
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 134
  end
  #--------------------------------------------------------------------------
  # 〇 アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    select_last
  end
  #--------------------------------------------------------------------------
  # 〇 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return @actor ? @actor.optimize_pattern.size : 2
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    @actor.optimize_pattern.each do |k, v|
      add_command(k, :optimize, true, v)
    end
  end
  #--------------------------------------------------------------------------
  # 〇 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select(0)
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.height = window_height
    self.y = @help_window.height + fitting_height(1) - window_height if @help_window
    super
  end
end

#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias optimize_start start
  def start
    optimize_start
    create_optimize_window
  end
  #--------------------------------------------------------------------------
  # 〇 最適装備ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_optimize_window
    wx = @command_window.x + @command_window.width / 2 - 67
    wy = @command_window.y - @command_window.height / 2
    @optimize_window = Window_OptimizeCommand.new(wx, wy)
    @optimize_window.viewport = @viewport
    @optimize_window.help_window = @help_window
    @optimize_window.set_handler(:optimize,    method(:optimize_equip))
    @optimize_window.set_handler(:cancel,    method(:optimize_cancel))
    @optimize_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # ● コマンド［最強装備］
  #--------------------------------------------------------------------------
  def command_optimize
    @optimize_window.open.activate.select_last
    #update until @optimize_window.open?
  end
  #--------------------------------------------------------------------------
  # 〇 最強装備決定
  #--------------------------------------------------------------------------
  def optimize_equip
    Sound.play_equip
    @actor.optimize_equipments(@optimize_window.current_ext)
    @status_window.refresh
    @slot_window.refresh
    @optimize_window.activate
    #@optimize_window.close
    #update until @optimize_window.close?
    #@command_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 最強装備キャンセル
  #--------------------------------------------------------------------------
  def optimize_cancel
    @optimize_window.deactivate#unselect
    @optimize_window.close
    update until @optimize_window.close?
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  alias optimize_on_actor_change on_actor_change
  def on_actor_change
    optimize_on_actor_change
    @optimize_window.actor = @actor
  end
end