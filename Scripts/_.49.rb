module FAKEREAL
  GUTS = {
           50 => 53,
           100 => 54,
           }
end

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor     :guts                     # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias guts_initialize initialize
  def initialize
    guts_initialize
    @guts = 0
  end
  #--------------------------------------------------------------------------
  # ● 戦闘開始処理　※エイリアス
  #--------------------------------------------------------------------------
  alias guts_on_battle_start on_battle_start
  def on_battle_start
    guts_on_battle_start
    guts_set
  end
  #--------------------------------------------------------------------------
  # ● 戦闘終了処理　※エイリアス
  #--------------------------------------------------------------------------
  alias guts_on_battle_end on_battle_end
  def on_battle_end
    @guts = 0
    guts_on_battle_end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの効果適用　※エイリアス
  #    行動前に死亡した場合、死亡ターンに行動しなくなるのを防ぐため@actionsを
  #    複製しガッツ実行メソッドに引き渡し
  #--------------------------------------------------------------------------
  alias guts_item_apply item_apply
  def item_apply(user, item)
    if @guts > 0
      before = @actions.clone
      guts_item_apply(user, item)
      execute_guts(before) if dead?
    else
      guts_item_apply(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # 〇 根性ステートをセット
  #--------------------------------------------------------------------------
  def add_guts
    # 同じ場所で戦った場合、根性ステートが付加されない為
    FAKEREAL::GUTS.each_value do |id|
      @result.removed_states.delete(id)
    end
    add_state(FAKEREAL::GUTS[@guts]) if @guts > 0
  end
  #--------------------------------------------------------------------------
  # ○ ガッツ時の回復数値のセットアップ
  #--------------------------------------------------------------------------
  def guts_set
    @guts = guts_select
    add_guts
  end
  #--------------------------------------------------------------------------
  # ○ ガッツ時の回復数値の選定
  #--------------------------------------------------------------------------
  def guts_select
    guts = []
    return 0 if enemy? #エネミーは復活しない
    full_equip.each {|equip| guts.push($1.to_i) if equip.note =~ /\<ガッツ:(\d+)\>/}
    guts.sort! {|a, b| b - a }
    return 0 if guts.empty?
    return guts[0]
  end
  #--------------------------------------------------------------------------
  # ○ ガッツ　一度だけ戦闘不能から自動で立ち上がることが出来る
  #    action ; そのターンに行動予定だった内容
  #--------------------------------------------------------------------------
  def execute_guts(action)
    remove_state(death_state_id)
    #@hp = (mhp * 0.01 * @guts).to_i
    self.hp = (mhp * @guts / 100).to_i
    #@guts = 0
    @actions = action
    Sound.play_recovery
  end
end


#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 戦闘不能になる
  #--------------------------------------------------------------------------
  def die
    if @guts == 0
      super
      no_guts_die
    else
      guts_die
    end
  end
  #--------------------------------------------------------------------------
  # ○ ガッツ有りの戦闘不能　※ステート・バフデバフはそのまま継続
  #--------------------------------------------------------------------------
  def guts_die
    @hp = 0
    FAKEREAL::GUTS.each_value{|id| remove_state(id) }
  end
  #--------------------------------------------------------------------------
  # ○ ガッツ無しの戦闘不能　※通常アクターは何もせずGame_Servantで設定
  #--------------------------------------------------------------------------
  def no_guts_die
  end
  #--------------------------------------------------------------------------
  # ○ 新しいステートの付加
  #--------------------------------------------------------------------------
  def add_new_state(state_id)
    # 付加されるステート戦闘不能かつ自動復活が有効の場合
    if state_id == death_state_id && @guts != 0
      die if state_id == death_state_id
      @states.push(state_id)
      # 行動制約によるステート解除を無効
      #on_restrict if restriction > 0
      sort_states
      refresh
    else
      super
    end
  end
end

#==============================================================================
# ■ Window_BattleLog
#------------------------------------------------------------------------------
# 　戦闘の進行を実況表示するウィンドウです。枠は表示しませんが、便宜上ウィンド
# ウとして扱います。
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● ステート付加の表示　※再定義
  #--------------------------------------------------------------------------
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      target.perform_collapse_effect if state.id == target.death_state_id && !(target.guts > 0)
      next if state_msg.empty?
      if state.id == target.death_state_id && target.guts > 0
        
      else
        replace_text(target.name + state_msg)
        wait
      end
      wait_for_effect
    end
  end
  #--------------------------------------------------------------------------
  # ● ステート解除の表示　※再定義
  #--------------------------------------------------------------------------
  def display_removed_states(target)
    target.result.removed_state_objects.each do |state|
      next if state.message4.empty?
      if state.id == target.death_state_id && target.guts > 0
        replace_text(target.name + "は踏みとどまった！")
        target.guts = 0
        wait
      else
        replace_text(target.name + state.message4)
        wait
      end
    end
  end
end
