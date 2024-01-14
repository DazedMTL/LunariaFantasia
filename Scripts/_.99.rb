#==============================================================================
# ■ Window_ItemCategory
#------------------------------------------------------------------------------
# 　アイテム画面またはショップ画面で、通常アイテムや装備品の分類を選択するウィ
# ンドウです。
#==============================================================================

class Window_LearnCategory < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :item_window
  attr_reader   :point_window
  attr_reader   :result_window
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
    @point_window.category = current_symbol if @point_window
    @result_window.category = current_symbol if @result_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Learn",     :learn)
    add_command(Vocab::skillup,   :skillup)
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def item_window=(item_window)
    @item_window = item_window
    update
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def point_window=(point_window)
    @point_window = point_window
    update
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def result_window=(result_window)
    @result_window = result_window
    update
  end
end

#==============================================================================
# □ Window_LearnList
#------------------------------------------------------------------------------
# 　スキルアップ画面で、アップできるスキルの一覧を表示するウィンドウです。
#==============================================================================

class Window_SkillUpList < Window_LearnList
  #--------------------------------------------------------------------------
  # ○ スキルアップポイントの基礎値の取得
  #--------------------------------------------------------------------------
  def base_p(item)
    Learn.lvup_point(item)[0]
  end
  #--------------------------------------------------------------------------
  # ○ スキルアップポイントの上昇値の取得
  #--------------------------------------------------------------------------
  def up_p(item)
    Learn.lvup_point(item)[1]
  end
  #--------------------------------------------------------------------------
  # ○ 現在のスキルレベルの取得
  #--------------------------------------------------------------------------
  def s_lv_now(item)
    return 1 if !item
    @actor.skill_lv(item.id)
  end
  #--------------------------------------------------------------------------
  # ○ レベルアップに必要なポイントの取得
  #--------------------------------------------------------------------------
  def levelup_point(item)
    base_p(item) + up_p(item) * (s_lv_now(item) - 1)
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルがマックスか
  #--------------------------------------------------------------------------
  def lv_max?(item)
    return false if !item
    @actor.skill_lv(item.id) == Learn::S_LV_MAX
  end
  #--------------------------------------------------------------------------
  # ○ ポイントウィンドウ更新用のポイントの取得
  #--------------------------------------------------------------------------
  def a_point
    if @category == :skillup
      @data && index >= 0 && !lv_max?(item) ? levelup_point(item) : 0
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    if @category == :skillup
      unless @not_learn_hide
        item.lvup_able?
      else
        item.lvup_able? && !lv_max?(item)
      end
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    if @category == :skillup
      item && !lv_max?(item) && @actor.ap >= levelup_point(item)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    if @category == :skillup
      skills = $game_temp.sss_array.select {|skill| @actor.skill_learn?(skill) }
      #skills = []
      #@actor.added_skill_types.sort.each do |stype|
        #skills += @actor.skills.select {|skill| skill && skill.stype_id == stype }
      #end
      @data = skills.select {|skill| include?(skill) } #$data_skills.select {|skill| include?(skill) }
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ○ 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select(0)#@data.index(@actor.last_skill.object) || 0)
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    if @category == :skillup
      skill = @data[index]
      if skill
        rect = item_rect(index)
        rect.width -= 4
        draw_type_name(skill, rect.x, rect.y, enable?(skill))
        draw_skill_level(skill, rect.x, rect.y, enable?(skill))
        draw_skill_cost(rect.x, rect.y, skill)
      end
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルの種類と名前の描画
  #--------------------------------------------------------------------------
  def draw_type_name(skill, x, y, enabled = true)
    if @category == :skillup
      return unless skill
      stype = Vocab::stype_name(skill.stype_id)
      change_color(normal_color, enabled)
      if lv_max?(skill)
        enabled = true
        change_color(system_color, enabled)
      end
      draw_text(x, y, 72, line_height, "#{stype}:", 2)
      draw_icon(skill.icon_index, x + 72, y, enabled)
      draw_text(x + 96, y, contents_width, line_height, skill.name)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルレベルの描画
  #--------------------------------------------------------------------------
  def draw_skill_level(skill, x, y, enabled = true)
    return unless skill
    change_color(normal_color, enabled)
    if lv_max?(skill)
      enabled = true
      change_color(system_color, enabled)
    end
    star = ""
    @actor.skill_lv(skill.id).times do |i|
      star += "★" unless i == 0
    end
    draw_text(x + 336, y, contents_width, line_height, "Skill LV:#{star}")
  end
  #--------------------------------------------------------------------------
  # ○ スキルの必要APを描画
  #--------------------------------------------------------------------------
  def draw_skill_cost(x, y, skill)
    if @category == :skillup
      if lv_max?(skill)
        change_color(system_color)
        draw_text(x - 4, y, contents_width, line_height, "----　", 2)
      else
        change_color(normal_color, enable?(skill))
        draw_text(x + 492, y, contents_width, line_height, "Need#{Vocab::ap}:#{levelup_point(skill)}")
      end
    else
      super
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
  # ○ 
  #--------------------------------------------------------------------------
  def sss_array
    @stype_sort_skills ||= sss_set
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def sss_set
    skills = {}
    sss = []
    $data_system.skill_types.size.times do |i|
      next if i == 0
      skills[i] = $data_skills.select {|skill| skill && skill.stype_id == i && !skill.nameless? && !skill.learn_omit }
      skills[i] = skills_sort(skills[i])
    end
    skills.each_value {|v| sss += v }
    return sss
    #skills = []
    #$data_system.skill_types.size.times do |i|
      #next if i == 0
      #skills += $data_skills.select {|skill| skill && skill.stype_id == i && !skill.nameless? && !skill.learn_omit }
    #end
    #return skills
  end
  #--------------------------------------------------------------------------
  # 〇 スキルソート
  #--------------------------------------------------------------------------
  def skills_sort(skills)
    skills.sort_by {|skill| [skill.category_id, skill.id] }
  end
end

class RPG::BaseItem
  def nameless?
    @name == "" || @name == "--------------------"
  end
end

class RPG::Skill < RPG::UsableItem
  def learn_omit
    self.note.include?("<習得除外>")
  end
end

