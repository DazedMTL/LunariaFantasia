#==============================================================================
# □ Learn
#------------------------------------------------------------------------------
# 　　技習得関連のデータを管理するモジュールです。
#==============================================================================

module Learn
  S_LV_MAX = 4
  HIDE = 88
  #--------------------------------------------------------------------------
  # ○ スキルのフラグ検索
  #--------------------------------------------------------------------------
  def self.l_flag(skill)
    return [0, [], 1, false, []] if !skill
    pt = point_set(skill)
    skill_flag = skill_set(skill)
    learn_lv = learn_lv_set(skill)
    ex_flag = ex_flag_set(skill)
    actor = actor_flag_set(skill)
    init = initial_actor_set(skill)
    return [pt, skill_flag, learn_lv, ex_flag, actor, init]
  end
  #--------------------------------------------------------------------------
  # ○ ポイントの設定
  #--------------------------------------------------------------------------
  def self.point_set(skill)
    if skill.note =~ /\<習得可能技:(\d+)\>/
      return $1.to_i
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ 必須スキルの設定
  #--------------------------------------------------------------------------
  def self.skill_set(skill)
    l_skill = []
    skill.note.each_line do |line|
      case line
      when /\<必須技能:(\D+?):Lv(\d+)\>/
        l_skill.push([$1, $2.to_i])
      end
    end
    return l_skill
  end
  #--------------------------------------------------------------------------
  # ○ 習得可能LVの設定
  #--------------------------------------------------------------------------
  def self.learn_lv_set(skill)
    if skill.note =~ /\<習得可能LV:(\d+)\>/
      return $1.to_i
    else
      return 1
    end
  end
  #--------------------------------------------------------------------------
  # ○ 特殊条件の設定
  #--------------------------------------------------------------------------
  def self.ex_flag_set(skill)
    if skill.note =~ /\<習得特殊条件:スイッチ(\d+)\>/
      return $game_switches[$1.to_i]
    elsif skill.note =~ /\<習得特殊条件:変数(\d+)番,(\d+)以上\>/
      return $game_variables[$1.to_i] >= $2.to_i
    elsif skill.note =~ /\<習得アイテム所持判定:(\D+?),(\d+)\>/
      case $1
      when "Weapon"; return $game_party.has_item?($data_weapons[$2.to_i], true)
      when "Armor"; return $game_party.has_item?($data_armors[$2.to_i], true)
      else       ; return $game_party.has_item?($data_items[$2.to_i])
      end
    else
      return true
    end
  end
  #--------------------------------------------------------------------------
  # ○ 習得可能アクターの設定
  #--------------------------------------------------------------------------
  def self.actor_flag_set(skill)
    l_actor = []
    skill.note.each_line do |line|
      case line
      when /\<習得アクター:(\D+?)\>/
        l_actor.push($1)
      end
    end
    return l_actor
  end
  #--------------------------------------------------------------------------
  # ○ 最初からリストに含めるアクターの設定
  #--------------------------------------------------------------------------
  def self.initial_actor_set(skill)
    i_actor = []
    skill.note.each_line do |line|
      case line
      when /\<(\D+?):最初から\>/
        i_actor.push($1)
      end
    end
    return i_actor
  end
  #--------------------------------------------------------------------------
  # ○ レベルアップポイントの取得
  #--------------------------------------------------------------------------
  def self.lvup_point(skill)
    return [0, 0] if !skill
    if skill.note =~ /\<スキルレベルAP:(\d+),(\d+)\>/
      return [$1.to_i, $2.to_i]
    end
  end
end

#==============================================================================
# □ Window_LearnPoint
#------------------------------------------------------------------------------
# 　技習得画面で現在の保有技ポイントと
#   現在選択中の技の習得後のポイントを表示するウィンドウです。
#==============================================================================

