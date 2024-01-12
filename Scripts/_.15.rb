#==============================================================================
# ■ RGSS3 ショップステータス表示変更 ver 1.03
#------------------------------------------------------------------------------
# 　配布元:
#     白の魔 http://izumiwhite.web.fc2.com/
#
# 　利用規約:
#     RPGツクールVX Aceの正規の登録者のみご利用になれます。
#     利用報告・著作権表示とかは必要ありません。
#     改造もご自由にどうぞ。
#     何か問題が発生しても責任は持ちません。
#==============================================================================


#--------------------------------------------------------------------------
# ★ 初期設定。
#    アクター預かり所併用時の処理等の設定
#--------------------------------------------------------------------------
module WD_shopstatus_ini
  
  MemberChange =  false #アクター預かり所のスクリプトを併用し、
                        #預かり所のアクターも表示する場合はtrue
                          
  E_type_slot_id = []#この行は消さないで下さい。
  
  Chara_view = true #ショップで歩行グラフィックを表示する場合はtrue
  Face_view = false  #ショップで顔グラフィックを表示する場合はtrue
  
  #各装備タイプと対応するスロットID
  #ショップではここで指定したスロットIDに装備した時の
  #スタース変動を表示します。
  #nilに指定した場合は、変動を表示しません。(例: E_type_slot_id[4] = nil)
  E_type_slot_id[0] = 0   #武器ステータス比較時に入れ替える装備スロットID
  E_type_slot_id[1] = 1#2   #盾ステータス比較時に入れ替える装備スロットID
  E_type_slot_id[2] = 2#3   #頭ステータス比較時に入れ替える装備スロットID
  E_type_slot_id[3] = 3#1   #身体ステータス比較時に入れ替える装備スロットID
  E_type_slot_id[4] = 4   #装飾品ステータス比較時に入れ替える装備スロットID

end


