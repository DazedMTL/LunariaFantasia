#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　ゲーム中の全てのウィンドウのスーパークラスです。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ○ 外すの描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_nil_name(x, y, enabled = true, width = 172)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, "外す")
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def teleport_map_name(id)
    TelepoMap::NAME[id]
  end
  #--------------------------------------------------------------------------
  # ○ アイテム名やスキル名をデータベースから参照して記述
  #　　　アイコンの有無も選べる
  #--------------------------------------------------------------------------
  def item_draw_in_text(type, id, icon = true)
    text = ""
    case type.upcase
    when "I"
      text = "\eI\[#{$data_items[id].icon_index}\]" if icon
      return text + $data_items[id].name
    when "A"
      text = "\eI\[#{$data_armors[id].icon_index}\]" if icon
      return text + $data_armors[id].name
    when "W"
      text = "\eI\[#{$data_weapons[id].icon_index}\]" if icon
      return text + $data_weapons[id].name
    when "S"
      text = "\eI\[#{$data_skills[id].icon_index}\]" if icon
      return text + $data_skills[id].name
    when "ST"
      text = "\eI\[#{$data_states[id].icon_index}\]" if icon
      return text + $data_states[id].name
    when "EL"
      return $data_system.elements[id]
    when "E"
      return $data_enemies[id].name
    else
      return $data_enemies[id].name
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテムやスキルの説明をデータベースから参照して記述
  #--------------------------------------------------------------------------
  def item_description_in_text(type, id, event = true)
    text = ""
    case type.upcase
    when "I"
      text = $data_items[id].description.clone
    when "A"
      text = $data_armors[id].description.clone
    when "W"
      text = $data_weapons[id].description.clone
    when "S"
      text = $data_skills[id].description.clone
    else
      text = $data_items[id].description.clone
    end
    text.gsub!(/\\/)             { "\e" } if event
    text.gsub!(/\e\e/)           { "\\" } if event
    text.gsub!(/\e{/)            { "" } if event
    text.gsub!(/\e}/)            { "" } if event
    if text =~ /習得可能スキル\r\n/
      text.gsub!(/習得可能スキル\r\n/) {"\e>習得可能スキル\r\n"}     if event
      text.gsub!(/\r\n/)           {"\r\n\e>"} if event
    else
      text.gsub!(/習得可能スキル/) {"\e>習得可能スキル\r\n"}     if event
      text.gsub!(/\r\n/)           {"\r\n\e>"} if event
    end
    return text
  end
  #--------------------------------------------------------------------------
  # ○ 装備アイテムのパラメーター取得
  #--------------------------------------------------------------------------
  def item_params(type, id, param)
    pr = ""
    case type.upcase
    when "A"
      pr = param == 8 ? $data_armors[id].soul_plus : $data_armors[id].params[param]
    when "W"
      pr = param == 8 ? $data_weapons[id].soul_plus : $data_weapons[id].params[param]
    else
      pr = param == 8 ? $data_armors[id].soul_plus : $data_armors[id].params[param]
      #pr = "#{$data_armors[id].params[param]}".tr("0-9","０-９")
    end
    return "#{pr}".tr("0-9","０-９")
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def learning_name(text)
    c_text = text.clone
    c_text.slice!(/学習「/)
    c_text.slice!(/」$/)
    return c_text
  end
  
  
  #--------------------------------------------------------------------------
  # ○ 最強武具の素材取得
  #--------------------------------------------------------------------------
  def a_material(id, type)
    am = ""
    case type
    when "w" ; item = FAKEREAL::ALTIMET_WEAPON[id]
    when "a" ; item = FAKEREAL::ALTIMET_ARMOR[id]
    end
    item.each_with_index do |a, i|
      am += "\n　" if i == 3
      am += material_item_change(a)
    end
    return am
  end
  #--------------------------------------------------------------------------
  # ○ 最強武具の名前取得
  #--------------------------------------------------------------------------
  def a_name(id, type)
    case type
    when "w" ; item = $data_weapons[id]
    when "a" ; item = $data_armors[id]
    end
    item ? "\edbi[#{type},#{id}]" : ""
  end
  #--------------------------------------------------------------------------
  # ○ 最強武具の素材のスクリプト配列を素材名と必要数/所持数に変換
  #--------------------------------------------------------------------------
  def material_item_change(ary)
    case ary[0]
    when 0 
      num = $game_party.item_number($data_items[ary[1]])
      return "\edbi[i,#{ary[1]}]×#{ary[2]}/#{num} "
    when 1 
      num = $game_party.item_number($data_weapons[ary[1]])
      return "\edbi[w,#{ary[1]}]×#{ary[2]}/#{num} "
    when 2 
      num = $game_party.item_number($data_armors[ary[1]])
      return "\edbi[a,#{ary[1]}]×#{ary[2]}/#{num} "
    else 
      return ""
    end
  end
  
  
  #--------------------------------------------------------------------------
  # ○ 手動センタリング
  #　　num1:全角文字数　num2:半角文字数
  #--------------------------------------------------------------------------
  def centering(num1, num2 = 0)
    text = ""
    w = (18 * num1 + 10 * num2) / 2
    center_x = contents.width / 2 - w
    (center_x / 18).times do
      text += "　"
    end
    text += " " if center_x % 18 > 9
    #(center_x % 18 / 10.to_i).times do
    #  text += " "
    #end
    return text
  end
  #--------------------------------------------------------------------------
  # ○ 文字の先頭を指定した数だけ取り出す
  #　　
  #--------------------------------------------------------------------------
  def cut_text_start(text, num)
    return text.slice!(0, num)
  end
  #--------------------------------------------------------------------------
  # ○ 文字の先頭を指定した数だけ切り取る
  #　　
  #--------------------------------------------------------------------------
  def cut_text_end(text, num)
    text.slice!(0, num)
    return text
  end
  #--------------------------------------------------------------------------
  # ○ 間の一文字を切り取る
  #--------------------------------------------------------------------------
  def cut_text_abs(text, num)
    return text.slice!(num, 1)
  end
  #--------------------------------------------------------------------------
  # ○ フォントを大きくする
  #--------------------------------------------------------------------------
  def make_font_bigger_extra
    contents.font.size += 4 if contents.font.size <= 64
  end
  #--------------------------------------------------------------------------
  # ○ フォントを小さくする
  #--------------------------------------------------------------------------
  def make_font_smaller_extra
    contents.font.size -= 4 if contents.font.size >= 16
  end
  #--------------------------------------------------------------------------
  # ● 制御文字の処理　※再定義
  #     code : 制御文字の本体部分（「\C[1]」なら「C」）
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'C'
      change_color(text_color(obtain_escape_param(text)))
    when 'I'
      process_draw_icon(obtain_escape_param(text), pos)
    when '{'
      make_font_bigger_extra
    when '}'
      make_font_smaller_extra
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def base_attack(id)
    "Base ATK:#{$data_skills[id].base}"
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def base_magnification(id)
    "Base X:#{$data_skills[id].base}"
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def plus_number(id)
    "Added:#{$data_skills[id].plus}"
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def base_heal(id)
    "Recovery:#{$data_skills[id].base}"
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def party_param(member, param_id)
    case param_id
    when 0 ; "HP" + "#{$game_party.members[member - 1].hp}"
    when 1 ; "MP" + "#{$game_party.members[member - 1].mp}"
    when 8 ; "SP" + "#{$game_party.members[member - 1].tp}"
    else ; Vocab::param(param_id) + "#{$game_party.members[member - 1].param(param_id)}"
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def key_button(name)
    FAKEREAL::BUTTON[name.upcase][$game_variables[Option::Button]]
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def extra_h
    $game_temp.extra_h
  end
  #--------------------------------------------------------------------------
  # ● 各種文字色の取得
  #--------------------------------------------------------------------------
  def important_color;      text_color(FAKEREAL::IMP);   end;    # 通常
  #--------------------------------------------------------------------------
  # ● 制御文字の事前変換
  #    実際の描画を始める前に、原則として文字列に変わるものだけを置き換える。
  #    文字「\」はエスケープ文字（\e）に変換。
  #--------------------------------------------------------------------------
  alias fakereal_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    result = fakereal_convert_escape_characters(text)
    result.gsub!(/\eID\[(\w+)\,(\d+)\]/i)  { item_description_in_text($1, $2.to_i, true) }
    result.gsub!(/\ePR\[(\d+)\]/i)   { Vocab::param($1.to_i) }
    result.gsub!(/\eSK\[(\d+)\]/i)   { $data_system.skill_types[$1.to_i] }
    result.gsub!(/\eHP/i)            { Vocab::hp }
    result.gsub!(/\eMP/i)            { Vocab::mp }
    result.gsub!(/\eTP/i)            { Vocab::tp }
    result.gsub!(/\eAP/i)            { Vocab::ap_ex }
    result.gsub!(/\eBA\[(\d+)\]/i)            { base_attack($1.to_i) }
    result.gsub!(/\eBM\[(\d+)\]/i)            { base_magnification($1.to_i) }
    result.gsub!(/\ePL\[(\d+)\]/i)            { plus_number($1.to_i) }
    result.gsub!(/\eHL\[(\d+)\]/i)            { base_heal($1.to_i) }
    result.gsub!(/\ePPR\[(\d+),(\d+)\]/i)     { party_param($1.to_i, $2.to_i) }
    result.gsub!(/\eIPR\[(\w),(\d+),(\d+)\]/i) { item_params($1, $2.to_i, $3.to_i) }
    result.gsub!(/\eHT/i)            { "\eI\[122\]" }
    result.gsub!(/\eIMP/i)           { "\eC\[#{FAKEREAL::IMP}\]" }
    result.gsub!(/\eKB\[(\w+)\]/i)   { key_button($1) }
    result.gsub!(/\eMC\[(\w+)\]/i)   { FAKEREAL::MEMORY_C[$1] }
    result.gsub!(/\eKW\[(\d+)\]/i)   { FAKEREAL::KEYWORD[$1.to_i][0] }
    result.gsub!(/\eKWC\[(\d+)\]/i)  { "\eC\[#{FAKEREAL::KEYWORD[$1.to_i][1]}\]" + FAKEREAL::KEYWORD[$1.to_i][0] + "\eC\[0\]" }
    
    result.gsub!(/\eAM\[(\d+)\,(\w+)\]/i)  { a_material($1.to_i, $2) }
    result.gsub!(/\eAN\[(\d+)\,(\w+)\]/i)  { a_name($1.to_i, $2) }
    result.gsub!(/\eAWLP\[(\d+)\]/i) { FAKEREAL::AW_LP_PLICE[$1.to_i][0] }
    result.gsub!(/\eAWAN\[(\d+)\]/i) { $game_actors[FAKEREAL::AW_LP_PLICE[$1.to_i][1]].name }
    result.gsub!(/\eAALP\[(\d+)\]/i) { FAKEREAL::AA_LP_PLICE[$1.to_i][0] }
    result.gsub!(/\eAAAN\[(\d+)\]/i) { $game_actors[FAKEREAL::AA_LP_PLICE[$1.to_i][1]].name }
    
    result.gsub!(/\eDB\[(\w+)\,(\d+)\]/i)  { item_draw_in_text($1, $2.to_i, false) }
    result.gsub!(/\eDBI\[(\w+)\,(\d+)\]/i) { item_draw_in_text($1, $2.to_i, true) }
    result.gsub!(/\eLN\[(\eI\[\w+\]\W+)\]/i)  { learning_name($1) }
    
    result.gsub!(/\eTMAP\[(\d+)\]/i) { teleport_map_name($1.to_i) }
    result.gsub!(/\eEXH/i)           { extra_h }
    result.gsub!(/\eTS\[(\D+?)\,(\d+)\]/i)   { cut_text_start($1, $2.to_i) }
    result.gsub!(/\eTE\[(\D+?)\,(\d+)\]/i)   { cut_text_end($1, $2.to_i) }
    result.gsub!(/\eTA\[(\D+?)\,(\d+)\]/i)   { cut_text_abs($1, $2.to_i) }
    result.gsub!(/\eCA\[(\d+)\,?(\d*?)\]/i)   { centering($1.to_i, $2.to_i) }
    result
  end
