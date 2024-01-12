#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　スプライトや行動に関するメソッドを追加したバトラーのクラスです。このクラス
# は Game_Actor クラスと Game_Enemy クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def float?
    false
  end
end

#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　敵キャラを扱うクラスです。このクラスは Game_Troop クラス（$game_troop）の
# 内部で使用されます。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 物理与ダメージ率の取得
  #--------------------------------------------------------------------------
  def float?
    enemy.note.include?("<浮遊>")
  end
end

#==============================================================================
# ■ Sprite_Base
#------------------------------------------------------------------------------
# 　アニメーションの表示処理を追加したスプライトのクラスです。
#==============================================================================

class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # ● アニメーションの原点設定
  #--------------------------------------------------------------------------
  alias float_set_animation_origin set_animation_origin
  def set_animation_origin
    if @animation.position == 2 && $game_party.in_battle
      if @battler.float?
        @ani_ox = x - ox + width / 2
        @ani_oy = y - oy + height / 2
        @ani_oy += height / 2 + 80
      else
        float_set_animation_origin
      end
    else
      float_set_animation_origin
    end
=begin
    if @animation.position == 3
      if viewport == nil
        @ani_ox = Graphics.width / 2
        @ani_oy = Graphics.height / 2
      else
        @ani_ox = viewport.rect.width / 2
        @ani_oy = viewport.rect.height / 2
      end
    else
      @ani_ox = x - ox + width / 2
      @ani_oy = y - oy + height / 2
      if @animation.position == 0
        @ani_oy -= height / 2
      elsif @animation.position == 2
        @ani_oy += height / 2
      end
    end
=end
  end
end