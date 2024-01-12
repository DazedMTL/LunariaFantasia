#==============================================================================
# 体験版で削除したサーヴァントの補完。
# スキル習得とGame_Interpreterからスキルを覚える場合に
# 対象のアクター(サーヴァント)をリセットする。
# レベルアップで召喚スキルは覚えないのでそちらは未対応。
#==============================================================================

#==============================================================================
# ■ Game_Actors
#------------------------------------------------------------------------------
# 　アクターの配列のラッパーです。このクラスのインスタンスは $game_actors で参
# 照されます。
#==============================================================================

class Game_Actors
  #--------------------------------------------------------------------------
  # 〇 アクターの再生成　※体験版修正用
  #--------------------------------------------------------------------------
  def actor_reset(actor_id)
    return unless $data_actors[actor_id] 
    return unless @data[actor_id]
    return if @data[actor_id] && @data[actor_id].name == $data_actors[actor_id].name # 名前が一致する場合は何もしない
    p "アクターID #{actor_id}　がリセットされました"
    @data[actor_id] = SummonSystem::SUMMON_ACTORS.include?(actor_id) ? Game_Servant.new(actor_id) : Game_Actor.new(actor_id)
  end
  #--------------------------------------------------------------------------
  # 〇 アクターの強制再生成　※体験版修正用　おそらく使用せずとも大丈夫
  #--------------------------------------------------------------------------
  def actor_reset_forced(actor_id)
    return unless $data_actors[actor_id] # アクターデータが存在しない場合は何もしない
    return unless @data[actor_id] # 生成前の場合は何もしない
    p "アクターID #{actor_id}　が強制リセットされました"
    @data[actor_id] = SummonSystem::SUMMON_ACTORS.include?(actor_id) ? Game_Servant.new(actor_id) : Game_Actor.new(actor_id)
  end
end


#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　ゲーム中の全てのウィンドウのスーパークラスです。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● アクター n 番の名前を取得　※再定義
  #        アクターネームを取得する際に名前が空白だとリセット
  #--------------------------------------------------------------------------
  def actor_name(n)
    actor = n >= 1 ? $game_actors[n] : nil
    if actor && actor.name == ""
      $game_actors.actor_reset(n)
    end
    actor ? actor.name : ""
  end
end


#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● スキルの増減　※再定義
  #--------------------------------------------------------------------------
  def command_318
    iterate_actor_var(@params[0], @params[1]) do |actor|
      if @params[2] == 0
        actor.learn_skill(@params[3])
        if actor.main? && $data_skills[@params[3]].stype_id == 3
          a_id = SummonSystem.summon_id($data_skills[@params[3]])
          $game_actors.actor_reset(a_id)
          $game_actors[a_id].recover_all # 習得後全回復
        end
      else
        actor.forget_skill(@params[3])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ 魔力吸収後のサーヴァントのリセット ※魔力吸収のコモンイベントで使用
  #--------------------------------------------------------------------------
  def actor_reset_s
    SummonSystem::SUMMON_ACTORS.each do |i|
      $game_actors.actor_reset(i)
      $game_actors[i].refresh
    end
  end
  #--------------------------------------------------------------------------
  # ○ アクターの強制リセット ※主に一週目に仲間になる前に使用。体験版修正用
  #--------------------------------------------------------------------------
  def actor_reset_forced(actor_id)
    $game_actors.actor_reset_forced(actor_id)
  end
end 
  

#==============================================================================
# ■ Scene_Learn
#------------------------------------------------------------------------------
# 　技習得画面の処理を行うクラスです。
#==============================================================================

class Scene_Learn < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● アイテム［決定］　※再定義
  #--------------------------------------------------------------------------
  def on_item_ok
    play_se_for_learn
    @result_window.hide
    @yesno_window.hide
    @actor.ap -= skill_ap
    @point_window.point = @actor.ap
    if @category_window.current_symbol == :learn
      @actor.learn_skill(item.id)
      if @actor.main? && item.stype_id == 3 # 追加
        a_id = SummonSystem.summon_id(item)
        $game_actors.actor_reset(a_id)
        $game_actors[a_id].tactics_reset
        $game_actors[a_id].recover_all # 習得後全回復
      end
    else
      @actor.skill_lv_up(item.id, 1)
    end
    @item_window.refresh
    @item_window.activate
  end
end