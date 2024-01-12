#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● セットアップ　※再定義　画面サイズの引き伸ばしに伴い敵のy座標をエディタの
  #　　設定より下に移動。(のばした倍率分screen_yに乗算)
  #--------------------------------------------------------------------------
  def setup(troop_id)
    clear
    @troop_id = troop_id
    @enemies = []
    troop.members.each do |member|
      next unless $data_enemies[member.enemy_id]
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
      enemy.hide if member.hidden
      enemy.screen_x = member.x
      enemy.screen_y = member.y * 1.16 #
      @enemies.push(enemy)
    end
    init_screen_tone
    make_unique_names
  end
end

#==============================================================================
# ■ Sprite_Base
#------------------------------------------------------------------------------
# 　アニメーションの表示処理を追加したスプライトのクラスです。
#==============================================================================
=begin
class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # ● アニメーションスプライトの設定
  #     画面サイズの拡大に合わせてアニメーションも拡大
  #--------------------------------------------------------------------------
  alias zoom_xy_animation_set_sprites animation_set_sprites
  def animation_set_sprites(frame)
    if @animation.position == 3
      cell_data = frame.cell_data
      @ani_sprites.each_with_index do |sprite, i|
        next unless sprite
        pattern = cell_data[i, 0]
        if !pattern || pattern < 0
          sprite.visible = false
          next
        end
        sprite.bitmap = pattern < 100 ? @ani_bitmap1 : @ani_bitmap2
        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192,
          pattern % 100 / 5 * 192, 192, 192)
        if @ani_mirror
          sprite.x = @ani_ox - cell_data[i, 1]
          sprite.y = @ani_oy + cell_data[i, 2]
          sprite.angle = (360 - cell_data[i, 4])
          sprite.mirror = (cell_data[i, 5] == 0)
        else
          sprite.x = @ani_ox + cell_data[i, 1]
          sprite.y = @ani_oy + cell_data[i, 2]
          sprite.angle = cell_data[i, 4]
          sprite.mirror = (cell_data[i, 5] == 1)
        end
        sprite.z = self.z + 300 + i
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom_x = cell_data[i, 3] / 100.0 * 1.25
        sprite.zoom_y = cell_data[i, 3] / 100.0 * 1.25
        sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
        sprite.blend_type = cell_data[i, 7]
      end
    else
      zoom_xy_animation_set_sprites(frame)
    end
  end
end
=end