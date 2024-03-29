#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。主に能力値計算のメソッドを含んでいます。こ
# のクラスは Game_Battler クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 通常能力値の最大値取得　※再定義
  #--------------------------------------------------------------------------
  def param_max(param_id)
    return 9999999 if param_id == 0  # MHP 一桁追加
    return 9999   if param_id == 1  # MMP
    return 999
  end
end