class Window_LearnPoint < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(wy)
    super(0, wy, window_width, fitting_height(4))
    @actor = nil
    @point = 0
    @new_point = 0
    @category = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ○ アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    @point = @new_point = @actor.ap
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ポイントの設定
  #--------------------------------------------------------------------------
  def point=(point)
    @point = point
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 技習得後のポイントの設定
  #--------------------------------------------------------------------------
  def set_item_point(point)
    @new_point = @point - point
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 能力値変化の描画色取得 ※オーバーライド
  #--------------------------------------------------------------------------
  def param_change_color(change)
    return power_down_color if change < 0
    return normal_color
  end
  #--------------------------------------------------------------------------
  # ○ ポイントの描画
  #--------------------------------------------------------------------------
  def draw_point_text(point, new_point, x, y)
    change_color(system_color)
    draw_text(x + 320, y + line_height * 0, contents_width, line_height, "#{Vocab::ap}")
    case @category
    when :learn
      draw_text(x + 465, y + line_height * 0, contents_width, line_height, "After")
    when :skillup
      draw_text(x + 465, y + line_height * 0, contents_width, line_height, "After")
    end
    change_color(normal_color)
    draw_text(x - 220, y + line_height * 1, contents_width, line_height, point, 2)
    change_color(param_change_color(new_point))
    draw_text(x + 430, y + line_height * 1, contents_width, line_height, "⇒")
    draw_text(x - 75, y + line_height * 1, contents_width, line_height, new_point, 2)
  end
  #--------------------------------------------------------------------------
  # ○ 習得画面用アクターステータスの描画
  #--------------------------------------------------------------------------
  def draw_actor_learn_st(actor, x, y)
    draw_actor_face(actor, x, 0)
    draw_actor_name(actor, x + 110, y)
    draw_actor_level(actor, x + 110, y + 24)
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_actor_learn_st(@actor, 4, 12) if @actor
    draw_point_text(@point, @new_point, 0, 12)
  end
end

#==============================================================================
# □ Window_LearnList
#------------------------------------------------------------------------------
# 　技習得画面で、習得できるスキルの一覧を表示するウィンドウです。
#==============================================================================

