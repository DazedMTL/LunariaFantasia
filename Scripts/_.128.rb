module SummonSystem
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  BREAK_SKILL = 400             # 退場コマンドスキルID
  
end
#==============================================================================
# ■ Game_Action
#------------------------------------------------------------------------------
# 　戦闘行動を扱うクラスです。このクラスは Game_Battler クラスの内部で使用され
# ます。
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # ○ 退場コマンドを設定
  #--------------------------------------------------------------------------
  def set_break
    set_skill(subject.break_skill_id)
    self
  end
end

#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。主に能力値計算のメソッドを含んでいます。こ
# のクラスは Game_Battler クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ○ 退場コマンドを設定
  #--------------------------------------------------------------------------
  def break_skill_id
    return SummonSystem::BREAK_SKILL
  end
  #--------------------------------------------------------------------------
  # 〇 退場の使用可能判定
  #--------------------------------------------------------------------------
  def break_usable?
    usable?($data_skills[break_skill_id]) && !$game_party.summon_no_remove
  end
end

#==============================================================================
# ■ Window_ActorCommand
#------------------------------------------------------------------------------
# 　バトル画面で、アクターの行動を選択するウィンドウです。
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成 ※エイリアス
  #--------------------------------------------------------------------------
  alias break_make_command_list make_command_list
  def make_command_list
    break_make_command_list
    return unless @actor
    add_break_command
  end
  #--------------------------------------------------------------------------
  # ○ 退場コマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_break_command
    add_command($data_skills[SummonSystem::BREAK_SKILL].name, :break, @actor.break_usable?) if @actor.summon_type?
  end
end


#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● アクターコマンドウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias break_create_actor_command_window create_actor_command_window
  def create_actor_command_window
    break_create_actor_command_window
    @actor_command_window.set_handler(:break,  method(:command_break))
  end
  #--------------------------------------------------------------------------
  # ○ コマンド［退場］
  #--------------------------------------------------------------------------
  def command_break
    BattleManager.actor.input.set_break
    select_actor_selection
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]アクター［キャンセル］
  #--------------------------------------------------------------------------
  alias break_on_actor_cancel on_actor_cancel
  def on_actor_cancel
    # 元のメソッドを呼ぶ
    break_on_actor_cancel
    # 退場の場合
    case @actor_command_window.current_symbol
    when :break
      @actor_command_window.activate
    end    
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アクターの選択したアイテム・スキルを返す　※再定義
  #--------------------------------------------------------------------------
  def actor_selection_item
    case @actor_command_window.current_symbol
    when :attack ; $data_skills[BattleManager.actor.attack_skill_id]
    when :skill  ; @skill
    when :item   ; @item
    when :guard  ; $data_skills[BattleManager.actor.guard_skill_id]
    when :break  ; $data_skills[BattleManager.actor.break_skill_id] #追加★
    when :concentration  ; $data_skills[BattleManager.actor.concentration_skill_id] #追加★
    else ; nil
    end
  end
end
