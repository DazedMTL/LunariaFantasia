module FAKEREAL
  
  #--------------------------------------------------------------------------
  # ● カウンターの発動タイプ
  #   0(1以外):デフォルト　1:攻撃を受けた後
  #--------------------------------------------------------------------------
  COUNTER_TYPE  = 1
  
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用　※連続攻撃の場合、最後にカウンター判定
  #--------------------------------------------------------------------------
  alias end_counter_use_item use_item
  def use_item
    if FAKEREAL::COUNTER_TYPE == 1
      item = @subject.current_action.item
      @log_window.display_use_item(@subject, item)
      @subject.use_item(item)
      refresh_status
      targets = @subject.current_action.make_targets.compact
      show_animation(targets, item.animation_id, item.repeat_anime, !item.not_mirror?, item.link_anime)
      targets.each {|target| item.repeats.times {|i| invoke_item(target, item, i) } }
    else
      end_counter_use_item
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの発動
  #--------------------------------------------------------------------------
  alias counter_type_invoke_item invoke_item
  def invoke_item(target, item, i = 0)
    if FAKEREAL::COUNTER_TYPE == 1
      if rand < target.item_mrf(@subject, item)
        invoke_magic_reflection(target, item)
      else
        apply_item_effects(apply_substitute(target, item), item)
      end
      if target.movable? && @subject.alive? && item.repeats == (i + 1) && [rand - i * 0.05, 0].max < target.item_cnt(@subject, item)
        invoke_counter_attack(target, item)
      end
      @subject.last_target_index = target.index
    else
      counter_type_invoke_item(target, item)
    end
  end
end
