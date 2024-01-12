#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　スプライトや行動に関するメソッドを追加したバトラーのクラスです。このクラス
# は Game_Actor クラスと Game_Enemy クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 使用効果［特殊効果］
  #--------------------------------------------------------------------------
  alias ap_gain_item_effect_special item_effect_special
  def item_effect_special(user, item, effect)
    if item.note=~ /\<AP獲得:(\d+)\>/ && !$game_party.in_battle
      @result.success = true
      self.ap += $1.to_i
    else
      ap_gain_item_effect_special(user, item, effect)
    end
  end
end