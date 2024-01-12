#==============================================================================
# ■ Window_MenuActor
#------------------------------------------------------------------------------
# 　アイテムやスキルの使用対象となるアクターを選択するウィンドウです。
#==============================================================================

class Window_SummonList_Heal < Window_SummonList
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, Graphics.height)
  end
  #--------------------------------------------------------------------------
  # ● 項目の高さを取得
  #--------------------------------------------------------------------------
  def item_height
    (height - standard_padding * 2) / 4
  end
  #--------------------------------------------------------------------------
  # ● シンプルなステータスの描画
  #--------------------------------------------------------------------------
  def draw_summon_actor_simple_status(actor, x, y, item)
    draw_actor_face(actor, x + 96, y + 8, enable?(item))
    draw_actor_name(actor, x, y)
    draw_actor_class(actor, x, y + line_height * 1)
    draw_actor_level(actor, x, y + line_height * 2)
    draw_actor_hp(actor, x + 200, y + line_height * 1 + 8)
    draw_actor_mp(actor, x + 200, y + line_height * 2 + 8)
    draw_actor_tp(actor, x + 200, y + line_height * 3 + 8)
  end
  #--------------------------------------------------------------------------
  # ○ アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false unless item.is_a?(RPG::Skill)
    #return false if $game_party.summon_members.include?(item.summon_unit_id)
    return item.stype_id == SummonSystem::S_S_ID
  end
  #--------------------------------------------------------------------------
  # ○ アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_actors[1].skills.select {|item| include?(item) }
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def summon_actor_all
    @data.collect{|skill| summon_actor(skill) }
  end
  #--------------------------------------------------------------------------
  # ○ アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    return true
  end
  #--------------------------------------------------------------------------
  # ○ Xボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_x
  end
  #--------------------------------------------------------------------------
  # ○ Yボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_y
  end
  #--------------------------------------------------------------------------
  # ○ Zのハンドリング処理の追加
  #--------------------------------------------------------------------------
  def z_enabled?
    false
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    #$game_party.target_actor = $game_party.members[index] unless @cursor_all
    call_ok_handler
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select(0) #select($game_party.target_actor.index || 0)
  end
  #--------------------------------------------------------------------------
  # ● アイテムのためのカーソル位置設定
  #--------------------------------------------------------------------------
  def select_for_item(item)
    @cursor_fix = item.for_user?
    @cursor_all = item.for_all?
    if @cursor_fix
      select_last#($game_party.menu_actor.index)
    elsif @cursor_all
      select(0)
    else
      select_last
    end
  end
end


#==============================================================================
# □ Window_ItemStatus
#------------------------------------------------------------------------------
# 　アイテム画面で、アイテムの能力値を表示するウィンドウです。
#==============================================================================

class Window_ItemStatus_SV < Window_ItemStatus
  #--------------------------------------------------------------------------
  # ○ サーヴァントウィンドウの設定
  #--------------------------------------------------------------------------
  def servant_window=(servant_window)
    @servant_window = servant_window
    update
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの変更トリガー
  #--------------------------------------------------------------------------
  def window_change
    #Input.trigger?(:Z) && !@actor_window.visible && !@servant_window.visible && @category_window.close?
    super && !@servant_window.visible
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの非表示化設定
  #--------------------------------------------------------------------------
  def window_off
    if @actor_window && @category_window && @servant_window
      self.visible = false if !@category_window.close?
      self.visible = false if @actor_window.visible
      self.visible = false if @servant_window.visible
    end
  end
end


#==============================================================================
# ■ Window_ItemList
#------------------------------------------------------------------------------
# 　アイテム画面で、所持アイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか　※エイリアス
  #--------------------------------------------------------------------------
  alias sv_heal_enable? enable?
  def enable?(item)
    if note_check(item, SummonSystem::HEAL_ITEM)#item.note.include?(TelepoMap::TELEPO)
      sv_heal_enable?(item) && !$game_party.summon_prohibit
    else
      sv_heal_enable?(item)
    end
  end
end


#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　アイテム画面の処理を行うクラスです。
#==============================================================================

class Scene_Item < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 開始処理　※テレポートの項目で設定
  #--------------------------------------------------------------------------
  #alias sv_heal_start start
  #def start
    #sv_heal_start
    #create_servant_window
  #end
  #--------------------------------------------------------------------------
  # ○ サーヴァントウィンドウの作成
  #--------------------------------------------------------------------------
  def create_servant_window
    @servant_window = Window_SummonList_Heal.new
    @servant_window.set_handler(:ok,     method(:on_servant_ok))
    @servant_window.set_handler(:cancel, method(:on_servant_cancel))
    @item_status_window.servant_window = @servant_window
  end
  #--------------------------------------------------------------------------
  # ○ アイテムステータスウィンドウの作成 ※オリジナルの再定義
  #--------------------------------------------------------------------------
  def create_item_status_window
    wy = @help_window.height
    wh = Graphics.height - wy
    @item_status_window = Window_ItemStatus_SV.new(0, wy, Graphics.width / 2, wh)
    @item_status_window.category_window = @category_window
    @item_status_window.actor_window = @actor_window
    @item_window.item_status_window = @item_status_window
  end
end  
  

#==============================================================================
# ■ Scene_ItemBase
#------------------------------------------------------------------------------
# 　アイテム画面とスキル画面の共通処理を行うクラスです。
#==============================================================================

class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ○ サーヴァント［決定］
  #--------------------------------------------------------------------------
  def on_servant_ok
    if item_usable_servant?
      use_item_servant
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ○ サーヴァント［キャンセル］
  #--------------------------------------------------------------------------
  def on_servant_cancel
    hide_sub_window(@servant_window)
  end
  #--------------------------------------------------------------------------
  # ● アイテムの決定
  #--------------------------------------------------------------------------
  alias sv_heal_determine_item determine_item
  def determine_item
    if item.note.include?(SummonSystem::HEAL_ITEM)
      show_sub_window(@servant_window)
      @servant_window.select_for_item(item)
    else
      sv_heal_determine_item
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムの使用対象となるサーヴァントを配列で取得
  #--------------------------------------------------------------------------
  def item_target_servants(window)
    if !item.for_friend?
      []
    elsif item.for_all?
      window.summon_actor_all
    else
      [window.summon_actor(window.item)]
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムの使用可能判定　サーヴァント
  #--------------------------------------------------------------------------
  def item_usable_servant?
    user.usable?(item) && item_effects_valid_sv?
  end
  #--------------------------------------------------------------------------
  # ○ アイテムの効果がサーヴァントに有効かを判定
  #--------------------------------------------------------------------------
  def item_effects_valid_sv?
    item_target_servants(@servant_window).any? do |target|
      target.item_test(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムをサーヴァントに対して使用
  #--------------------------------------------------------------------------
  def use_item_to_servants
    item_target_servants(@servant_window).each do |target|
      item.repeats.times { target.item_apply(user, item) }
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムの使用 サーヴァント
  #--------------------------------------------------------------------------
  def use_item_servant
    play_se_for_item
    user.use_item(item)
    use_item_to_servants
    check_common_event
    check_gameover
    @servant_window.refresh
    @item_window.redraw_current_item
  end
end
