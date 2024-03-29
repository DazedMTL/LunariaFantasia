module FREA
  #--------------------------------------------------------------------------
  # ○ 属性耐性の描画
  #--------------------------------------------------------------------------
  def draw_analyze_elements(x, y)
    ary = ["Physical","Absorb","Fire","Ice","Thunder","Light","Darkness","Charm","Exorcism","Steal"]
    str = "Elements"
    rate = {}
    ary.each{|name| rate[FRGP::ELEMENT_ICON[elements_comvert(name)]] = elg_rate_analyze(name)}
    draw_percent(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ Drawing state resistances
  #--------------------------------------------------------------------------
  def draw_analyze_state(x, y, ext = "Charm")
    ary = ["Instant Death","Poison","Blind","Silence","Confusion","Sleep","Paralysis","Stun",ext]
    str = "States"
    rate = {}
    ary.compact.each{|name| rate[$data_states[state_comvert(name)].icon_index] = stg_rate_analyze(name)}
    draw_percent(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ Drawing debuff resistances
  #--------------------------------------------------------------------------
  def draw_analyze_debuff(x, y)
    ary = [2, 3, 4, 5, 6, 7]
    str = "Debuffs"
    rate = {}
    ary.each{|id| rate[FRGP::ICON_DEBUFF_START + id] = debuff_rate_analyze(id)}
    draw_percent(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ IDを属性耐性に変換
  #--------------------------------------------------------------------------
  def elg_rate_analyze(element_name)
    (@actor.element_rate(elements_comvert(element_name)) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ IDを状態耐性に変換
  #--------------------------------------------------------------------------
  def stg_rate_analyze(state_name)
    id = state_comvert(state_name)
    return 0 if @actor.state_resist?(id)
    (@actor.state_rate(id) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ IDを弱体耐性に変換
  #--------------------------------------------------------------------------
  def debuff_rate_analyze(id)
    (@actor.debuff_rate(id) * 100).round
  end
end

#==============================================================================
# □ Window_Analyze
#------------------------------------------------------------------------------
# 　を表示するウィンドウです。
#==============================================================================

class Window_Analyze < Window_Base
  include FRGP
  include FREA
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @actor = nil
    self.opacity = 0
    hide
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 320
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
    return 11
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
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return if !@actor.is_a?(Game_Battler)
    draw_background(contents.rect)
    draw_analyze_elements(8, 0)
    draw_analyze_state(108, 0)
    draw_analyze_debuff(208, 0)
  end
  #--------------------------------------------------------------------------
  # ○ 背景の描画
  #--------------------------------------------------------------------------
  def draw_background(rect)
    contents.fill_rect(rect, back_color)
  end
  #--------------------------------------------------------------------------
  # ○ 背景色の取得
  #--------------------------------------------------------------------------
  def back_color
    Color.new(0, 0, 0, 192)
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成
  #--------------------------------------------------------------------------
  alias enemy_analyze_create_all_windows create_all_windows
  def create_all_windows
    enemy_analyze_create_all_windows
    create_analyze_window
  end
  #--------------------------------------------------------------------------
  # ● 敵キャラウィンドウの作成
  #--------------------------------------------------------------------------
  def create_analyze_window
    @analyze_window = Window_Analyze.new(320,@targethelp_window.height)
    @enemy_window.analyze_window = @analyze_window
  end
end

#==============================================================================
# ■ Window_BattleEnemy
#------------------------------------------------------------------------------
# 　バトル画面で、行動対象の敵キャラを選択するウィンドウです。
# 横並びの不可視のウィンドウとして扱います。
#==============================================================================

class Window_BattleEnemy < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_analyze
    @analyze_window.actor = targetcursor
  end
  #--------------------------------------------------------------------------
  # ○ 分析ウィンドウの設定
  #--------------------------------------------------------------------------
  def analyze_window=(analyze_window)
    @analyze_window = analyze_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ○ ヘルプウィンドウ更新メソッドの呼び出し
  #--------------------------------------------------------------------------
  def call_update_help
    super
    update_analyze if active && @analyze_window
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの変更トリガー
  #--------------------------------------------------------------------------
  def window_change
    Input.trigger?(:Z) && active && $game_party.weak_disclose? && !cursor_all
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの非表示化設定
  #--------------------------------------------------------------------------
  def window_off
    if !active
      @analyze_window.visible = false# if !@item_window.visible && !@skill_window.visible
    end
  end
  #--------------------------------------------------------------------------
  # ○ 更新
  #--------------------------------------------------------------------------
  def update
    super
    update_page
    window_off
  end
  #--------------------------------------------------------------------------
  # ○ ページの更新
  #--------------------------------------------------------------------------
  def update_page
    $game_temp.target_cursor_sprite.x > 320 ? @analyze_window.x = 0 : @analyze_window.x = 320
    if window_change
      Sound.play_cursor
      @analyze_window.visible ^= true
    end
  end
end