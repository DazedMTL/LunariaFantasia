#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================
=begin

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # 〇 カットインの実行
  #--------------------------------------------------------------------------
  def cutin_effect(user, item)
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用
  #--------------------------------------------------------------------------
  alias cutin_use_item use_item
  def use_item
    cutin_effect(@subject, @subject.current_action.item)
    cutin_use_item
  end
end

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　スプライトや行動に関するメソッドを追加したバトラーのクラスです。このクラス
# は Game_Actor クラスと Game_Enemy クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # 〇 スプライトのエフェクトをクリア
  #--------------------------------------------------------------------------
  def cutin_effects(user, item)
    item_effect_cutin(user, item) if item.cutin?
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def item_effect_cutin(user, item, effect = nil)
    item_effect_common_event(user, item, effect)
  end
end

class RPG::UsableItem < RPG::BaseItem
  def cutin?
    @cutin ||= cutin_set
  end
  def cutin_set
    self.note.include?("<カットイン発動>")
  end
end
=end