=begin
  def convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)             { "\e" }
    result.gsub!(/\e\e/)           { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i)  { $game_variables[$1.to_i] }
    result.gsub!(/\eN\[(\d+)\]/i)  { actor_name($1.to_i) }
    result.gsub!(/\eP\[(\d+)\]/i)  { party_member_name($1.to_i) }
    result.gsub!(/\ePR\[(\d+)\]/i) { Vocab.param($1.to_i) }
    result.gsub!(/\eG/i)           { Vocab::currency_unit }
    result.gsub!(/\eBA/i)          { "基本威力" }
    result.gsub!(/\ePL/i)          { "スキルLv上昇" }
    result.gsub!(/\eHL/i)          { "基本回復値" }
    result
  end
=end
end


module FAKEREAL
  
  SEX_POINT_NAME = "淫性値"
  
  KEYWORD      = { 0 => ["魔力吸収率",14],
                   1 => ["魔力吸収",14],
                   2 => [SEX_POINT_NAME,24],
                   3 => ["リアトリス",0],#大陸の名前
                   4 => ["ピオニーナイツ",0],#フィリカ直属の親衛隊
                   5 => ["",0],
                   6 => ["",0],
                   7 => ["",0],
                   8 => ["",0],
                   9 => ["",0],
                  10 => ["",0],
                  11 => ["ブロンズランク",0],#闘技場ランク１
                  12 => ["ゴールドランク",0],#闘技場ランク２
  
                                  }
  
  IMP = 14
  
  BUTTON       = { "SHIFT" => ["SHIFTキー", "Aボタン", "ボタン1"],
                   "X"     => ["Xキー", "Bボタン", "ボタン2"],
                   "Z"     => ["Zキー", "Cボタン", "ボタン3",],
                   "A"     => ["Aキー", "Xボタン", "ボタン4"],
                   "S"     => ["Sキー", "Yボタン", "ボタン5"],
                   "D"     => ["Dキー", "Zボタン", "ボタン6"],
                   "Q"     => ["Qキー", "Lボタン", "ボタン7"],
                   "W"     => ["Wキー", "Rボタン", "ボタン8"],
                   "ALT"   => ["ALTキー","ALTキー","ALTキー"],
                   "CTRL"  => ["CTRLキー","CTRLキー","CTRLキー"],
                   "F5"    => ["F5キー","F5キー","F5キー"]
  
                                  }
  
  MEMORY_C      = {"sentou01" => "\ekw[2]１００・絶頂４０・セクハラ１０以上",
                   "sentou02" => "処女を喪失している・女湯更衣室で銭湯の鍵を拾っている",
                   "sentou03" => "『ラグラス４』『カクタス４』『カクタス５』を見ている",
                   "cactus01" => "娼館で個室対応した事がある",
                   "cactus02" => "\ekw[2]６５・フェラ５・セクハラ１０・セックス４以上",
                   "cactus03" => "\ekw[2]８０以上",
                   "cactus04" => "『カクタス３』を見ている",
                   "true01a"   => "\ekw[0]０・\ekw[2]０の状態(Hステータス全て０)で",
                   "true01b"   => "宝玉を５つ集める",
                   "true02"   => "高潔ルートのストーリー強制イベント",
                                  }
  
end

#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :extra_h                # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias exh_initialize initialize
  def initialize
    exh_initialize
    extra_h_init
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def extra_h_init
    @extra_h = ""
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def extra_h_add(t)
    @extra_h += t + "　"
  end
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def exh_add(t)
    $game_temp.extra_h_add(t)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def exh_init
    $game_temp.extra_h_init
  end
end