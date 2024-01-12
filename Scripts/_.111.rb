#==============================================================================
# □ Window_Teleport
#------------------------------------------------------------------------------
# 　テレポート選択画面で、移動先の一覧を表示するウィンドウです。
#==============================================================================

class Window_Teleport < Window_Selectable
  include FRZB
  #--------------------------------------------------------------------------
  # ○ Zのハンドリング処理の追加
  #--------------------------------------------------------------------------
  def process_handling
    super
    return unless open? && active
    return process_z if z_enabled? && Input.trigger?(:Z)
  end
  #--------------------------------------------------------------------------
  # ○ 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def ex_current_item_enabled?
    SceneManager.scene_is?(Scene_QuickTeleport)
  end
end

#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● シーン遷移に関連する更新
  #--------------------------------------------------------------------------
  alias quick_telepo_update_scene update_scene
  def update_scene
    quick_telepo_update_scene
    update_call_telepo unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # ○ 特定ボタンによるクイックテレポ判定
  #--------------------------------------------------------------------------
  def update_call_telepo
    return if call_disabled
    call_telepo if Input.trigger?(:Y)
  end
  #--------------------------------------------------------------------------
  # ○ クイックテレポの実行
  #--------------------------------------------------------------------------
  def call_telepo
    ts = telepo_select
    #user = ts[0]
    #item = ts[1]
    if $game_party.telepo_ok? && !ts.empty? #item
      Sound.play_ok
      #SceneManager.telepo_call(Scene_QuickTeleport, user, item)
      SceneManager.q_telepo_call(Scene_QuickTeleport, ts.keys[0], ts.values[0], ts)
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ○ クイックテレポ用アイテムの選別
  #--------------------------------------------------------------------------
=begin
  def telepo_select
    user1 = $game_actors[1]
    u1_skills = user1.usable_skills.select {|skill| skill.note.include?(TelepoMap::TELEPO)}
    u_s = [user1, u1_skills[0]]
    if $game_party.members.include?($game_actors[3])
      user2 = $game_actors[3]
      u2_skills = user2.usable_skills.select {|skill| skill.note.include?(TelepoMap::TELEPO)}
      u_s = [user2, u2_skills[0]] if u2_skills[0]
    end
    user = u_s[0]
    item = u_s[1]
    unless item
      items = $game_party.items.select {|i| i.note.include?(TelepoMap::TELEPO) }
      item = items[0]
    end
    return [user, item]
  end
=end
  #--------------------------------------------------------------------------
  # ○ クイックテレポ用アイテムの選別
  #--------------------------------------------------------------------------
  def telepo_select
    ary = {}
    if $game_party.members.include?($game_actors[3])
      user2 = $game_actors[3]
      u2_skills = user2.usable_skills.select {|skill| skill.note.include?(TelepoMap::TELEPO)}
      ary[user2] = u2_skills[0] if u2_skills[0]
    end
    user1 = $game_actors[1]
    u1_skills = user1.usable_skills.select {|skill| skill.note.include?(TelepoMap::TELEPO)}
    ary[user1] = u1_skills[0] if u1_skills[0]
    items = $game_party.items.select {|i| i.note.include?(TelepoMap::TELEPO) }
    ary["item"] = items[0] if items[0]
    return ary
  end
end

#==============================================================================
# □ Scene_Teleport
#------------------------------------------------------------------------------
# 　テレポート場所の選択・決定を行うクラスです。
#==============================================================================

class Scene_QuickTeleport < Scene_Teleport
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(user, item, ts)
    @item = item
    @user = user.is_a?(String) ? $game_party.leader : user
    @ts = ts
    @ts_key = ts.keys
    @index = 0
  end
  #--------------------------------------------------------------------------
  # ○ 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_skill_window
  end
  #--------------------------------------------------------------------------
  # ○ テレポ使用スキルウィンドウの作成
  #--------------------------------------------------------------------------
  def create_skill_window
    @skill_window = Window_TeleportSkill.new(@user, @item, @telepo_window.width)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def next_item
    @index += 1
    @index = 0 if @index >= @ts.size
    @user = @ts_key[@index]
    @item = @ts[@user]
    @user = $game_party.leader if @user.is_a?(String)
  end
  #--------------------------------------------------------------------------
  # ★ 呼び出し元のシーンへ戻る　※オーバーライド
  #     もし戻るシーンがアイテム画面及びスキル画面なら専用のリターンプロセスを行う
  #     処理は SceneManagerプラス に記述
  #--------------------------------------------------------------------------
  def return_scene
    SceneManager.return
  end
  #--------------------------------------------------------------------------
  # ○ テレポウィンドウの作成
  #--------------------------------------------------------------------------
  def create_telepo_window
    super
    @telepo_window.set_handler(:z_change, method(:change_item))
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def change_item
    next_item
    @skill_window.next_item(@user, @item)
    @telepo_window.activate
  end
end

#==============================================================================
# ■ SceneManager
#------------------------------------------------------------------------------
# 　シーン遷移を管理するモジュール　※追加分
#==============================================================================

module SceneManager
  #--------------------------------------------------------------------------
  # ○ テレポート専用呼び出し　※使用者とアイテムを引数に渡してシーン移動
  #--------------------------------------------------------------------------
  def self.q_telepo_call(scene_class, user, item, ts_hash)
    @stack.push(@scene)
    @scene = scene_class.new(user, item, ts_hash)
  end
end

#==============================================================================
# □ Window_Teleport
#------------------------------------------------------------------------------
# 　テレポート選択画面で、移動先の一覧を表示するウィンドウです。
#==============================================================================

class Window_TeleportSkill < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(user, item, wx)
    super(wx, 0, window_width, window_height)
    @user = user
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ横幅
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ縦幅
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(3)
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item
    rect1 = Rect.new(0, 0, contents.width, line_height)
    rect2 = Rect.new(0, line_height, contents.width, line_height)
    change_color(system_color)
    draw_text(rect1.x + 4, rect1.y, rect1.width, rect1.height, "使用")
    fs = contents.font.clone
    contents.font.size = 20
    draw_text(0, line_height * 2, contents.width, line_height, "#{key_button("D")}で転移手段の切替", 1)
    contents.font = fs
    change_color(normal_color)
    draw_text(rect1.x + 52, rect1.y, rect1.width, rect1.height, @user.name) if @item.is_a?(RPG::Skill)
    draw_item_name(@item, rect2.x + 64, rect2.y)
    draw_item_number(rect2, @item) if @item.is_a?(RPG::Item)
  end
  #--------------------------------------------------------------------------
  # ● アイテムの個数を描画
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    draw_text(rect.x, rect.y, rect.width - 72, rect.height, sprintf(":%2d", $game_party.item_number(item)), 2)
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_item
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def next_item(user, item)
    @user = user
    @item = item
    refresh
  end
end
