#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットの戦闘前セット # 再定義
  #--------------------------------------------------------------------------
  alias over_summon_summon_actor_set summon_actor_set
  def summon_actor_set
    if $game_switches[SummonSystem::SUMMON_OVER_SWITCH]
      @summon_members.each do |actor_id|
        summon_actor(actor_id) if actor_id #&& members.size < max_battle_members # ※補欠メンバーが入らないように設定
      end
    else
      over_summon_summon_actor_set
    end
  end
  #--------------------------------------------------------------------------
  # ○ 控えメンバーの取得
  #--------------------------------------------------------------------------
  def waiting_members
    all_members[max_battle_members, all_members.size - max_battle_members].select {|actor| actor.exist? }
  end
  #--------------------------------------------------------------------------
  # ○ 人間メンバーの取得
  #--------------------------------------------------------------------------
  def actor_members
    members.select {|actor| actor.exist? && !actor.summon_type? }
  end
  #--------------------------------------------------------------------------
  # ○ 召喚ユニットを加える ※スキル発動用
  #--------------------------------------------------------------------------
  alias waiting_summon_actor_skill summon_actor_skill
  def summon_actor_skill(actor_id, level = $game_actors[1].level)
    if $game_switches[SummonSystem::SUMMON_OVER_SWITCH]
      change = $game_temp.remove_reserve ? $game_temp.remove_reserve : summon_members_top
      change_index = change && summon_max? ? @actors.index(change.id) : nil
      summon_members_change(change) if summon_max? #($game_party.summon_members_size == $game_variables[SummonSystem::S_N_ID] || $game_party.members.size == $game_party.max_battle_members) && $game_variables[SummonSystem::S_N_ID] > 0
      $game_actors[actor_id].summon_level_set(level)#$game_actors[1].level)
      $game_actors[actor_id].last_actor_command = 0 #XPスタイルバトルあわせ　召喚と同時にアクターコマンドのカーソル記憶をリセット
      $game_actors[actor_id].on_battle_start # 戦闘開始時の処理
      if change_index
        @actors[change_index,0] = actor_id if !@actors.include?(actor_id) #@actors.push(actor_id) if !@actors.include?(actor_id)
      else
        @actors.push(actor_id) if !@actors.include?(actor_id) #@actors.push(actor_id) if !@actors.include?(actor_id)
      end
      @summon_able.delete(actor_id) # 召喚可能ユニット配列のアクターIDを削除
      $game_player.refresh
      $game_map.need_refresh = true
      $game_temp.remove_reserve_reset
    else
      waiting_summon_actor_skill(actor_id, level)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 召喚限界数か
  #--------------------------------------------------------------------------
  alias waiting_summon_max? summon_max?
  def summon_max?
    if $game_switches[SummonSystem::SUMMON_OVER_SWITCH]
      summon_members_size == summon_number && summon_number > 0
    else
      waiting_summon_max?
    end
  end
  #--------------------------------------------------------------------------
  # ○ 召喚可能数を超えたユニットの削除
  #--------------------------------------------------------------------------
  alias waiting_summon_number_check summon_number_check
  def summon_number_check
    if $game_switches[SummonSystem::SUMMON_OVER_SWITCH]
      num = [(SummonSystem::SUMMON_SLOT - summon_number), 0].max
      num.times {|i| @summon_members[2 - i] = nil }
    else
      waiting_summon_number_check
    end
  end
  #--------------------------------------------------------------------------
  # ● 順序入れ替え
  #--------------------------------------------------------------------------
  def swap_order(index1, index2)
    @actors[index1], @actors[index2] = @actors[index2], @actors[index1]
    $game_player.refresh
  end
end

#==============================================================================
# □ Window_SummonSlot
#------------------------------------------------------------------------------
# 　サーヴァント画面で、アクターが現在セットしているサーヴァントを表示するウィンドウです。
#==============================================================================

class Window_SummonSlot < Window_ItemList
  #--------------------------------------------------------------------------
  # ○ 定員オーバーじゃないか
  #--------------------------------------------------------------------------
  alias summon_over_max_member? max_member?
  def max_member?(index)
    if $game_switches[SummonSystem::SUMMON_OVER_SWITCH]
      true
    else
      summon_over_max_member?(index)
    end
  end
end



#==============================================================================
# □ Window_BattleServant
#------------------------------------------------------------------------------
# 　戦闘画面で戦闘参加中のサーヴァントを表示するコマンドウィンドウです。
#==============================================================================

