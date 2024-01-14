module FAKEREAL
  BOOK_EXTEND = 116 # 図鑑拡張フラグ
  NO_RECORD   = 117 # このスイッチオンの間は戦闘で魔物図鑑に登録しない
end

#==============================================================================
# □ Window_BookList
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_BookList < Window_Selectable
  include FRZB
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :detail_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(y, height)
    super(0, y, window_width, height)
    @category = :none
    @data = []
  end
  #--------------------------------------------------------------------------
  # ● カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def window_width
    160
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● アイテムの取得
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # ○ クエストを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if !item
    case @category
    when :character
      $game_system.book["character"][item]
    when :monster
      $game_system.book["monster"][item[0]]
    when :quest
      enable_quest(item[1], item[11])
    end
  end
  #--------------------------------------------------------------------------
  # ○ サブクエストの許可状態判定 v = 変数
  #--------------------------------------------------------------------------
  def enable_quest(v, c)
    $game_system.book["quest"][v]
  end
  #--------------------------------------------------------------------------
  # ○ アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    case @category
    when :character
      Book::CHARA.each {|k,v| @data.push(k) if $game_system.book["character"][k] }
    when :monster
      @data = $game_temp.monster_book
      @data += $game_temp.true_monster_book if $game_switches[FAKEREAL::BOOK_EXTEND]
    when :quest
      @data = $game_temp.sub_quest
      @data += $game_temp.true_quest if $game_switches[FAKEREAL::BOOK_EXTEND]
      @data.sort! {|a, b| a[0] - b[0]}
    else
      #@data.push(nil)
    end
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item && enable?(item)
      rect = item_rect(index)
      case @category
      when :character
        if Book::CHARA[item][7] <= $game_system.book["character"][item]
          draw_text(4, rect.y, contents_width, line_height, Book::CHARA[item][0])
        else
          draw_text(4, rect.y, contents_width, line_height, "???")
        end
      when :monster
        draw_text(4, rect.y, contents_width, line_height, $data_enemies[item[0]].name)
      when :quest
        draw_quest(index, item)
      end
    else
      rect = item_rect(index)
      draw_text(4, rect.y, 152, line_height, "??????")
    end
  end
  #--------------------------------------------------------------------------
  # ○ クエストの描画
  #--------------------------------------------------------------------------
  def draw_quest(index, item)
    rect = item_rect(index)
    draw_text(-8, rect.y, 152, line_height, "Quest No.#{format("%02d",item[0])}", 1)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウ更新メソッドの呼び出し
  #--------------------------------------------------------------------------
  def call_update_help
    update_help if active && @detail_window && @help_window
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    case @category
    when :character
      @detail_window.set_item(enable?(item) ? Book::CHARA[item] : nil)
      @help_window.set_item(enable?(item) ? item : nil)
    when :monster
      @detail_window.set_number(index) ##
      @detail_window.set_item(enable?(item) ? item : nil)
    when :quest
      @detail_window.set_item(item)
    end
    @detail_window.category = @category
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def detail_window=(detail_window)
    @detail_window = detail_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ○ 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def ex_current_item_enabled?
    true #@category == :character
  end
  #--------------------------------------------------------------------------
  # ○ Zのハンドリング処理の追加
  #--------------------------------------------------------------------------
  def process_handling
    super
    return unless active
    return process_z if z_enabled? && Input.trigger?(:Z)
  end
end

#==============================================================================
# ■ Window_
#------------------------------------------------------------------------------
#　
#==============================================================================