class Window_LearnList < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @actor = nil
    @category = nil
    @not_learn_hide = $game_switches[Learn::HIDE]
    @data = []
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
  # ○ カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ○ 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ○ 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ○ スキルの取得
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # ○ スキル習得ポイントの取得
  #--------------------------------------------------------------------------
  def skill_ap(item)
    Learn.l_flag(item)[0]
  end
  #--------------------------------------------------------------------------
  # ○ 必須スキルを覚えているか？
  #--------------------------------------------------------------------------
  def skill_learn_ok?(item)
    l_skills = Learn.l_flag(item)[1]
    return true if l_skills.empty?
    l_skills.each do |i|
      flag = @actor.skills.any? {|skill| skill.name == i[0] && @actor.skill_lv(skill.id) >= i[1] }
      return false if !flag
    end
  end
  #--------------------------------------------------------------------------
  # ○ 必要レベルに達しているか？
  #--------------------------------------------------------------------------
  def learn_lv_ok?(item)
    @actor.level >= Learn.l_flag(item)[2]
  end
  #--------------------------------------------------------------------------
  # ○ 上記二つの融合
  #--------------------------------------------------------------------------
  def learn_ok?(item)
    learn_lv_ok?(item) && skill_learn_ok?(item)
  end
  #--------------------------------------------------------------------------
  # ○ ハテナ表記フラグ
  #--------------------------------------------------------------------------
  def learn_question?(item)
    !skill_learn_ok?(item)
  end
  #--------------------------------------------------------------------------
  # ○ スキル習得のための特別な条件を満たしているか
  #--------------------------------------------------------------------------
  def ex_flag_ok?(item)
    Learn.l_flag(item)[3]
  end
  #--------------------------------------------------------------------------
  # ○ スキルを習得できるアクターかどうか
  #--------------------------------------------------------------------------
  def actor_ok?(item)
    Learn.l_flag(item)[4].include?(@actor.name) || all_actor?(item)
  end
  #--------------------------------------------------------------------------
  # ○ 最初からリストに含めるか
  #--------------------------------------------------------------------------
  def init_ok?(item)
    Learn.l_flag(item)[5].include?(@actor.name)
  end
  #--------------------------------------------------------------------------
  # ○ 全キャラ習得可能スキルか
  #--------------------------------------------------------------------------
  def all_actor?(item)
    Learn.l_flag(item)[4].empty?
  end
  #--------------------------------------------------------------------------
  # ○ ポイントウィンドウ更新用のポイントの取得
  #--------------------------------------------------------------------------
  def a_point
    @data && index >= 0 && !@actor.skill_learn?(item) ? skill_ap(item) : 0 #@data[index])[0] : nil
  end
  #--------------------------------------------------------------------------
  # ○ 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # ○ スキルをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    unless @not_learn_hide
      return true if init_ok?(item)
      skill_ap(item) > 0 && ex_flag_ok?(item) && actor_ok?(item)
    else
      return true if init_ok?(item) && !@actor.skill_learn?(item)
      skill_ap(item) > 0 && ex_flag_ok?(item) &&
        actor_ok?(item) && !@actor.skill_learn?(item)
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    @actor.ap >= skill_ap(item) && !@actor.skill_learn?(item) && learn_ok?(item) && item
  end
  #--------------------------------------------------------------------------
  # ○ スキルリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    #skills = $game_temp.sss_array
    @data = $game_temp.sss_array.select {|skill| include?(skill) }
    #@data = $data_skills.select {|skill| include?(skill) }
  end
  #--------------------------------------------------------------------------
  # ○ 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index(@actor.last_skill.object) || 0)
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if skill
      rect = item_rect(index)
      rect.width -= 4
      draw_type_name(skill, rect.x, rect.y, enable?(skill))
      draw_learning_level(rect.x, rect.y, skill)
      draw_skill_cost(rect.x, rect.y, skill)
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルの種類と名前の描画
  #--------------------------------------------------------------------------
  def draw_type_name(skill, x, y, enabled = true)
    contents.font.size = 18
    return unless skill
    stype = Vocab::stype_name(skill.stype_id)
    if @actor.skill_learn?(skill)
      enabled = true
      change_color(system_color, enabled)
    else
      change_color(normal_color, enabled)
    end
    draw_text(x, y, 72, line_height, "#{stype}:", 2)
    draw_icon(skill.icon_index, x + 72, y, enabled)
    draw_question(x + 96, y, skill.name, learn_question?(skill))
  end
  #--------------------------------------------------------------------------
  # ○ スキル名の???描画
  #--------------------------------------------------------------------------
  def draw_question(x, y, name, question = true)
    name = name.gsub(/./) {"?"} if question
    draw_text(x, y, contents_width, line_height, name)
  end
  #--------------------------------------------------------------------------
  # ○ スキルの習得可能レベルの描画
  #--------------------------------------------------------------------------
  def draw_learning_level(x, y, skill)
    return unless skill
    return if @actor.skill_learn?(skill)
    lv = Learn.l_flag(skill)[2]
    return if lv == 1
    change_color(normal_color, enable?(skill))
    draw_text(x + 344, y, contents_width, line_height, "LV: #{lv}")
  end
  #--------------------------------------------------------------------------
  # ○ スキルの習得ポイントを描画
  #--------------------------------------------------------------------------
  def draw_skill_cost(x, y, skill)
    if @actor.skill_learn?(skill)
      change_color(system_color)
      draw_text(x - 4, y, contents_width, line_height, "Learned ", 2)
    else
      change_color(normal_color, enable?(skill))
      draw_text(x + 492, y, contents_width, line_height, "#{Vocab::ap}:#{skill_ap(skill)}")
    end
  end
  #--------------------------------------------------------------------------
  # ○ ヘルプテキスト更新 ※ヘルプウィンドウと一緒にポイントウィンドウも更新
  #--------------------------------------------------------------------------
  def update_help
    if learn_question?(item)
      @help_window.set_required(item)
    else
      @help_window.set_item(item)
    end
    @point_window.set_item_point(a_point)
  end
  #--------------------------------------------------------------------------
  # ○ ポイントウィンドウの設定
  #--------------------------------------------------------------------------
  def point_window=(point_window)
    @point_window = point_window
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
=begin
  #--------------------------------------------------------------------------
  # ○ スキル表示のチェンジ
  #--------------------------------------------------------------------------
  def process_hide_change
    Sound.play_cursor
    Input.update
    call_handler(:hide_change)
  end
  #--------------------------------------------------------------------------
  # ○ スキル表示のチェンジ
  #--------------------------------------------------------------------------
  def hide_change
    @not_learn_hide ^= true
    refresh
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ○ 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    super
    if active
      return process_hide_change if handle?(:hide_change) && Input.trigger?(:Z)
    end
  end