class Window_BattleServant < Window_Command
  #--------------------------------------------------------------------------
  # 〇 公開インスタンス変数
  #--------------------------------------------------------------------------
  #attr_reader   :change_window
  #--------------------------------------------------------------------------
  # 〇 オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, waiting = false)
    super(x, y)
    @waiting = waiting
    unselect
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # 〇 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    2#[2, item_max].min
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_servant_members
  end
  #--------------------------------------------------------------------------
  # 〇 主要コマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_servant_members
    if @waiting
      $game_party.waiting_members.each {|member| add_command(member.name,   :ok, true, member) if include?(member) }
    else
      $game_party.battle_members.each {|member| add_command(member.name,   :ok, true, member) if include?(member) }
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return item.summon_type?
  end
  #--------------------------------------------------------------------------
  # 〇 ウィンドウの設定
  #--------------------------------------------------------------------------
  #def change_window=(change_window)
    #@change_window = change_window
    #update
  #end
  #--------------------------------------------------------------------------
  # 〇 フレーム更新
  #--------------------------------------------------------------------------
  #def update
    #super
    #@change_window.actor = current_ext if @change_window
  #end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    #if SceneManager.scene_is?(Scene_Battle)
      #change_color(normal_color, command_enabled?(index))
    #elsif $game_party.summon_members.include?(@list[index][:ext].id) || $game_party.members.include?(@list[index][:ext])
      #change_color(important_color, command_enabled?(index))
    #else
      #change_color(normal_color, command_enabled?(index))
    #end
    change_color(normal_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  #def battle_member?(index)
    #return false if SceneManager.scene_is?(Scene_Battle)
    #return $game_party.summon_members.include?(@list[index][:ext].id) || $game_party.members.include?(@list[index][:ext])
  #end
end

#==============================================================================
# ■ Window_PartyCommand
#==============================================================================
class Window_PartyCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  alias sv_change_make_command_list make_command_list
  def make_command_list
    sv_change_make_command_list
    add_command("交替",   :sv_change, $game_party.all_members.size > 4) if $game_switches[SummonSystem::SUMMON_OVER_SWITCH]
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
  alias sv_create_all_windows create_all_windows
  def create_all_windows
    sv_create_all_windows
    create_battle_servant_window
    create_waiting_servant_window
  end
  #--------------------------------------------------------------------------
  # ● パーティコマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias sv_create_party_command_window create_party_command_window
  def create_party_command_window
    sv_create_party_command_window
    @party_command_window.set_handler(:sv_change,   method(:command_waiting))
  end
  #--------------------------------------------------------------------------
  # 〇 戦闘サーヴァントウィンドウの作成
  #--------------------------------------------------------------------------
  def create_battle_servant_window
    x = Graphics.width / 2 - (160 + 160) / 2
    y = @party_command_window.height
    @battle_servant_window = Window_BattleServant.new(x, y)
    @battle_servant_window.set_handler(:ok,  method(:waiting_select))
    @battle_servant_window.set_handler(:cancel, method(:return_pc))
    @battle_servant_window.deactivate
    @battle_servant_window.hide
  end
  #--------------------------------------------------------------------------
  # 〇 控えサーヴァントウィンドウの作成
  #--------------------------------------------------------------------------
  def create_waiting_servant_window
    y = @battle_servant_window.y
    x = @battle_servant_window.x + @battle_servant_window.width
    @waiting_servant_window = Window_BattleServant.new(x, y, true)
    @waiting_servant_window.set_handler(:ok,  method(:on_waiting_ok))
    @waiting_servant_window.set_handler(:cancel, method(:on_waiting_cancel))
    @waiting_servant_window.deactivate
    @waiting_servant_window.hide
  end
  #--------------------------------------------------------------------------
  # 〇 交替選択開始
  #--------------------------------------------------------------------------
  def command_waiting
    @waiting_servant_window.refresh
    @waiting_servant_window.show
    @battle_servant_window.refresh
    @battle_servant_window.show.activate
    @battle_servant_window.select(0)
  end
  #--------------------------------------------------------------------------
  # 〇 交替キャラ選択
  #--------------------------------------------------------------------------
  def waiting_select
    @waiting_servant_window.activate
    @waiting_servant_window.select(0)
  end
  #--------------------------------------------------------------------------
  # 〇 交替［決定］
  #--------------------------------------------------------------------------
  def on_waiting_ok
    $game_party.swap_order(@battle_servant_window.index + $game_party.actor_members.size,
                           @waiting_servant_window.index + $game_party.battle_members.size)
    @waiting_servant_window.refresh
    @waiting_servant_window.unselect
    @battle_servant_window.refresh
    @battle_servant_window.activate
    $game_party.make_actions
  end
  #--------------------------------------------------------------------------
  # 〇 交替［キャンセル］
  #--------------------------------------------------------------------------
  def on_waiting_cancel
    @waiting_servant_window.unselect
    @waiting_servant_window.deactivate
    @battle_servant_window.activate
  end
  #--------------------------------------------------------------------------
  # 〇 パーティコマンド選択へ戻る
  #--------------------------------------------------------------------------
  alias sv_change_return_pc return_pc
  def return_pc
    if @tactics_window.visible
      sv_change_return_pc
    else
      @waiting_servant_window.hide
      @battle_servant_window.hide
      @battle_servant_window.unselect
      @party_command_window.activate
    end
  end
end

=begin
#==============================================================================
# ■ Window_BattleLog
#------------------------------------------------------------------------------
# 　戦闘の進行を実況表示するウィンドウです。枠は表示しませんが、便宜上ウィンド
# ウとして扱います。
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● ステート付加の表示　※エイリアス
  #--------------------------------------------------------------------------
  alias spare_display_added_states display_added_states
  def display_added_states(target)
    spare_display_added_states(target)
    if $game_party.members.size < 4 && !$game_party.spare.empty?
      $game_party.spare.each do |s|
        $game_party.add_actor(s) if $game_party.members.size < 4
      end
    end
  end
end
=end