class Window_ShopStatus < Window_Base
  #-------------------------------------------------------------------
  # ● 装備情報の描画
  #--------------------------------------------------------------------------
  def draw_equip_info(x, y)
    @actor = status_member
    @temp_actor = nil
    draw_actor_equip_info(x, y, @actor)
  end
  #--------------------------------------------------------------------------
  # ● 装備情報を描画するアクターの配列
  #--------------------------------------------------------------------------
  def status_member
    status_members[@page_index]
  end
  #--------------------------------------------------------------------------
  # ● 装備情報を描画するアクターの配列
  #--------------------------------------------------------------------------
  def status_members
    if WD_shopstatus_ini::MemberChange
      members = []
      $data_actors.each do |actor|
        if actor
          if $game_switches[WD_memberchange_ini::Initial_switch+actor.id-1]
            members.push($game_actors[actor.id])
          end
        end
      end    
      return members
    else
      $game_party.members
    end
  end
  #--------------------------------------------------------------------------
  # ● 最大ページ数の取得
  #--------------------------------------------------------------------------
  def page_max
    status_members.size
  end
  #-------------------------------------------------------------------
  # ● 装備情報の描画
  #--------------------------------------------------------------------------
  def draw_equip_info(x, y)
    @actor = status_member
    @slot_id = nil
    @slot_id = WD_shopstatus_ini::E_type_slot_id[@item.etype_id]
    if @slot_id
      if @actor
        temp_actor = Marshal.load(Marshal.dump(@actor))
        temp_actor.force_change_equip(@slot_id, @item)
        set_temp_actor(temp_actor)
        i = 0
        draw_actor_name(@actor, 4, line_height*2)
        if WD_shopstatus_ini::Chara_view
          draw_actor_graphic(@actor, 140, line_height*3, @actor.equippable?(@item))
        end
        if @actor.equips_item_same?(@slot_id, @item)
          draw_text(x + 140, line_height * 2 + 6, 96, line_height, "E", 0)
        end
        if WD_shopstatus_ini::Face_view
          draw_actor_face(@actor, 204, line_height*2, @actor.equippable?(@item))
        end
        6.times {|i| draw_item(4, line_height * (3.5 + i), 2 + i) }
        3.times {|i| draw_item_xparam_ss(4, line_height * (3.5 + i + 6), i) }
      end
      contents.font.size = 16
      change_color(normal_color)
      draw_text(x, y+248, 250, line_height, "#{key_button("A")} #{key_button("S")}: キャラクター切り替え", 0)
      contents.font.size = 24
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備変更後の一時アクター設定
  #--------------------------------------------------------------------------
  def set_temp_actor(temp_actor)
    return if @temp_actor == temp_actor
    @temp_actor = temp_actor
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(x, y, param_id)
    draw_param_name(x + 4, y, param_id)
    #draw_current_param(x + 94, y, param_id) if @actor
    #draw_right_arrow(x + 126, y)
    #draw_new_param(x + 150, y, param_id) if @temp_actor
    draw_new_param(x + 94, y, param_id) if @temp_actor
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画　※追加
  #--------------------------------------------------------------------------
  def draw_item_xparam_ss(x, y, param_id)
    draw_xparam_name_ss(x + 4, y, param_id)
    #draw_current_xparam_ss(x + 94, y, param_id) if @actor
    #draw_right_arrow(x + 126, y)
    #draw_new_xparam_ss(x + 150, y, param_id) if @temp_actor
    draw_new_xparam_ss(x + 94, y, param_id) if @temp_actor
  end
  #--------------------------------------------------------------------------
  # ● 能力値の名前を描画
  #--------------------------------------------------------------------------
  def draw_param_name(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, Vocab::param(param_id))
  end
  #--------------------------------------------------------------------------
  # ● 現在の能力値を描画
  #--------------------------------------------------------------------------
  def draw_current_param(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 32, line_height, @actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値の描画
  #--------------------------------------------------------------------------
  def ex_param(param_id, actor)
    case param_id
    when 0;    return actor.hit * 100
    when 1;    return actor.eva * 100
    when 2;    return actor.cri * 100
    else  ;    return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 能力値の名前を描画　※追加
  #--------------------------------------------------------------------------
  def draw_xparam_name_ss(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, FAKEREAL::xparam(param_id))
  end
  #--------------------------------------------------------------------------
  # ● 現在の能力値を描画　※追加
  #--------------------------------------------------------------------------
  def draw_current_xparam_ss(x, y, param_id)
    change_color(normal_color)
    draw_text(x - 24, y, 56, line_height, "#{format("%.2f",ex_param(param_id, @actor))}", 2)
  end
  #--------------------------------------------------------------------------
  # ● 右向き矢印を描画
  #--------------------------------------------------------------------------
  def draw_right_arrow(x, y)
    change_color(system_color)
    draw_text(x, y, 22, line_height, "→", 1)
  end
  #--------------------------------------------------------------------------
  # ● 装備変更後の能力値を描画
  #--------------------------------------------------------------------------
  def draw_new_param(x, y, param_id)
    #if @actor.equips_item_same?(@slot_id, @item)
      #new_value = "E"
      #change_color(normal_color)
    if @actor.equippable?(@item)
      new_value = @temp_actor.param(param_id)
      nv = new_value - @actor.param(param_id)
      change_color(param_change_color(nv))#new_value - @actor.param(param_id)))
    else
      new_value = "-"
      nv = nil
      change_color(normal_color)
    end
    draw_text(x + 24, y, 32, line_height, new_value, 2)
    draw_text(x + 24 + 40, y, 32, line_height, nv > 0 ? "+#{nv}" : nv, 0) if nv && nv != 0
  end
  #--------------------------------------------------------------------------
  # ● 装備変更後の能力値を描画　※追加
  #--------------------------------------------------------------------------
  def draw_new_xparam_ss(x, y, param_id)
    #if @actor.equips_item_same?(@slot_id, @item)
      #new_value = "E"
      #change_color(normal_color)
    if @actor.equippable?(@item)
      new_value = ex_param(param_id, @temp_actor)
      nv = new_value - ex_param(param_id, @actor)
      change_color(param_change_color(new_value - ex_param(param_id, @actor)))
      new_value = "#{format("%.2f",new_value)}"
      nv = "#{format("%.2f",nv)}"
    else
      new_value = "-"
      nv = nil
      change_color(normal_color)
    end
    draw_text(x, y, 56, line_height, new_value, 2)
    draw_text(x + 24 + 40, y, 56, line_height, nv.to_f > 0 ? "+#{nv}" : nv, 0) if nv && nv.to_f != 0
  end
  #--------------------------------------------------------------------------
  # ● ページの更新
  #--------------------------------------------------------------------------
  def update_page
    if visible && Input.repeat?(:Y) && page_max > 1
      Sound.play_cursor
      @page_index = (@page_index + 1) % page_max
      refresh
    elsif visible && Input.repeat?(:X) && page_max > 1
      Sound.play_cursor
      @page_index = (@page_index - 1) % page_max
      refresh      
    end
  end
end

##以下追加

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 装備が同じかチェック
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  def equips_item_same?(slot_id, item)
    @equips[slot_id].object == item
  end
end

class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 歩行グラフィックの描画
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y, enabled = true)
    return unless character_name
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    contents.blt(x - cw / 2, y - ch, bitmap, src_rect, enabled ? 255 : translucent_alpha)
  end
  #--------------------------------------------------------------------------
  # ● アクターの歩行グラフィック描画
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y, enabled = true)
    draw_character(actor.character_name, actor.character_index, x, y, enabled)
  end
end
