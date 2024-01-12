#==============================================================================
# ■ Window_BattleLog
#------------------------------------------------------------------------------
# 　戦闘の進行を実況表示するウィンドウです。枠は表示しませんが、便宜上ウィンド
# ウとして扱います。
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● スキル／アイテム使用の表示
  #--------------------------------------------------------------------------
  alias name_cut_display_use_item display_use_item
  def display_use_item(subject, item)
    if item.is_a?(RPG::Skill) && item.name_cut
      add_text(item.message1)
      unless item.message2.empty?
        wait
        add_text(item.message2)
      end
    else
      name_cut_display_use_item(subject, item)
    end
  end
end

class RPG::Skill < RPG::UsableItem
  def name_cut
    @name_cut ||= nc_set
  end
  def nc_set
    self.note =~ /\<使用者名カット\>/
  end
end