=end
end

#==============================================================================
# □ Window_LearnResult
#------------------------------------------------------------------------------
# 　技習得画面で、習得技の確認を表示するウィンドウです。
#==============================================================================

class Window_LearnResult < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @point = nil
    @learn_skill = nil
    @category = nil
    ww = Graphics.width
    super(0, 0, ww, fitting_height(2))
    self.y = Graphics.height / 2 - self.height / 2
    self.z = 300
    self.back_opacity = 255
    self.visible = false
    self.arrows_visible = false
  end
  #--------------------------------------------------------------------------
  # ○ カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    self.width = window_width
    self.x = Graphics.width / 2 - self.width / 2
    draw_skill_name(@learn_skill, @point, 0, 0)
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の設定
  #--------------------------------------------------------------------------
  def window_width
    if @category == :learn
      @learn_skill ? [@learn_skill.name.size * 24 + 24 + 168, 264].max : Graphics.width
    else
      @learn_skill ? [@learn_skill.name.size * 24 + 24 + 264, 360].max : Graphics.width
    end
  end
  #--------------------------------------------------------------------------
  # ○ 習得スキルの設定
  #--------------------------------------------------------------------------
  def learn_skill=(learn_skill)
    @learn_skill = learn_skill
  end
  #--------------------------------------------------------------------------
  # ○ スキルポイントの設定
  #--------------------------------------------------------------------------
  def point=(point)
    @point = point
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 習得技名の描画
  #--------------------------------------------------------------------------
  def draw_skill_name(skill, point, x, y)
    return unless skill && point
    text_size = skill.name.size
    result = @category == :learn ? "Learn?":"Lvアップさせますか"
    change_color(normal_color)
    draw_text(x + 4, y, contents_width, line_height, "#{Vocab::ap} #{point} Consume")
    draw_icon(skill.icon_index, x + 12, y + line_height)
    draw_text(x + 36, y + line_height, text_size * 20, line_height, skill.name)
    draw_text(x - 4, y + line_height, contents_width, line_height, "#{result}", 2)
  end
end

#==============================================================================
# □ Window_YesNoChoice
#------------------------------------------------------------------------------
# 　"はい"か"いいえ"を選択するウィンドウです。
#==============================================================================

class Window_YesNoChoice < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    self.x = Graphics.width / 2 - self.width / 2
    self.visible = false
    self.back_opacity = 255
    self.z = 300
    deactivate
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 4
  end
  #--------------------------------------------------------------------------
  # ○ 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ○ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Yes",     :yes_select)
    add_command("No",   :no_select)
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
# ■ Window_Help
#------------------------------------------------------------------------------
# 　スキルやアイテムの説明、アクターのステータスなどを表示するウィンドウです。
#==============================================================================

class Window_Help < Window_Base
  def set_required(item)
    return unless item
    skills = Learn.l_flag(item)[1]
    if skills.empty?
      set_text("No Skills Required")
    else
      text = ""
      skills.each_with_index do |skill, i|
        text += "\n　　　　　　" if i == 2
        star = ""
        (skill[1] - 1).times {star += "★"}
        text += "#{skill[0]}" + star + "　"
      end
      set_text("Required: #{text}")
    end
  end
end

class RPG::BaseItem
  def skill_book?
    self.note.include?("<スキルブック>")
  end
end

