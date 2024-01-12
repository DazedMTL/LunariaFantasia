class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def repeat_anime
    return $1.to_i if self.note =~ /\<アニメ追加:(\d+)\>/
    return 0
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def link_anime
    return $1.to_i if self.note =~ /\<リンクアニメ:(\d+)\>/
    return 0
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def not_mirror?
    self.note.include?("<反転無し>")
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def repeat_plus
    return $1.to_i if self.note =~ /\<攻撃回数追加:(\d+)\>/
    return 0
  end
  #--------------------------------------------------------------------------
  # ○
  #--------------------------------------------------------------------------
  def repeats
    @repeats + repeat_plus
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    @log_window.display_use_item(@subject, item)
    @subject.use_item(item)
    refresh_status
    targets = @subject.current_action.make_targets.compact
    show_animation(targets, item.animation_id, item.repeat_anime, !item.not_mirror?, item.link_anime)
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
  end
  #--------------------------------------------------------------------------
  # ● アニメーションの表示
  #     targets      : 対象者の配列
  #     animation_id : アニメーション ID（-1: 通常攻撃と同じ）
  #--------------------------------------------------------------------------
  alias repeat_show_animation show_animation
  def show_animation(targets, animation_id, repeat_anime = 0, mirror_flag = true, link = 0)
    if link > 0 || repeat_anime >= 1
      if animation_id < 0
        if @subject.actor?
          animation_id = @subject.atk_animation_id1
        elsif @subject.enemy?
          animation_id = @subject.atk_animation # XPスタイルバトル&エネミーコンボ対応合わせ
        else
          animation_id = 1
        end
      end
      mirror = false
      repeat_anime += 1
      repeat_anime.times do
        show_normal_animation(targets, animation_id, mirror)
        wait_for_animation
        mirror ^= true if mirror_flag
      end
      show_normal_animation(targets, link) if link > 0
      @log_window.wait
      wait_for_animation
=begin
    elsif repeat_anime >= 1
      animation_id = @subject.atk_animation_id1 if animation_id < 0
      mirror = false
      repeat_anime += 1
      repeat_anime.times do
        show_normal_animation(targets, animation_id, mirror)
        wait_for_animation
        mirror ^= true if mirror_flag
      end
      @log_window.wait
      wait_for_animation
=end
    else
      repeat_show_animation(targets, animation_id)
    end
  end
end
