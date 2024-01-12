module FAKEREAL
  
  NOT_SAVE = "<セーブ禁止！>"
  
end

#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　メニュー画面で表示するコマンドウィンドウです。
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● セーブの有効状態を取得
  #--------------------------------------------------------------------------
  alias save_map_save_enabled save_enabled
  def save_enabled
    save_map_save_enabled && save_map?
    #!$game_system.save_disabled
  end
  #--------------------------------------------------------------------------
  # ○ セーブ可能マップか
  #--------------------------------------------------------------------------
  def save_map?
    !$game_map.note.include?(FAKEREAL::NOT_SAVE)
  end
end