class Window_BookHelp < Window_Help
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(line_number = 4)
    super(line_number)
    self.width = window_width
    self.x = Graphics.width - window_width
    self.y = Graphics.height - self.height
    self.opacity = 0
    self.arrows_visible = false
    @category = :none
    @flag = true
    refresh
  end
  #--------------------------------------------------------------------------
  # ● カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ○ 文字の大きさを設定
  #--------------------------------------------------------------------------
  def font_size
    return 20
  end
  #--------------------------------------------------------------------------
  # ● 行の高さを取得
  #--------------------------------------------------------------------------
  def line_height
    return font_size
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def window_width
    480
  end
  #--------------------------------------------------------------------------
  # ● アイテム設定
  #     item : スキル、アイテム等
  #--------------------------------------------------------------------------
  def set_item(item)
    it = Book::TEXT[item]
    set_text(it ? it[$game_system.book["character"][item]] : "")
  end
  #--------------------------------------------------------------------------
  # ○ 背景の描画
  #--------------------------------------------------------------------------
  def draw_background(rect)
    contents.fill_rect(rect, back_color)
  end
  #--------------------------------------------------------------------------
  # ○ 背景色の取得
  #--------------------------------------------------------------------------
  def back_color
    Color.new(0, 0, 0, 192)
  end
  #--------------------------------------------------------------------------
  # ● 制御文字つきテキストの描画
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    contents.font.size = font_size
    if @category == :character 
      self.visible = @flag
      draw_background(contents.rect)
      draw_text_ex(4, 0, @text)
    else
      self.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def flag_change
    @flag ^= true
    refresh
  end
end

#==============================================================================
# ■ Window_QuestDetail
#------------------------------------------------------------------------------
#　
#==============================================================================

