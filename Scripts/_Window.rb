#==============================================================================
# □ Window_ItemStatus
#------------------------------------------------------------------------------
# 　アイテム画面で、アイテムの能力値を表示するウィンドウです。
#==============================================================================

class Window_ShopStatus  < Window_Base #Window_Selectable #
  CURE_SKILLS     = [31, 32, 256]              # 回復魔術表示
  #--------------------------------------------------------------------------
  # ● 定数（使用効果）
  #--------------------------------------------------------------------------
  EFFECT_RECOVER_HP     = 11              # HP 回復
  EFFECT_RECOVER_MP     = 12              # MP 回復
  EFFECT_GAIN_TP        = 13              # TP 増加
  EFFECT_ADD_STATE      = 21              # ステート付加
  EFFECT_REMOVE_STATE   = 22              # ステート解除
  EFFECT_ADD_BUFF       = 31              # 能力強化
  EFFECT_ADD_DEBUFF     = 32              # 能力弱体
  EFFECT_REMOVE_BUFF    = 33              # 能力強化の解除
  EFFECT_REMOVE_DEBUFF  = 34              # 能力弱体の解除
  EFFECT_SPECIAL        = 41              # 特殊効果
  EFFECT_GROW           = 42              # 成長
  EFFECT_LEARN_SKILL    = 43              # スキル習得
  EFFECT_COMMON_EVENT   = 44              # コモンイベント
  #--------------------------------------------------------------------------
  # ● 定数（能力強化／弱体アイコンの開始番号）
  #--------------------------------------------------------------------------
  ICON_BUFF_START       = 64              # 強化（16 個）
  ICON_DEBUFF_START     = 80              # 弱体（16 個）
  #--------------------------------------------------------------------------
  # ● 定数（特殊効果）
  #--------------------------------------------------------------------------
  SPECIAL_EFFECT_ESCAPE = 0               # 逃げる
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias is_initialize initialize
  def initialize(x, y, width, height)
    @is_mode = false
    is_initialize(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  alias is_refresh refresh
  def refresh
    if @compose_mode
      is_refresh
    elsif rune?(@item) || @is_mode || @item.is_a?(RPG::Item)
      contents.clear
      draw_category(4, 0)
      if rune?(@item)
        draw_equip_possession(100, 0)
      else
        draw_possession(200, 0)
      end
      return if !@item
      if @item.is_a?(RPG::EquipItem)
        4.times {|i| draw_hmth(0, line_height * (2 + i), i, @item) }
        3.times {|i| draw_xparam(0, line_height * (5 + i), i, @item) }
        6.times {|i| draw_item(160, line_height * (2 + i), 2 + i) }
        draw_description(0, line_height, @item) if @item.is_a?(RPG::Armor)
        draw_description_add(0, line_height, @item) if @item.is_a?(RPG::Weapon)
      elsif @item.is_a?(RPG::Item)
        ary = effects_set(@item)
        draw_effects(160, line_height, ary, @item)
        draw_oc_sc(0, line_height, @item)
        draw_stbude(0, 8, ary)
      end
      draw_another(4, line_height * 12, @item)
    else
      is_refresh
    end
    if (@item.is_a?(RPG::EquipItem) && !rune?(@item)) || @compose_mode_main
      cfc = contents.font.clone
      contents.font.size = EasyCompose::FS2
      draw_text(4,line_height,contents_width,line_height,key_button("D") + EasyCompose::Text)
      contents.font = cfc
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムのルーン判定
  #--------------------------------------------------------------------------
  def rune?(item)
    return false if item == nil
    item.rune?
  end
  #--------------------------------------------------------------------------
  # ○ 所持数・装備数の描画 ルーン用
  #--------------------------------------------------------------------------
  def draw_equip_possession(x, y)
    rect = Rect.new(x, y, (contents.width - 4 - x) / 2, line_height)
    rect2 = Rect.new(x + rect.width, y, (contents.width - 4 - x) / 2, line_height)
    change_color(system_color)
    draw_text(rect.x + 24, rect.y, rect.width, rect.height, "Possessed")
    draw_text(rect2.x + 24, rect2.y, rect2.width, rect2.height, "Equipped")
    change_color(normal_color)
    draw_text(rect, $game_party.item_number(@item), 2)
    draw_text(rect2, $game_party.members_equip_number(@item), 2)
  end
  #--------------------------------------------------------------------------
  # ○ その他の説明の描画
  #--------------------------------------------------------------------------
  def draw_another(x, y, item)
    change_color(normal_color)
    item.ex_description.each_with_index {|text, i| draw_text_ex(x, y + line_height * i, number_comvert(text)) }
  end
  #--------------------------------------------------------------------------
  # ○ 数字の変換
  #--------------------------------------------------------------------------
  def number_comvert(text)
    text.tr('０-９','0-9')
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画　アイテム
  #--------------------------------------------------------------------------
  def effects_set(item)
    ary = Array.new(14, [])
    item.effects.each {|ef| effects_sort(ef, ary) }
    return ary
  end
  #--------------------------------------------------------------------------
  # ○ 属性IDを名前に変換
  #--------------------------------------------------------------------------
  def effects_sort(effect, ary)
    case effect.code
    when EFFECT_RECOVER_HP ; ary[0] = [effect.value1, effect.value2]
    when EFFECT_RECOVER_MP ; ary[1] = [effect.value1, effect.value2]
    when EFFECT_GAIN_TP ; ary[2] = [effect.value1, effect.value2]
    when EFFECT_ADD_STATE ; ary[3] += [[effect.data_id, false, 1]]
    when EFFECT_REMOVE_STATE ; ary[4] += [[effect.data_id, true, 1]]
    when EFFECT_ADD_BUFF ; ary[5] += [[effect.data_id, false, 2]]
    when EFFECT_ADD_DEBUFF ; ary[6] += [[effect.data_id, false, 0]]
    when EFFECT_REMOVE_BUFF ; ary[7] += [[effect.data_id, true, 2]]
    when EFFECT_REMOVE_DEBUFF ; ary[8] += [[effect.data_id, true, 0]]
    when EFFECT_SPECIAL ; ary[9] = [effect.data_id]
    when EFFECT_GROW ; ary[10] = [effect.data_id, effect.value1]
    when EFFECT_LEARN_SKILL ; ary[11] = [effect.data_id]
    when EFFECT_COMMON_EVENT ; ary[12] = [effect.data_id]
    else ; ary[13] = [effect.data_id]
    end
  end
  #--------------------------------------------------------------------------
  # ○ 効果範囲を変換
  #--------------------------------------------------------------------------
=begin
  def scope_change(scope)
    case scope
    when 0  ; "なし"
    when 1  ; "敵単体"
    when 2  ; "敵全体"
    when 3  ; "敵１体ランダム"
    when 4  ; "敵２体ランダム"
    when 5  ; "敵３体ランダム"
    when 6  ; "敵４体ランダム"
    when 7  ; "味方単体"
    when 8  ; "味方全体"
    when 9  ; "味方単体(戦闘不能)"
    when 10 ; "味方全体(戦闘不能)"
    else    ; "使用者"
    end
  end
=end
  #--------------------------------------------------------------------------
  # ○ 効果範囲を変換 ※使用アイテム・スキル用
  #--------------------------------------------------------------------------
  def scope_change_usable(scope, random_change, random_plus)
    case scope
    when 0  ; "None"
    when 1  ; "Single Enemy"
    when 2  ; "All Enemies"
    when 3..6
      num = (scope - 2 + random_plus).to_s.tr('0-9','０-９')
      random_change ? "Enemies #{num}" : "Random #{num} Times"
    when 7  ; "Single Ally"
    when 8  ; "All Allies"
    when 9  ; "Single Ally (Incapacitated)"
    when 10 ; "All Allies (Incapacitated)"
    else    ; "User"
    end
  end
  #--------------------------------------------------------------------------
  # ○ Convert to usable occasion
  #--------------------------------------------------------------------------
  def occasion_change(occasion)
    case occasion
    when 0  ; "Always"
    when 1  ; "Battle Only"
    when 2  ; "Menu Only"
    else    ; "Not Usable"
    end
  end
  #--------------------------------------------------------------------------
  # ○ Convert consumption
  #--------------------------------------------------------------------------
  def consumable_change(consumable)
    return "Yes" if consumable
    return "No"
  end
  #--------------------------------------------------------------------------
  # ○ Draw item data 1
  #--------------------------------------------------------------------------
  def draw_oc_sc(x, y, item)
    draw_range(x, y * 2, "Usable", occasion_change(item.occasion))
    #draw_range(x, y * 4, "Scope of Effect", item.is_a?(RPG::UsableItem) ? scope_change_usable(item.scope, item.random_change, item.random_plus) : scope_change(item.scope))
    draw_range(x, y * 4, "Scope of Effect", scope_change_usable(item.scope, item.random_change, item.random_plus))
    draw_range(x, y * 6, "Consumption", consumable_change(item.consumable))
  end
  #--------------------------------------------------------------------------
  # ○ Draw each item
  #--------------------------------------------------------------------------
  def draw_range(x, y, name, type)
    draw_name_wide(x + 4, y, name, true)
    draw_name_wide(x + 12, y + line_height, type)
  end
  #--------------------------------------------------------------------------
  # ○ Draw names
  #--------------------------------------------------------------------------
  def draw_name_wide(x, y, name, system = false)
    change_color(normal_color)
    change_color(system_color) if system
    draw_text(x, y, 120, line_height, name)
  end
  #--------------------------------------------------------------------------
  # ○ Draw item data 1
  #--------------------------------------------------------------------------
  def draw_effects(x, y, ary, item)
    hp_h = ary.shift
    draw_heal(x, y * 2, "HP Recovery", hp_h[0], hp_h[1])
    mp_h = ary.shift
    draw_heal(x, y * 3, "MP Recovery", mp_h[0], mp_h[1])
    tp_h = ary.shift
    tp_h = tp_comvert(tp_h, item) unless tp_h.empty?
    draw_heal(x, y * 4, "SP Recovery", tp_h[0], tp_h[1])
  end
  #--------------------------------------------------------------------------
  # ○ の描画
  #--------------------------------------------------------------------------
  def draw_item_effect(x, y, effect)
    ary = code_change(effect)
    draw_text(x, y, 120, line_height, "#{ary[0]} #{ary[1]} #{ary[2]}")
  end
  #--------------------------------------------------------------------------
  # ○ 各回復を描画
  #--------------------------------------------------------------------------
  def draw_heal(x, y, name, rate, heal)
    draw_name(x + 4, y, name)
    draw_heal_param(x + 74, y, rate, heal)
  end
  #--------------------------------------------------------------------------
  # ○ 名を描画
  #--------------------------------------------------------------------------
  def draw_name(x, y, name)
    change_color(normal_color)
    draw_text(x, y, 65, line_height, name)
  end
  #--------------------------------------------------------------------------
  # ○ 回復数値を描画
  #--------------------------------------------------------------------------
  def draw_heal_param(x, y, rate, heal)
    if rate == nil
      num = 0
    else
      num = rate != 0.0 ? rate * 100 : heal 
    end
    per = (rate != 0.0) && (num > 0) ? "%" : ""
    kigou = num > 0 ? "+":""
    change_color(param_change_color(num))
    draw_text(x, y, 55, line_height, "#{kigou}#{num.to_i}#{per}", 2)
  end
  #--------------------------------------------------------------------------
  # ○ ＴＰ回復用数値の置き換え
  #--------------------------------------------------------------------------
  def tp_comvert(ary, item)
    if item.note =~ /\<TP回復:全回復\>/
      ary[0] = 1.0
    elsif item.note =~ /\<TPダメージ:(\d+)\>/
      ary[1].to_i *= -1
      ary[1] -= $1.to_i
    elsif item.note =~ /\<TPダメージ率:(\d+)\>/
      ary[0] -= ($1.to_i * 0.01).to_i
    elsif item.note =~ /\<TP回復率:(\d+)\>/
      ary[0] = $1.to_i * 0.01
    else
      ary[1] += $1.to_i if item.note =~ /\<TP回復:(\d+)\>/ #追加
    end
    return ary
  end
  #--------------------------------------------------------------------------
  # ○ 状態解除を描画
  #--------------------------------------------------------------------------
  def draw_remove_item(x, y, ary, hide)
    change_color(system_color)
    draw_text(x, y, 48, line_height, "解除")
    draw_remove(x + 52, y, ary, hide)
  end
  #--------------------------------------------------------------------------
  # ○ 状態付加を描画
  #--------------------------------------------------------------------------
  def draw_add_item(x, y, ary)
    change_color(system_color)
    draw_text(x, y, 48, line_height, "付加")
    draw_add(x + 52, y, ary)
  end
  #--------------------------------------------------------------------------
  # ○ 状態解除のアイコンを描画
  #--------------------------------------------------------------------------
  def draw_remove(x, y, st_array, hide)
    return if hide
    i = 0
    st_array.each do |ft_ary|
      next if ft_ary[0] <= 0 || !ft_ary[1]
      draw_icon($data_states[ft_ary[0]].icon_index, x + 24 * (i % 10), y + line_height * (i / 10)) if ft_ary[2] == 1
      draw_icon(buff_icon_index(ft_ary[2], ft_ary[0]), x + 24 * (i % 10), y + line_height * (i / 10)) if ft_ary[2] != 1
      i += 1
    end
  end
  #--------------------------------------------------------------------------
  # ○ 状態付加のアイコンを描画
  #--------------------------------------------------------------------------
  def draw_add(x, y, st_array)
    i = 0
    st_array.each do |ft_ary|
      next if ft_ary[0] <= 0 || ft_ary[1]
      draw_icon($data_states[ft_ary[0]].icon_index, x + 24 * (i % 10), y + line_height * (i / 10)) if ft_ary[2] == 1
      draw_icon(buff_icon_index(ft_ary[2], ft_ary[0]), x + 24 * (i % 10), y + line_height * (i / 10)) if ft_ary[2] != 1
      i += 1
    end
  end
  #--------------------------------------------------------------------------
  # ○ 状態強化弱体項目の描画
  #--------------------------------------------------------------------------
  def draw_stbude(x, y, ary, hide = false)
    st = ary.shift
    st += ary.shift
    st += ary.shift
    st += ary.shift
    st += ary.shift
    st += ary.shift
    draw_remove_item(x + 4, line_height * y, st, hide)
    draw_add_item(x + 4, line_height * (y + 2), st)
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画　装備品
  #--------------------------------------------------------------------------
  def draw_hmth(x, y, param_id, item)
    case param_id
    when 0, 1
      draw_param_name_is(x + 4, y, param_id)
      draw_change_param(x + 94, y, param_id, item)
    when 2
      draw_tp_name(x + 4, y, param_id)
      draw_change_tp(x + 94, y, param_id, item)
    else
      return unless item.rune?
      draw_heal_rate(x + 4, y + line_height * 3)
      draw_change_rate(x + 94, y + line_height * 3, item)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  alias is_draw_item draw_item
  def draw_item(x, y, param_id)
    if rune?(@item) || @is_mode || @item.is_a?(RPG::Item)
      draw_param_name_is(x + 4, y, param_id)
      draw_change_param(x + 94, y, param_id, @item) if @item
    else
      is_draw_item(x, y, param_id)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 能力値の名前を描画
  #--------------------------------------------------------------------------
  def draw_param_name_is(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 80, line_height, Vocab::param(param_id))
  end
  #--------------------------------------------------------------------------
  # ○ アイテムの能力値を描画
  #--------------------------------------------------------------------------
  def draw_change_param(x, y, param_id, item)
    num = item.params[param_id]
    kigou = num > 0 ? "+":""
    change_color(param_change_color(num))
    draw_text(x, y, 34, line_height, "#{kigou}#{num}", 2)
  end
  #--------------------------------------------------------------------------
  # ○ TPの名前を描画
  #--------------------------------------------------------------------------
  def draw_tp_name(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 80, line_height, "Max #{Vocab::tp}")
  end
  #--------------------------------------------------------------------------
  # ○ アイテムのTPを描画
  #--------------------------------------------------------------------------
  def draw_change_tp(x, y, param_id, item)
    num = item.soul_plus
    kigou = num > 0 ? "+":""
    change_color(param_change_color(num))
    draw_text(x, y, 34, line_height, "#{kigou}#{num}", 2)
  end
  #--------------------------------------------------------------------------
  # ○ 回復率の名前の描画
  #--------------------------------------------------------------------------
  def draw_heal_rate(x, y)
    change_color(normal_color)
    draw_text(x, y, 80, line_height, "Recovery Rate")
  end
  #--------------------------------------------------------------------------
  # ○ ルーンの回復率を描画
  #--------------------------------------------------------------------------
  def draw_change_rate(x, y, item)
    num = item.heal_rate_plus
    kigou = num > 0 ? "+":""
    change_color(param_change_color(num))
    draw_text(x, y, 34, line_height, "#{kigou}#{num}", 2)
  end
  #--------------------------------------------------------------------------
  # ○ 耐性項目の描画
  #--------------------------------------------------------------------------
  def draw_description(x, y, item)
    draw_element(x + 4, y * 9, item, "ATR RES", 11)
    draw_state(x + 4, y * 10, item)
    draw_debuff(x + 4, y * 11, item)
  end
  #--------------------------------------------------------------------------
  # ○ 付加項目の描画
  #--------------------------------------------------------------------------
  def draw_description_add(x, y, item)
    draw_element(x + 4, y * 9, item, "ATR Add", 31)
    draw_state_add(x + 4, y * 10, item)
  end
  #--------------------------------------------------------------------------
  # ○ 特徴オブジェクトの配列取得（特徴コードを限定）
  #--------------------------------------------------------------------------
  def strong_features(item, code)
    item.features.select {|ft| ft.code == code && ft.value < 1.0 }
  end
  #--------------------------------------------------------------------------
  # ○ 特徴オブジェクトの配列取得（特徴コードを限定）
  #--------------------------------------------------------------------------
  def resist_features(item, code)
    item.features.select {|ft| ft.code == code}
  end
  #--------------------------------------------------------------------------
  # ○ 属性耐性を描画
  #--------------------------------------------------------------------------
  def draw_element(x, y, item, name, id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, name)
    return unless item
    if name.include?("耐性")
      strong = strong_features(item, id)
    else
      strong = resist_features(item, id)
    end
    draw_element_name(x + 84, y, strong)
  end
  #--------------------------------------------------------------------------
  # ○ 属性耐性の名前を描画
  #--------------------------------------------------------------------------
  def draw_element_name(x, y, el_array)
    change_color(normal_color)
    el_array.each_with_index do |ft, i|
      draw_text(x + 24 * i, y, 24, line_height, $data_system.elements[ft.data_id], 1)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 状態耐性を描画
  #--------------------------------------------------------------------------
  def draw_state(x, y, item)
    change_color(system_color)
    draw_text(x, y, 80, line_height, "State RES")
    return unless item
    resist = resist_features(item, 14)
    strong = strong_features(item, 13)
    draw_state_name(x + 84, y, resist + strong)
  end
  #--------------------------------------------------------------------------
  # ○ 状態付加を描画
  #--------------------------------------------------------------------------
  def draw_state_add(x, y, item)
    change_color(system_color)
    draw_text(x, y, 80, line_height, "State Add")
    return unless item
    resist = resist_features(item, 32)
    draw_state_name(x + 84, y, resist)
  end
  #--------------------------------------------------------------------------
  # ○ 状態耐性のアイコンを描画
  #--------------------------------------------------------------------------
  def draw_state_name(x, y, st_array)
    change_color(normal_color)
    st_array.each_with_index do |ft, i|
      draw_icon($data_states[ft.data_id].icon_index, x + 24 * i, y)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 弱体耐性を描画
  #--------------------------------------------------------------------------
  def draw_debuff(x, y, item)
    change_color(system_color)
    draw_text(x, y, 80, line_height, "Weakness")
    return unless item
    strong = strong_features(item, 12)
    draw_debuff_name(x + 84, y, strong)
  end
  #--------------------------------------------------------------------------
  # ○ 弱体耐性のアイコンを描画
  #--------------------------------------------------------------------------
  def draw_debuff_name(x, y, db_array)
    change_color(normal_color)
    db_array.each_with_index do |ft, i|
      draw_icon(buff_icon_index(ft.value, ft.data_id), x + 24 * i, y)
    end
  end
  #--------------------------------------------------------------------------
  # ● 強化／弱体に対応するアイコン番号を取得
  #--------------------------------------------------------------------------
  def buff_icon_index(buff_level, param_id)
    if buff_level > 1.0
      return ICON_BUFF_START + param_id
    elsif buff_level < 1.0
      return ICON_DEBUFF_START + param_id 
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム分類の描画
  #--------------------------------------------------------------------------
  def draw_category(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    if @item.is_a?(RPG::Weapon)
      draw_text(rect, "武器：#{Vocab::wtype_name(@item.wtype_id)}")
    elsif @item.is_a?(RPG::Armor)
      draw_text(rect, "#{Vocab::atype_name(@item.atype_id)}：#{Vocab::etype(@item.etype_id)}") if @item.etype_id != 4
      draw_text(rect, "#{Vocab::atype_name(@item.atype_id)}") if @item.etype_id == 4
    elsif @item.is_a?(RPG::Item)
      @item.cooking? ? draw_text(rect, "Cooking") : draw_text(rect, "Tool")
    elsif @item.is_a?(RPG::Skill)
      draw_skill_type(x, y, @item)
    end
    change_color(normal_color)
  end
  
  
  #--------------------------------------------------------------------------
  # ● 読み仮名の描画
  #--------------------------------------------------------------------------
  def draw_kana(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    last_font_size = contents.font.size
    contents.font.size = 16
    change_color(important_color)
    draw_text(rect, @item.kana)
    change_color(normal_color)
    contents.font.size = last_font_size
  end
  
  
  #--------------------------------------------------------------------------
  # ● ページの更新
  #--------------------------------------------------------------------------
  alias is_update_page update_page
  def update_page
    if (visible && Input.repeat?(:Z)) && ((@item.is_a?(RPG::EquipItem) && !rune?(@item)) || @compose_mode_main)
    #if visible && Input.repeat?(:Z) && @item.is_a?(RPG::EquipItem) && !rune?(@item)
      Sound.play_cursor
      @is_mode ^= true
      refresh
    elsif !@is_mode && @item.is_a?(RPG::EquipItem) && !rune?(@item)
      is_update_page
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルタイプ名と武器の描画
  #--------------------------------------------------------------------------
  def draw_skill_type(x, y, type = "")
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力項目の描画
  #--------------------------------------------------------------------------
  def draw_xparam(x, y, param_id, item)
    draw_xparam_name(x + 4, y, param_id)
    draw_change_xparam(x + 94, y, param_id, item) if item
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値の名前を描画
  #--------------------------------------------------------------------------
  def draw_xparam_name(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 80, line_height, FAKEREAL::xparam(param_id))
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値を描画
  #--------------------------------------------------------------------------
  def draw_change_xparam(x, y, param_id, item)
    num = (xparam(item, param_id) * 100).to_i
    kigou = num > 0 ? "+":""
    change_color(param_change_color(num))
    draw_text(x, y, 34, line_height, "#{kigou}#{num}", 2)
  end
  #--------------------------------------------------------------------------
  # ○ 特徴オブジェクトの配列取得（特徴コードを限定）
  #--------------------------------------------------------------------------
  def xparam_features(item, id)
    item.features.select {|ft| ft.code == 22 && ft.data_id == id}
  end
  #--------------------------------------------------------------------------
  # ○ 特徴オブジェクトの配列取得（特徴コードを限定）
  #--------------------------------------------------------------------------
  def xparam(item, id)
    xparam_features(item, id).inject(0.0) {|r, ft| r += ft.value }
  end
end



class RPG::BaseItem
  def ex_description
    @ex_description ||= ex_description_set
  end
  def ex_description_set
    ary = []
    ary.push(self.note =~ /\<追加説明A:(\D+?)\>/ ? $1 : "")
    ary.push(self.note =~ /\<追加説明B:(\D+?)\>/ ? $1 : "")
  end
end

class RPG::Skill < RPG::UsableItem
  def ex_description_set
    ary = super
    ary.push(self.note =~ /\<追加説明C:(\D+?)\>/ ? $1 : "")
    ary.push(self.note =~ /\<追加説明D:(\D+?)\>/ ? $1 : "")
    ary.push(self.note =~ /\<追加説明E:(\D+?)\>/ ? $1 : "")
    ary.push(self.note =~ /\<追加説明F:(\D+?)\>/ ? $1 : "")
  end
end
#==============================================================================
# □ Window_ItemStatus
#------------------------------------------------------------------------------
# 　アイテム画面で、アイテムの能力値を表示するウィンドウです。
#==============================================================================

class Window_ItemStatus < Window_ShopStatus
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :actor_window            # メニューアクターウィンドウ
  attr_reader   :category_window         # カテゴリーウィンドウ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.visible = false
    self.back_opacity = 255
    self.z = 500
    @is_mode = true
    @actor = nil
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_category(4, 0)
    return if !@item || !self.visible
    draw_kana(4, line_height) #追加
    ay = 0
    if @item.is_a?(RPG::EquipItem)
      4.times {|i| draw_hmth(0, line_height * (2 + i), i, @item) }
      3.times {|i| draw_xparam(0, line_height * (5 + i), i, @item) }
      6.times {|i| draw_item(160, line_height * (2 + i), 2 + i) }
      draw_description(0, line_height, @item) if @item.is_a?(RPG::Armor)
      draw_description_add(0, line_height, @item) if @item.is_a?(RPG::Weapon)
      ay += 3
    elsif @item.is_a?(RPG::Item)
      ary = effects_set(@item)
      draw_effects(160, line_height, ary, @item)
      draw_oc_sc(0, line_height, @item)
      draw_stbude(0, 8, ary)
      ay += 3
    elsif @item.is_a?(RPG::Skill)
      ary = effects_set(@item)
      ary.shift
      ary.shift
      ary.shift
      draw_type(144, 0, @item)
      draw_os(0, line_height, @item)
      draw_stbude(0, 4, ary, @item.remove_hide)
      draw_cost(0, 8, @item)
      draw_horz_line(line_height * 9)
      if @item.base != 0
        draw_damage(8, 10, @item)
        draw_horz_line(line_height * 12)
        ay += 3 #if @item.stype_id != 8
      end
      if @item.use_limit != 0
        draw_use_limit(8, line_height * (10 + ay), @item)
        ay += 1
      end
    end
    draw_another(4, line_height * (10 + ay), @item)
  end
  #--------------------------------------------------------------------------
  # ○ 使用可能回数の描画　スキル
  #--------------------------------------------------------------------------
  def draw_use_limit(x, y, item)
    width = 144
    change_color(important_color)
    draw_text(x, y, width, line_height, "Limit")
    used = $game_party.in_battle ? item.use_limit - @actor.used_skill(item.id) : item.use_limit
    change_color(normal_color)
    draw_text(x + width, y, 100, line_height, "#{used}/#{item.use_limit}")
  end
  #--------------------------------------------------------------------------
  # ○ スキルタイプ名と武器の描画
  #--------------------------------------------------------------------------
  def draw_skill_type(x, y,item)
    rect = Rect.new(x, y, 64, line_height)
    rect2 = Rect.new(x + 68, y, 64, line_height)
    type = Vocab::stype_name(item.stype_id)
    change_color(system_color)
    draw_text(rect, type)
    weapon = []
    weapon.push(Vocab::wtype_name(item.required_wtype_id1))
    weapon.push(Vocab::wtype_name(item.required_wtype_id2))
    weapon.delete("")
    unless weapon.empty?
      text = ""
      weapon.each_with_index {|name,i| text += "#{name} " }
      change_color(normal_color)
      draw_text(rect2, text)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画　スキル
  #--------------------------------------------------------------------------
  def draw_os(x, y, item)
    draw_range(x, y * 2, "Available", occasion_change(item.occasion))
    draw_range(x + 140, y * 2, "Scope", scope_change_usable(item.scope, item.random_change, item.random_plus))
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画　スキル
  #--------------------------------------------------------------------------
  def draw_type(x, y, item)
    el = elements_comvert(item)
    width = 44
    change_color(system_color)
    draw_text(x, y, width, line_height, "ATR")
    change_color(normal_color)
    draw_text(x + width, y, 100, line_height, el)
    #rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    #draw_text(rect, "属性:#{el}")
  end
  #--------------------------------------------------------------------------
  # ○ 項目の描画　スキル
  #--------------------------------------------------------------------------
  def draw_cost(x, y, item)
    change_color(system_color)
    draw_text(x, line_height * y, 80, line_height, "Use #{Vocab::mp}", 2)
    draw_text(x + 140, line_height * y, 80, line_height, "Use #{Vocab::tp}", 2)
    change_color(normal_color)
    mp_cost = plus_cost(item, item.mp_cost, true)
    tp_cost = plus_cost(item, item.tp_cost)
    draw_text(x + 80, line_height * y, 40, line_height, "#{mp_cost}")
    draw_text(x + 140 + 80, line_height * y, 40, line_height, "#{tp_cost}")
  end
  
  #--------------------------------------------------------------------------
  # 〇 スキルの消費 TP 計算　※エイリアス
  #--------------------------------------------------------------------------
  def plus_cost(skill, cost, mp = false)
    default = cost
    if mp
      return "全#{Vocab::mp}" if skill.note.include?("<全MP消費>")
      return "最大#{Vocab::mp}" if skill.note.include?("<最大MP消費>")
    else
      default += $1.to_i if skill.note =~ /\<消費追加:(\d+)\>/
      return "全#{Vocab::tp}" if skill.note.include?("<全TP消費>")
      return "最大#{Vocab::tp}" if skill.note.include?("<最大TP消費>")
    end
    return default
  end
  #--------------------------------------------------------------------------
  # 〇 スキルの消費 MP 計算　※エイリアス
  #--------------------------------------------------------------------------
  def skill_mp_cost(skill)
    default = 0
    if skill.note.include?("<全MP消費>")
      return @mp > default ? @mp : default
    elsif skill.note.include?("<最大MP消費>")
      return mmp
    else
      return default
    end
  end
  
  #--------------------------------------------------------------------------
  # ○ 属性IDを名前に変換
  #--------------------------------------------------------------------------
  def elements_comvert(item)
    return "回復" if item.damage.recover? || CURE_SKILLS.include?(item.id)#( == 31 || item.id == 32 || item.id == 256)
    return "----" if item.damage.none?
    element_id = item.damage.element_id
    case element_id
    when 0 ; "None"
    when -1 ; "武器依存"
    else ; $data_system.elements[element_id]
    end
  end
  #--------------------------------------------------------------------------
  # ○ ダメージの描画　スキル
  #--------------------------------------------------------------------------
  def draw_damage(x, y, item)
    change_color(system_color)
    #change_color(important_color)
    width = 100
    base = "Base"
    base += item.magni? ? "X" : (item.for_friend? ? "Recovery" : "Might" )
    draw_text(x, line_height * y, width, line_height, base) #if item.base != 0
    #draw_text(x, line_height * (y + 1), width, line_height, "スキルLv上昇") if item.plus != 0
    #draw_text(x, line_height * (y + 2), width, line_height, "現在の数値") if item.base != 0
    draw_text(x + width * 1, line_height * y, width, line_height, "Skill LV")
    draw_text(x + width * 2, line_height * y, width, line_height, "Current") #if item.base != 0
    lv_max = item.base + item.plus * 3
    lv_max = lv_max.round(2) if item.magni?
    now = lv_max
    now = item.base + item.plus * (@actor.skill_lv(item.id) - 1) if @actor
    now = now.round(2) if item.magni?
    change_color(normal_color)
    num_width = 48
    draw_text(x + 10, line_height * (y + 1), num_width, line_height, item.base, 2) #if item.base != 0
    #draw_text(x + width, line_height * (y + 1), num_width, line_height, item.plus, 2) if item.plus != 0
    draw_text(x + 10 + width * 1, line_height * (y + 1), num_width, line_height, item.plus > 0 ? item.plus : "None", 2) #if item.plus != 0
    change_color(important_color)
    #draw_text(x + width, line_height * (y + 2), num_width, line_height, now, 2) if item.base != 0
    draw_text(x + width * 2, line_height * (y + 1), num_width, line_height, now, 2) #if item.base != 0
    change_color(system_color)
    draw_text(x + width * 2 + num_width, line_height * (y + 1), 48, line_height, "MAX") if item.plus != 0 && now == lv_max
    change_color(normal_color)
  end
=begin
  #--------------------------------------------------------------------------
  # ○ 効果範囲を変換
  #--------------------------------------------------------------------------
  def scope_change_usable(scope, random_change, random_plus)
    case scope
    when 0  ; "なし"
    when 1  ; "敵単体"
    when 2  ; "敵全体"
    when 3..6
      num = (scope - 2 + random_plus).to_s.tr('0-9','０-９')
      random_change ? "敵#{num}体" : "ランダム#{num}回"
    when 7  ; "味方単体"
    when 8  ; "味方全体"
    when 9  ; "味方単体(戦闘不能)"
    when 10 ; "味方全体(戦闘不能)"
    else    ; "使用者"
    end
  end
=end
  #--------------------------------------------------------------------------
  # ○ その他の説明の描画
  #--------------------------------------------------------------------------
  def draw_another(x, y, item)
    if item.is_a?(RPG::Skill) && item.summon_unit_id
      change_color(normal_color)
      summon = $game_actors[item.summon_unit_id]
      summon.summon_level_set($game_actors[1].level) if summon.level != $game_actors[1].level
      draw_actor_simple_status(summon, x, y)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 水平線の描画
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # ● 水平線の色を取得
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # ● アクターウィンドウの設定
  #--------------------------------------------------------------------------
  def actor_window=(actor_window)
    @actor_window = actor_window
    update
  end
  #--------------------------------------------------------------------------
  # ● アクターウィンドウの設定
  #--------------------------------------------------------------------------
  def category_window=(category_window)
    @category_window = category_window
    update
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def update
    super
    window_off
  end
  #--------------------------------------------------------------------------
  # ● ページの更新
  #--------------------------------------------------------------------------
  def update_page
    if window_change
      Sound.play_cursor
      self.visible ^= true
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの変更トリガー
  #--------------------------------------------------------------------------
  def window_change
    Input.trigger?(:Z) && !@actor_window.visible && @category_window.close?
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの非表示化設定
  #--------------------------------------------------------------------------
  def window_off
    if @actor_window && @category_window
      self.visible = false if !@category_window.close?
      self.visible = false if @actor_window.visible
    end
  end
end

#==============================================================================
# ■ Window_ItemList
#------------------------------------------------------------------------------
# 　アイテム画面で、所持アイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :item_status_window            # アイテムステータスウィンドウ
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  def item_status_window=(item_status_window)
    @item_status_window = item_status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  alias is_update_help update_help
  def update_help
    is_update_help
    @item_status_window.item = item if @item_status_window
    alignment_window
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def alignment_window
    return if !@item_status_window
    @item_status_window.x = ((index % 2) == 0 ? Graphics.width / 2 : 0)
  end
end

#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　アイテム画面の処理を行うクラスです。
#==============================================================================

class Scene_Item < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias is_start start
  def start
    is_start
    create_item_status_window
  end
  #--------------------------------------------------------------------------
  # ○ アイテムステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_status_window
    wy = @help_window.height
    wh = Graphics.height - wy
    @item_status_window = Window_ItemStatus.new(0, wy, Graphics.width / 2, wh)
    @item_status_window.category_window = @category_window
    @item_status_window.actor_window = @actor_window
    @item_window.item_status_window = @item_status_window
    #@actor_window.height = Graphics.height - @help_window.height
    #@actor_window.y = @help_window.height
    #@help_window.viewport = nil
  end
end




#==============================================================================
# □ Window_ItemStatus
#------------------------------------------------------------------------------
# 　アイテム画面で、アイテムの能力値を表示するウィンドウです。
#==============================================================================

class Window_ItemStatus_Skill < Window_ItemStatus
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの変更トリガー
  #--------------------------------------------------------------------------
  def window_change
    Input.trigger?(:Z) && !@actor_window.visible && !@category_window.active
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの非表示化設定
  #--------------------------------------------------------------------------
  def window_off
    if @actor_window && @category_window
      self.visible = false if @category_window.active
      self.visible = false if @actor_window.visible
    end
  end
end

#==============================================================================
# ■ Window_SkillList
#------------------------------------------------------------------------------
# 　スキル画面で、使用できるスキルの一覧を表示するウィンドウです。
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :item_status_window            # アイテムステータスウィンドウ
  #--------------------------------------------------------------------------
  # ○ ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  def item_status_window=(item_status_window)
    @item_status_window = item_status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  alias is_update_help update_help
  def update_help
    is_update_help
    @item_status_window.item = item if @item_status_window
    alignment_window
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def alignment_window
    return if !@item_status_window
    @item_status_window.x = ((index % 2) == 0 ? Graphics.width / 2 : 0)
  end
end


#==============================================================================
# ■ Scene_Skill
#------------------------------------------------------------------------------
# 　スキル画面の処理を行うクラスです。処理共通化の便宜上、スキルも「アイテム」
# として扱っています。
#==============================================================================

class Scene_Skill < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias is_start start
  def start
    is_start
    create_item_status_window
  end
  #--------------------------------------------------------------------------
  # ○ アイテムステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_status_window
    wy = @help_window.height
    wh = Graphics.height - wy
    @item_status_window = Window_ItemStatus_Skill.new(0, wy, Graphics.width / 2, wh)
    @item_status_window.category_window = @command_window
    @item_status_window.actor_window = @actor_window
    @item_status_window.actor = @actor
    @item_window.item_status_window = @item_status_window
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  alias item_status_on_actor_change on_actor_change
  def on_actor_change
    @item_status_window.actor = @actor
    item_status_on_actor_change
  end
end


#==============================================================================
# □ Window_ItemStatus
#------------------------------------------------------------------------------
# 　アイテム画面で、アイテムの能力値を表示するウィンドウです。
#==============================================================================

class Window_BattleItemStatus < Window_ItemStatus_Skill
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :item_window            # メニューアクターウィンドウ
  attr_reader   :skill_window         # カテゴリーウィンドウ
  #--------------------------------------------------------------------------
  # ● アクターウィンドウの設定
  #--------------------------------------------------------------------------
  def item_window=(item_window)
    @item_window = item_window
    update
  end
  #--------------------------------------------------------------------------
  # ● アクターウィンドウの設定
  #--------------------------------------------------------------------------
  def skill_window=(skill_window)
    @skill_window = skill_window
    update
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの変更トリガー
  #--------------------------------------------------------------------------
  def window_change
    Input.trigger?(:Z) && (@item_window.visible || @skill_window.visible)
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウの非表示化設定
  #--------------------------------------------------------------------------
  def window_off
    if @item_window && @skill_window
      self.visible = false if !@item_window.visible && !@skill_window.visible
    end
  end
end


#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成
  #--------------------------------------------------------------------------
  alias item_status_create_all_windows create_all_windows
  def create_all_windows
    item_status_create_all_windows
    create_item_status_window
  end
  #--------------------------------------------------------------------------
  # ○ アイテムステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_status_window
    wy = @help_window.height
    wh = Graphics.height - wy
    @item_status_window = Window_BattleItemStatus.new(0, wy, Graphics.width / 2, wh)
    @item_status_window.item_window = @item_window
    @item_status_window.skill_window = @skill_window
    @item_window.item_status_window = @item_status_window
    @skill_window.item_status_window = @item_status_window
  end
  #--------------------------------------------------------------------------
  # ● コマンド［スキル］
  #--------------------------------------------------------------------------
  alias item_status_command_skill command_skill
  def command_skill
    @item_status_window.actor = BattleManager.actor
    item_status_command_skill
  end
end


class RPG::Skill < RPG::UsableItem
  def remove_hide
    @remove_hide ||= remove_hide_set
  end
  def remove_hide_set
    self.note =~ /\<状態解除非表示\>/
  end
end

class RPG::BaseItem
  def kana
    @kana ||= kana_set
  end
  def kana_set
    self.note =~ /\<読み仮名:([^>]*)\>/ ? $1 : ""
  end
end
