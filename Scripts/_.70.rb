#==============================================================================
# ■ Window_EquipStatus
#------------------------------------------------------------------------------
# 　装備画面で、アクターの能力値変化を表示するウィンドウです。
#==============================================================================

class Window_EquipStatus < Window_Base
  include FRGP
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias equip_plus_initialize initialize
  def initialize(x, y)
    @page_index = 0
    equip_plus_initialize(x, y)
  end
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  def command_window=(command_window)
    @command_window = command_window
  end
  #--------------------------------------------------------------------------
  # ○ 最大ページ数の取得
  #--------------------------------------------------------------------------
  def page_max
    return 4
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得　※再定義
  #--------------------------------------------------------------------------
  def window_width
    return 256
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得　※再定義
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height - fitting_height(2)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ　※再定義
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_actor_name(@actor, 4, 0) if @actor
    draw_actor_face(@actor, 72, line_height * 2) if @actor
    draw_page(line_height * 0)
    case @page_index
    when 0
      draw_actor_point(24 + 34, line_height * 6)
      6.times {|i| draw_item(0, line_height * (9 + i), i + 2) }
    when 1
      draw_actor_point(24 + 34, line_height * 6)
      3.times {|i| draw_item_ex(0, line_height * (9 + i), i) }
    when 2
      if @temp_actor
        draw_guard_state_new(14, line_height * 6)
        draw_magic_elements_new(134, line_height * 6)
      else
        draw_guard_state(14, line_height * 6) if @actor
        draw_magic_elements(134, line_height * 6) if @actor
      end
    when 3
      if @temp_actor
        draw_guard_debuff_new(14, line_height * 6)
        draw_guard_elements_new(134, line_height * 6)
      else
        draw_guard_debuff(14, line_height * 6) if @actor
        draw_guard_elements(134, line_height * 6) if @actor
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ 適正や耐性の描画ベース
  #--------------------------------------------------------------------------
  def draw_percent_new(x, y, str, rate, icon = false, plus = 0)
    change_color(system_color)
    i = 0
    draw_text(x, y + line_height * i, 85, line_height, str)
    return unless rate
    h = line_height
    rate.each do |name, num|
      change_color(normal_color)
      i += 1
      if icon
        draw_icon(name, x, y + h * i)
      else
        draw_text(x + 4, y + h * i, 82, h, "#{name}")
      end
      change_color(num[1])
      draw_text(x + plus, y + h * i, 82, h, "#{num[0]}％", 2)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 術適正の描画
  #--------------------------------------------------------------------------
  def draw_magic_elements_new(x, y)
    ary = ["炎","氷","雷","光","闇","無","回復"]
    str = "術適正"
    rate = {}
    ary.each{|name| rate[name] = el_rate_new(name)}
    draw_percent_new(x, y, str, rate, false, 13)
  end
  #--------------------------------------------------------------------------
  # ○ 属性耐性の描画
  #--------------------------------------------------------------------------
  def draw_guard_elements_new(x, y)
    ary = ["炎","氷","雷","光","闇","艶"]
    str = "属性耐性"
    rate = {}
    ary.each{|name| rate[ELEMENT_ICON[elements_comvert(name)]] = elg_rate_new(name)}
    draw_percent_new(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ 状態耐性の描画
  #--------------------------------------------------------------------------
  def draw_guard_state_new(x, y)
    ary = ["即死","毒","暗闇","沈黙","混乱","睡眠","麻痺","ｽﾀﾝ","閉門"]
    str = "状態耐性"
    rate = {}
    ary.each{|name| rate[$data_states[state_comvert(name)].icon_index] = stg_rate_new(name)}
    draw_percent_new(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ 弱体耐性の描画
  #--------------------------------------------------------------------------
  def draw_guard_debuff_new(x, y)
    ary = [2, 3, 4, 5, 6, 7]
    str = "弱体耐性"
    rate = {}
    ary.each{|id| rate[ICON_DEBUFF_START + id] = debuff_rate_new(id)}
    draw_percent_new(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ IDを術適正に変換
  #--------------------------------------------------------------------------
  def el_rate_new(element_name)
    new = (@temp_actor.atk_elements_rate(elements_comvert(element_name)) * 100).round
    now = (@actor.atk_elements_rate(elements_comvert(element_name)) * 100).round
    return [new, param_change_color(new - now)]
  end
  #--------------------------------------------------------------------------
  # ○ IDを属性耐性に変換
  #--------------------------------------------------------------------------
  def elg_rate_new(element_name)
    new = 100 - (@temp_actor.element_rate(elements_comvert(element_name)) * 100).round
    now = 100 - (@actor.element_rate(elements_comvert(element_name)) * 100).round
    return [new, param_change_color(new - now)]
  end
  #--------------------------------------------------------------------------
  # ○ IDを状態耐性に変換
  #--------------------------------------------------------------------------
  def stg_rate_new(state_name)
    id = state_comvert(state_name)
    new = @temp_actor.state_resist?(id) ? 100 : 100 - (@temp_actor.state_rate(id) * 100).round
    now = @actor.state_resist?(id) ? 100 : 100 - (@actor.state_rate(id) * 100).round
    return [new, param_change_color(new - now)]
  end
  #--------------------------------------------------------------------------
  # ○ IDを弱体耐性に変換
  #--------------------------------------------------------------------------
  def debuff_rate_new(id)
    new = 100 - (@temp_actor.debuff_rate(id) * 100).round
    now = 100 - (@actor.debuff_rate(id) * 100).round
    return [new, param_change_color(new - now)]
  end
  #--------------------------------------------------------------------------
  # ○ ページ数の描画
  #--------------------------------------------------------------------------
  def draw_page(y)
    change_color(normal_color)
    draw_text(0, y, contents_width, line_height, "page#{@page_index + 1}/#{page_max}", 2)
    draw_text(-2, y + line_height, contents_width, line_height, "←　→", 2)
  end
  #--------------------------------------------------------------------------
  # ○ HPMPTP の描画
  #--------------------------------------------------------------------------
  def draw_actor_point(x, y, width = 124)
    if @temp_actor
      draw_actor_new_hp(@temp_actor, x, y + line_height * 0, width)
      draw_actor_new_mp(@temp_actor, x, y + line_height * 1, width)
      draw_actor_new_tp(@temp_actor, x, y + line_height * 2, width)
    elsif @actor
      draw_actor_hp(@actor, x, y + line_height * 0, width)
      draw_actor_mp(@actor, x, y + line_height * 1, width)
      draw_actor_tp(@actor, x, y + line_height * 2, width)
    else
      change_color(system_color)
      draw_text(x, y, 90, line_height, Vocab::hp_a)
      draw_text(x, y + line_height * 1, 90, line_height, Vocab::mp_a)
      draw_text(x, y + line_height * 2, 90, line_height, Vocab::tp_a)
    end
  end
  #--------------------------------------------------------------------------
  # ○ HPMPTP の描画(装備後)
  #--------------------------------------------------------------------------
  #def draw_temp_actor_point(x, y, width = 182)
    #if @actor
      #draw_actor_new_hp(@temp_actor, x, y + line_height * 0, width)
      #draw_actor_new_mp(@temp_actor, x, y + line_height * 1, width)
      #draw_actor_new_tp(@temp_actor, x, y + line_height * 2, width)
    #else
      #change_color(system_color)
      #draw_text(x, y, 90, line_height, Vocab::hp_a)
      #draw_text(x, y + line_height * 1, 90, line_height, Vocab::mp_a)
      #draw_text(x, y + line_height * 2, 90, line_height, Vocab::tp_a)
    #end
  #end
  #--------------------------------------------------------------------------
  # ○ HP の描画(装備後)
  #--------------------------------------------------------------------------
  def draw_actor_new_hp(actor, x, y, width = 124)
    draw_actor_hp_gauge(actor, x, y, width)
    #draw_gauge(x, y, width, actor.hp_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    change = @temp_actor.mhp - @actor.mhp
    draw_current_and_max_values(x, y, width, actor.hp, actor.mhp,
      param_change_color(change), param_change_color(change))
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ○ MP の描画(装備後)
  #--------------------------------------------------------------------------
  def draw_actor_new_mp(actor, x, y, width = 124)
    draw_actor_mp_gauge(actor, x, y, width)
    #draw_gauge(x, y, width, actor.mp_rate, mp_gauge_color1, mp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::mp_a)
    change = @temp_actor.mmp - @actor.mmp
    draw_current_and_max_values(x, y, width, actor.mp, actor.mmp,
      param_change_color(change), param_change_color(change))
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ○ TP の描画(装備後)
  #--------------------------------------------------------------------------
  def draw_actor_new_tp(actor, x, y, width = 124)
    draw_actor_tp_gauge(actor, x, y, width)
    #draw_gauge(x, y, width, actor.tp_rate, tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::tp_a)
    change = @temp_actor.max_tp - @actor.max_tp
    draw_current_and_max_values(x, y, width, actor.tp, actor.max_tp,
      param_change_color(change), param_change_color(change))
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画　※特殊能力
  #--------------------------------------------------------------------------
  def draw_item_ex(x, y, param_id)
    draw_xparam_name(x + 58, y, param_id)
    draw_new_xparam(x + 56, y, param_id) if @actor
    #draw_xparam_name(x + 4, y, param_id)
    #draw_current_xparam(x + 2, y, param_id) if @actor
    #draw_right_arrow(x + 124, y)
    #draw_new_xparam(x + 94, y, param_id) if @temp_actor
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値の名前を描画
  #--------------------------------------------------------------------------
  def draw_xparam_name(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, FAKEREAL::xparam(param_id))
  end
  #--------------------------------------------------------------------------
  # ○ 現在の特殊能力値を描画
  #--------------------------------------------------------------------------
  def draw_current_xparam(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 124, line_height, "#{format("%.2f",ex_param(param_id, @actor))}", 2)
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値の取得
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
  # ○ 装備後の特殊能力値を描画
  #--------------------------------------------------------------------------
  def draw_new_xparam(x, y, param_id)
    new_value = @temp_actor ? ex_param(param_id, @temp_actor) : ex_param(param_id, @actor)
    nv = new_value - ex_param(param_id, @actor)
    change_color(param_change_color(nv))#new_value - @actor.param(param_id)))
    draw_text(x, y, 124, line_height, "#{format("%.2f",new_value)}", 2)
    draw_text(x + 132, y, 48, line_height, nv > 0 ? "+#{format("%.2f",nv)}" : "#{format("%.2f",nv)}", 0) if nv && nv != 0
    #change = ex_param(param_id, @temp_actor) - ex_param(param_id, @actor)
    #change_color(param_change_color(change))
    #draw_text(x, y, 124, line_height, "#{format("%.2f",ex_param(param_id, @temp_actor))}", 2)
    #change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画　※再定義
  #--------------------------------------------------------------------------
  def draw_item(x, y, param_id)
    draw_param_name(x + 58, y, param_id)
    draw_new_param(x + 148, y, param_id) if @actor
    #draw_param_name(x + 4, y, param_id)
    #draw_current_param(x + 94, y, param_id) if @actor
    #draw_right_arrow(x + 126, y)
    #draw_new_param(x + 186, y, param_id) if @temp_actor
  end
  #--------------------------------------------------------------------------
  # ○ 現在の特殊能力値を描画
  #--------------------------------------------------------------------------
  def draw_new_param(x, y, param_id)
    #change_color(normal_color)
    #draw_text(x, y, 124, line_height, "#{format("%.2f",ex_param(param_id, @actor))}", 2)
    new_value = @temp_actor ? @temp_actor.param(param_id) : @actor.param(param_id)
    nv = new_value - @actor.param(param_id)
    change_color(param_change_color(nv))#new_value - @actor.param(param_id)))
    draw_text(x, y, 32, line_height, new_value, 2)
    draw_text(x + 40, y, 32, line_height, nv > 0 ? "+#{nv}" : "#{nv}", 0) if nv && nv != 0
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_page
  end
  #--------------------------------------------------------------------------
  # ○ ページの更新
  #--------------------------------------------------------------------------
  def update_page
    if visible && ((Input.trigger?(:RIGHT) && !@command_window.active) || Input.trigger?(:Y)) #(@command_window && !@command_window.active)
      Sound.play_cursor
      @page_index = (@page_index + 1) % page_max
      refresh
    elsif visible && ((Input.trigger?(:LEFT) && !@command_window.active) || Input.trigger?(:X))
      Sound.play_cursor
      @page_index = (@page_index - 1) % page_max
      refresh
    end
  end
end

#==============================================================================
# ■ Window_EquipItem
#------------------------------------------------------------------------------
# 　装備画面で、装備変更の候補となるアイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
end

#==============================================================================
# ■ Window_EquipItem
#------------------------------------------------------------------------------
# 　装備画面で、装備変更の候補となるアイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_EquipItem_Extra < Window_EquipItem
  #--------------------------------------------------------------------------
  # 〇 ヘルプウィンドウ更新メソッドの呼び出し
  #--------------------------------------------------------------------------
  def call_update_help
    update_help if active && @help_window
    update_status if active && @actor && @status_window
  end
  #--------------------------------------------------------------------------
  # 〇 ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # 〇 ステータス更新
  #--------------------------------------------------------------------------
  def update_status
    temp_actor = Marshal.load(Marshal.dump(@actor))
    temp_actor.force_change_equip(@slot_id, item)
    @status_window.set_temp_actor(temp_actor)
  end
end


#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  alias eq_sp_create_status_window create_status_window
  def create_status_window
    eq_sp_create_status_window
    #@status_window.x = Graphics.width - @status_window.width
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias eq_sp_create_command_window create_command_window
  def create_command_window
    eq_sp_create_command_window
    @status_window.command_window = @command_window
    #@command_window.x = 0
  end
  #--------------------------------------------------------------------------
  # ● スロットウィンドウの作成
  #--------------------------------------------------------------------------
  alias eq_sp_create_slot_window create_slot_window
  def create_slot_window
    eq_sp_create_slot_window
    #@slot_window.x = 0
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成　※再定義
  #--------------------------------------------------------------------------
  def create_item_window
    wx = @command_window.x
    wy = @slot_window.y + @slot_window.height
    ww = Graphics.width - @status_window.width
    wh = Graphics.height - wy
    @item_window = Window_EquipItem_Extra.new(wx, wy, ww, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.status_window = @status_window
    @item_window.actor = @actor
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @slot_window.item_window = @item_window
  end
end