class Window_BookDetail < Window_Base
  include QuestConfig
  #--------------------------------------------------------------------------
  # ● 定数
  #--------------------------------------------------------------------------
  FEATURE_ELEMENT_RATE  = 11              # 属性有効度
  FEATURE_DEBUFF_RATE   = 12              # 弱体有効度
  FEATURE_STATE_RATE    = 13              # ステート有効度
  FEATURE_STATE_RESIST  = 14              # ステート無効化
  FEATURE_XPARAM        = 22              # 追加能力値
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(y, line_number = 17)
    super(Graphics.width - window_width, y, window_width, fitting_height(line_number))
    @category = :none
    @flag = true
    @number = 0 ##
    @page = []
    @page_index = 0
    @item = {}
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def flag_change
    @flag ^= true
    refresh
  end
  #--------------------------------------------------------------------------
  # ● カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ● クリア
  #--------------------------------------------------------------------------
  def clear
    contents.clear
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def window_width
    480
  end
  #--------------------------------------------------------------------------
  # ● アイテム設定
  #     item : スキル、アイテム等
  #--------------------------------------------------------------------------
  def set_item(item)
    if item != @item
      @item = item
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム設定
  #     item : スキル、アイテム等
  #--------------------------------------------------------------------------
  def set_number(number) ##
    @number = number
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def draw_item(item)
    draw_enemy_number(0, line_height * 0) if @category == :monster
    return unless item 
    case @category
    when :character
    #if item.is_a?(Hash)
      #人物
      draw_stand(item[1],item[2],0,0,item[8] ? item[8] : 50)
      draw_data(item)
    when :monster
    #elsif item[0].is_a?(Numeric)
      #魔物
      enemy = $data_enemies[item[0]]
      draw_battler(enemy, 0, 0)
      draw_enemy_data(enemy, item[1]) if @flag
    when :quest
      draw_quest(item)
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # 〇 通常文字の処理　
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    text_width = text_size(c).width
    th = text_size(c).height
    ty = 24 > th ? 24 - th - 2 : 0
    draw_text(pos[:x], pos[:y] + ty, text_width * 2, pos[:height], c)
    pos[:x] += text_width
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_item(@item)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def page_next
    @page_index += 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def page_prev
    @page_index -= 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def page_max
    @page.size
  end
  #--------------------------------------------------------------------------
  # ○ 人物データの描画
  #--------------------------------------------------------------------------
  def draw_data(item)
    change_color(important_color)
    key = Book::CHARA.index(item)
    return unless key
    if item[7] <= $game_system.book["character"][key]
      draw_text(8, line_height * 0, contents_width, line_height, item[4])
    end
    change_color(system_color)
    draw_text(328, line_height * 2, contents_width, line_height, "Height:")
    if item[6]
      draw_text(354, line_height * 3, contents_width, line_height, "B:")
      draw_text(354, line_height * 4, contents_width, line_height, "W:")
      draw_text(354, line_height * 5, contents_width, line_height, "H:")
    end
    change_color(normal_color)
    key =item[5]
    draw_text(376, line_height * 2, contents_width, line_height, Person::BWH["#{key}_t"])
    if item[6]
      draw_text(376, line_height * 3, contents_width, line_height, (Person::BWH["#{key}_b"].to_s + "(" + Person::BWH["#{key}_c"] + ")"))
      draw_text(376, line_height * 4, contents_width, line_height, Person::BWH["#{key}_w"])
      draw_text(376, line_height * 5, contents_width, line_height, Person::BWH["#{key}_h"])
    end
  end
  #--------------------------------------------------------------------------
  # ○ グラフィックの描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_stand(name, cos, x, y, pos = 50, enabled = true)
    if !name.empty?
      bitmap = Cache.stand("#{name}_#{draw_costume_set(cos)}")
      wx = contents_width / 2 - bitmap.width / 2
      #rect = Rect.new(0, pos, contents_width + 400, contents_height) #Rect.new(stand_index % 4 * 96, stand_index / 4 * 96, item_width, 288)# / num, 288) #272 / num, 288)
      rect = Rect.new(0, pos, bitmap.width, contents_height) #Rect.new(stand_index % 4 * 96, stand_index / 4 * 96, item_width, 288)# / num, 288) #272 / num, 288)
      contents.blt(x + wx, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    else
      bitmap = Cache.picture("NO_IMAGE")
      wx = contents_width / 2 - bitmap.width / 2
      wy = contents_height / 2 - bitmap.height / 2
      rect = Rect.new(0, 0, contents_width + 200, contents_height) #Rect.new(stand_index % 4 * 96, stand_index / 4 * 96, item_width, 288)# / num, 288) #272 / num, 288)
      contents.blt(x + wx, y + wy, bitmap, rect, enabled ? 255 : translucent_alpha)
    end
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ○ 衣装の選定
  #--------------------------------------------------------------------------
  def draw_costume_set(cos)
    if cos.is_a?(Array)
      cos.each do |ary| 
        case ary[1]
        when "story"
          return ary[0] if ary[2] <= $game_variables[21]
        when "item"
          return ary[0] if $game_party.has_item?($data_items[ary[2]])
        else
          return ary[0]
        end
      end
    else
      return cos
    end
  end
  #--------------------------------------------------------------------------
  # ○ モンスターデータの描画
  #--------------------------------------------------------------------------
  def draw_enemy_data(enemy, base)
    draw_enemy_name(enemy, 8, line_height * 0)
    draw_enemy_params(enemy, base, 8, line_height * 1)
    draw_enemy_validity(enemy, 8, line_height * 11)
    draw_enemy_drop(enemy, 8, line_height * 15)
    draw_enemy_steal(enemy, 240, line_height * 15)
  end
  #--------------------------------------------------------------------------
  # ○ 図鑑Noの描画
  #--------------------------------------------------------------------------
  def draw_enemy_number(x, y)
    change_color(important_color)
    draw_text(x, y, 128, line_height, "No.#{format("%03d",@number + 1)}")
  end
  #--------------------------------------------------------------------------
  # ○ 魔物名の描画
  #--------------------------------------------------------------------------
  def draw_enemy_name(enemy, x, y)
    change_color(important_color)
    draw_text(x + 128, y, 248, line_height, enemy.name)
  end
  #--------------------------------------------------------------------------
  # ○ データの描画
  #--------------------------------------------------------------------------
  def draw_enemy_params(enemy, base, x, y)
    change_color(system_color)
    draw_text(x - 4, y, 72, line_height * 1, "LV")
    draw_text(x + 8, y + line_height * 2, 48, line_height, Vocab.hp)
    draw_text(x + 8, y + line_height * 3, 48, line_height, Vocab.mp)
    draw_text(x + 8, y + line_height * 4, 48, line_height, Vocab.tp)
    6.times {|i| draw_text(x + 300, y + line_height * (i + 2), 48, line_height, Vocab.param(i + 2)) }
    3.times {|i| draw_text(x + 300, y + line_height * (i + 8), 48, line_height, FAKEREAL.xparam(i)) }
    draw_text(x + 8, y + line_height * 6, 48, line_height, "EXP")
    draw_text(x + 8, y + line_height * 7, 48, line_height, "Money")
    draw_text(x + 8, y + line_height * 8, 48, line_height, "LP")
    id = enemy.id
    @page = [base]
    w_lv = $game_system.book["monster"][id]
    if w_lv && base < w_lv
      $game_temp.change_level_search(id, w_lv)
      $game_temp.enemy_change_level[id].keys.sort.each do |lv|
        @page.push(lv)
        break if w_lv == lv
      end
    end
    if @page_index >= page_max
      @page_index = 0
    elsif @page_index < 0
      @page_index = page_max - 1
    end
    @page.size.times do |i|
      change_color(normal_color, @page_index == i)
      draw_text(x + 60 + 36 * i, y, 24, line_height, @page[i], 1)
    end
    change_color(normal_color)
    #draw_text(x + 60, y, 36, line_height, @page[@page_index], 1)
    if @page_index == 0
      2.times {|i| draw_text(x + 56, y + line_height * (i + 2), 172, line_height, enemy.params[i] + enemy.param_plus[i]) }
      draw_text(x + 56, y + line_height * 4, 172, line_height, enemy.mtp)
      draw_text(x + 56, y + line_height * 6, 172, line_height, enemy.exp)
      draw_text(x + 56, y + line_height * 7, 172, line_height, enemy.gold)
      draw_text(x + 56, y + line_height * 8, 172, line_height, enemy.ap)
      6.times {|i| draw_text(x + 356, y + line_height * (i + 2), 172, line_height, enemy.params[i + 2]) }
      3.times {|i| draw_enemy_xparam(i, enemy, features_sum(FEATURE_XPARAM, i, enemy.features), enemy.params[6], x + 356, y + line_height * (i + 8)) }
    else
      params = $game_temp.change_level_search(id, @page[@page_index])
      2.times {|i| draw_text(x + 56, y + line_height * (i + 2), 172, line_height, params[i]) }
      draw_text(x + 56, y + line_height * 4, 172, line_height, params[8])
      3.times {|i| draw_text(x + 56, y + line_height * (i + 6), 172, line_height, params[i + 9]) }
      6.times {|i| draw_text(x + 356, y + line_height * (i + 2), 172, line_height, params[i + 2]) }
      3.times {|i| draw_enemy_xparam(i, enemy, features_sum(FEATURE_XPARAM, i, enemy.features), params[6], x + 356, y + line_height * (i + 8)) }
    end
  end
  #--------------------------------------------------------------------------
  # ○ の描画
  #--------------------------------------------------------------------------
  def draw_enemy_xparam(id, enemy, base, agi, x, y)
    data = 0.0
    case id
    when 0; data = enemy.hit_rate * (agi * FAKEREAL::HIT_RATE_BASE) * 0.01
    when 1; data = enemy.eva_rate * (agi * FAKEREAL::EVA_RATE_BASE) * 0.01
    when 2; data = enemy.cri_rate * agi * 0.01
    end
    draw_text(x, y, 172, line_height, "#{format("%.2f",(base + data) * 100)}")
  end
  #--------------------------------------------------------------------------
  # ○ 有効データの描画
  #--------------------------------------------------------------------------
  def draw_enemy_validity(enemy, x, y)
    change_color(system_color)
    draw_text(x, y + line_height * 0, 48, line_height, "Weakness")
    weak_set(enemy.features + pfo_set(enemy)).each_with_index do |icon, i|
      draw_icon(icon, x + 48 + i * 24, y + line_height * 0)
    end
    draw_text(x, y + line_height * 1, 48, line_height, "RES")
    guard_set(enemy.features + pfo_set(enemy)).each_with_index do |icon, i|
      draw_icon(icon, x + 48 + i * 24, y + line_height * 1)
    end
    draw_text(x, y + line_height * 2, 48, line_height, "Immune")
    resist_set(enemy.features + pfo_set(enemy)).each_with_index do |icon, i|
      draw_icon(icon, x + 48 + i * 24, y + line_height * 2)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 追加特徴のセット
  #--------------------------------------------------------------------------
  def pfo_set(enemy)
    pfo = []
    ft = []
    enemy.note.each_line do |line|
      case line
      when /\<エネミー特徴:LV(\d+)\s(\d+)(N)?\>/
        pfo.push($data_classes[$2.to_i]) if @page[@page_index] >= $1.to_i && (!$3 || $3 == "N")
      when /\<エネミー限定特徴:LV(\d+)\s(\d+)\>/
        pfo.push($data_classes[$2.to_i]) if @page[@page_index] == $1.to_i && (!$3 || $3 == "N")
      end
    end
    pfo.each {|obj| ft += obj.features }
    return ft
  end
  #--------------------------------------------------------------------------
  # ○ 落とすアイテムデータの描画
  #--------------------------------------------------------------------------
  def draw_enemy_drop(enemy, x, y)
    change_color(system_color)
    draw_text(x - 4, y, 172, line_height, "Dropped Items")
    change_color(normal_color)
    i = 1
    #enemy.drop_items.sort_by{|item| [-(item.denominator), item.data_id] }.each do |item|
    enemy.drop_items.sort_by{|item| item.denominator > 100 ? [item.denominator, item.data_id] : [-(item.denominator), item.data_id] }.each do |item|
      if item.kind > 0
        draw_item_name(item_object(item.kind, item.data_id), x + 44, y + line_height * i, true, 148)
        draw_d_percent(item.denominator, x, y + line_height * i)
        i += 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ パーセンテージの描画
  #--------------------------------------------------------------------------
  def draw_d_percent(per, x, y)
    if per <= 100
      draw_text(x, y, 48, line_height, "#{per}％")
    else
      draw_text(x, y, 48, line_height, "1/#{per}")
    end
  end
  #--------------------------------------------------------------------------
  # ○ 盗めるアイテムデータの描画
  #--------------------------------------------------------------------------
  def draw_enemy_steal(enemy, x, y)
    change_color(system_color)
    draw_text(x - 4, y, 172, line_height, "Stolen Items")
    change_color(normal_color)
    i = 1
    t = enemy.item_steal_total(@page[@page_index])
    d = 100
    enemy.item_steal_list(@page[@page_index]).sort{|a,b| b[2] - a[2]}.each do |item|
      if item[0] < 3
        #item[2] <= 20 ? change_color(important_color) : change_color(normal_color)
        draw_item_name(item_object(item[0] + 1, item[1]), x + 44, y + line_height * i, true, 148)
        per = (100.0 / t * item[2]).round
        per = d if i == enemy.item_steal_list(@page[@page_index]).size
        draw_d_percent(per, x, y + line_height * i)
      else
        draw_currency_value(item[1],Vocab::currency_unit, x + 44, y + line_height * i, 148)
        per = (100.0 / t * item[2]).round
        per = d if i == enemy.item_steal_list(@page[@page_index]).size
        draw_d_percent(per, x, y + line_height * i)
      end
      d -= per
      i += 1
    end
  end
  #--------------------------------------------------------------------------
  # ○ モンスターグラフィックの描画
  #--------------------------------------------------------------------------
  def draw_battler(enemy, x, y, enabled = true)
    bitmap = Cache.battler(enemy.battler_name, enemy.battler_hue)
    space = 0
    wx = contents_width / 2 - bitmap.width / 2
    wy = 350 / 2 - bitmap.height / 2 
    rect = Rect.new(0, 0, contents_width - space, contents_height) #Rect.new(stand_index % 4 * 96, stand_index / 4 * 96, item_width, 288)# / num, 288) #272 / num, 288)
    contents.blt(x + wx, y + wy, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● アイテムオブジェクトの取得
  #--------------------------------------------------------------------------
  def item_object(kind, data_id)
    return $data_items  [data_id] if kind == 1
    return $data_weapons[data_id] if kind == 2
    return $data_armors [data_id] if kind == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 通貨単位つき数値（所持金など）の描画
  #--------------------------------------------------------------------------
  def draw_currency_value(value, unit, x, y, width)
    cx = text_size(unit).width
    change_color(normal_color)
    draw_text(x, y, width - cx - 2, line_height, "#{value}#{unit}")
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  
  #--------------------------------------------------------------------------
  # ● 特徴オブジェクトの配列取得（特徴コードとデータ ID を限定）
  #--------------------------------------------------------------------------
  def features_with_id(code, id, features)
    features.select {|ft| ft.code == code && ft.data_id == id }
  end
  #--------------------------------------------------------------------------
  # ● 特徴値の総乗計算
  #--------------------------------------------------------------------------
  def features_pi(code, id, features)
    features_with_id(code, id, features).inject(1.0) {|r, ft| r *= ft.value }
  end
  #--------------------------------------------------------------------------
  # ● 属性有効度の取得
  #--------------------------------------------------------------------------
  def element_rate(element_id, features)
    features_pi(FEATURE_ELEMENT_RATE, element_id, features)
  end
  #--------------------------------------------------------------------------
  # ● 弱体有効度の取得
  #--------------------------------------------------------------------------
  def debuff_rate(param_id, features)
    features_pi(FEATURE_DEBUFF_RATE, param_id, features)
  end
  #--------------------------------------------------------------------------
  # ● ステート有効度の取得
  #--------------------------------------------------------------------------
  def state_rate(state_id, features)
    features_pi(FEATURE_STATE_RATE, state_id, features)
  end
  #--------------------------------------------------------------------------
  # ● 特徴の集合和計算
  #--------------------------------------------------------------------------
  def features_set(code, features)
    features.select {|ft| ft.code == code }.inject([]) {|r, ft| r |= [ft.data_id] }
  end
  #--------------------------------------------------------------------------
  # ● 特徴値の総和計算（データ ID を指定）
  #--------------------------------------------------------------------------
  def features_sum(code, id, features)
    features_with_id(code, id, features).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # ● 無効化するステートの配列を取得
  #--------------------------------------------------------------------------
  def state_resist_set(features)
    features_set(FEATURE_STATE_RESIST, features)
  end
  #--------------------------------------------------------------------------
  # ● 無効化されているステートの判定
  #--------------------------------------------------------------------------
  def state_resist?(state_id, features)
    state_resist_set(features).include?(state_id)
  end
  
  #--------------------------------------------------------------------------
  # ○ 敵の弱点属性配列
  #--------------------------------------------------------------------------
  def weak_set(features)
    weak = FRGP::ELEMENTS.select {|id| select_rule(id, features) } #features(FEATURE_ELEMENT_RATE).select{|ft| select_rule(ft) }
    weak.sort! {|a, b| element_rate(b, features) - element_rate(a, features) }
    list = []
    weak.each{|id| list.push(icon_number(id))}
    return list
  end
  #--------------------------------------------------------------------------
  # ○ 選別ルール
  #--------------------------------------------------------------------------
  def select_rule(id, features)#(ft)
    element_rate(id, features) > 1.0 && !FRGP::NO_ICON.include?(id) #&& (ft.data_id >= 3 && ft.data_id <= 10)
  end
  #--------------------------------------------------------------------------
  # ○ 敵の耐性配列
  #--------------------------------------------------------------------------
  def guard_set(features)
    elg = FRGP::ELEMENTS.select {|id| select_rule_guard(0, id, features) }
    st = [*(1..8), 26]
    stg = st.select {|id| select_rule_guard(1, id, features) }
    db = [*(2..7)]
    dbg = db.select {|id| select_rule_guard(2, id, features) }
    list = []
    elg.each do |id|
      list.push(icon_number(id))
    end
    stg.each do |i| 
      list.push($data_states[i].icon_index)
    end
    dbg.each do |i| 
      list.push(FRGP::ICON_DEBUFF_START + i)
    end
    return list
  end
  #--------------------------------------------------------------------------
  # ○ 選別ルール 耐性
  #--------------------------------------------------------------------------
  def select_rule_guard(type, id, features)#(ft)
    case type
    when 0
      element_rate(id, features) < 1.0 && element_rate(id, features) > 0 && !FRGP::NO_ICON.include?(id) #&& (ft.data_id >= 3 && ft.data_id <= 10)
    when 1
      state_rate(id, features) < 1.0 && state_rate(id, features) > 0
    when 2
      debuff_rate(id, features) < 1.0 && debuff_rate(id, features) > 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ 敵の無効配列
  #--------------------------------------------------------------------------
  def resist_set(features)
    elr = FRGP::ELEMENTS.select {|id| select_rule_resist(0, id, features) }
    st = [*(1..8), 26]
    str = st.select {|id| select_rule_resist(1, id, features) }
    db = [*(2..7)]
    dbr = db.select {|id| select_rule_resist(2, id, features) }
    list = []
    elr.each do |id|
      list.push(icon_number(id))
    end
    str.each do |i| 
      list.push($data_states[i].icon_index)
    end
    dbr.each do |i| 
      list.push(FRGP::ICON_DEBUFF_START + i)
    end
    return list
  end
  #--------------------------------------------------------------------------
  # ○ 選別ルール 無効
  #--------------------------------------------------------------------------
  def select_rule_resist(type, id, features)#(ft)
    case type
    when 0
      element_rate(id, features) == 0.0 && !FRGP::NO_ICON.include?(id) #&& (ft.data_id >= 3 && ft.data_id <= 10)
    when 1
      state_rate(id, features) == 0.0 || state_resist?(id, features)
    when 2
      debuff_rate(id, features) == 0.0
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイコン数値
  #--------------------------------------------------------------------------
  def icon_number(id)
    FRGP::ELEMENT_ICON[id]#ft.data_id]
  end

  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def draw_quest(item)
    return unless item 
      half = line_height / 2
      #サブクエスト処理
      change_color(system_color)
      draw_text(16, line_height * 2 + half, window_width, line_height, "Location")
      draw_text(16, line_height * 5, window_width, line_height, "Client:")
      draw_text(16, line_height * 6 + half, window_width, line_height, "Reward:")
      draw_text(16, line_height * 9, window_width, line_height, "Details")
      pr = $game_system.book["quest"][item[1]]
      title  = pr ? item[7] : item[7].gsub(/./) {"？"}
      lv     = pr ? item[6] : "？？"
      place  = pr ? item[3] : item[3].gsub(/./) {"？"}
      name   = pr ? item[4] : "？？？？" 
      reword = pr ? item[5] : "？？？？"
      if pr
        detail = item[8]
      else
        detail = "？？？？？？？？？？？？"
      end
      #クエスト名
      change_color(hp_gauge_color2)
      draw_text(4, line_height * 0, window_width, line_height, title)
      change_color(normal_color)
      #依頼種別
      draw_text(16, line_height * 1, window_width, line_height, "Request: #{item[2]}")
      #推奨Lv
      draw_text(180, line_height * 1, window_width, line_height, "Advised LV:#{lv}")
      l_text = ""
      if pr
        draw_text_ex(416, line_height * 0, heart(item[11]["h"])) if h_event?(item[11])
        l_text = "Deadline" if limit?(item[11])
      end
      change_color(normal_color)
      #受注状況
      text = pr ? "Cleared" : ""
      draw_text(320, line_height * 1, window_width, line_height, text)
      #場所
      draw_text(28, line_height * 3 + half, window_width, line_height, place)
      #依頼人
      draw_text_ex(84, line_height * 5, name)#(28, line_height * 5 + line_height / 2, name)#
      #報酬
      draw_text_ex(66, line_height * 6 + half, reword)
      #詳細
      draw_text_ex(28, line_height * 10, detail)
  end
  
end



#==============================================================================
# ■ Window_QuestCategory
#------------------------------------------------------------------------------
#　
#　
#==============================================================================

class Window_BookCategory < Window_ItemCategory_Extra
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Monster",     :monster)
    add_command("Character",     :character)
    add_command("Quest", :quest)
    add_command("Item", :item)
  end
  #--------------------------------------------------------------------------
  # ○ フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @help_window.category = current_symbol if @help_window
    @rate_window.category = current_symbol if @rate_window
  end
  #--------------------------------------------------------------------------
  # ○ アイテムウィンドウの設定
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    update
  end
  #--------------------------------------------------------------------------
  # ○ レートウィンドウの設定
  #--------------------------------------------------------------------------
  def rate_window=(rate_window)
    @rate_window = rate_window
    update
  end
end



#==============================================================================
# ■ Window_CollectionRate
#------------------------------------------------------------------------------
# 　図鑑収集率を表示するウィンドウです。
#==============================================================================

class Window_CollectionRate < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(Graphics.width - window_width, 0, window_width, fitting_height(1))
    self.y = Graphics.height - self.height
    @category = :none
    self.z = 600
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # ● カテゴリの設定
  #--------------------------------------------------------------------------
  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    unless @category == :none
      draw_collect_rate(4, 0, contents.width - 8, @category)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描画
  #--------------------------------------------------------------------------
  def draw_collect_rate(x, y, width, category)
    change_color(system_color)
    draw_text(x, y, width, line_height, "Total")
    tr = $game_switches[FAKEREAL::BOOK_EXTEND]
    rate = [collect_rate(@category, tr), 100].min
    if tr && rate == 100
      change_color(important_color)
      draw_text(x, y, width, line_height, "★#{rate}％", 2)
    else
      change_color(normal_color)
      draw_text(x, y, width, line_height, "#{rate}％", 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def collect_rate(category, true_route = false)
    case category
    when :monster   ; 100 * $game_system.book["monster"].size / collect_number_monster(true_route)
    #when :character ; 100 * $game_system.book["character"].values.inject(:+) / collect_number_chara(true_route)
    when :character ; 100 * book_collect_number_chara(true_route) / collect_number_chara(true_route)
    when :quest     ; 100 * $game_system.book["quest"].size / collect_number_quest(true_route)
    #when :item      ; 100 * $game_system.book["item"].size / collect_number_item(true_route)
    when :item      ; 100 * book_collect_number_item(true_route, $game_system.book["item"]) / collect_number_item(true_route)
    else            ; 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def collect_number_chara(true_route)
    x = 0
    Book::CHARA.keys.each do |k|
      size = Book::TEXT[k].select{|k2| k2.kind_of?(Integer) }.size 
      true_num = Book::TEXT[k][:true]
      x += chara_number_select(size, true_num, true_route)
    end
    return x
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def book_collect_number_chara(true_route)
    x = 0
    Book::CHARA.keys.each do |k|
      next if !$game_system.book["character"][k]
      if !true_route
        if Book::TEXT[k][:true] == 0
          x += $game_system.book["character"][k]
        else
          y = $game_system.book["character"][k]
          while y >= Book::TEXT[k][:true]
            y -= 1
          end
          #y -= 1 while y < Book::TEXT[k][:true]
          x += y
        end
      else
        x += $game_system.book["character"][k]
      end
    end
    return x
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def chara_number_select(size, true_num, true_route)
    return size if true_num == 0 || true_route
    x = 0
    size.times do |i|
      break if x == (true_num - 1)
      x += 1
    end
    return x
    #if true_num == 1
      #return size - true_num
    #else
      #x = 0
      #size.times do |i|
        #break if x == (true_num - 1)
        #x += 1
      #end
      #return x
    #end
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def collect_number_monster(true_route)
    data = $game_temp.monster_book
    data += $game_temp.true_monster_book if true_route
    return data.size
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def collect_number_quest(true_route)
    data = $game_temp.sub_quest
    data += $game_temp.true_quest if true_route
    return data.size
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def collect_number_item(true_route)
    data = []
    $game_temp.item_book.values.each {|v| data += v }
    return data.size
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def book_collect_number_item(true_route, item_hash)
    x = 0
    if !true_route
      item_hash.keys.each do |k|
        x += 1 if Book::TRUE_ITEM[k[0]].include?(k[1])
      end
    end
    return item_hash.size - x
  end
end
