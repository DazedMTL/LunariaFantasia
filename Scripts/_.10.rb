module FRMassage
  
  OP_TEXT = Hash[
    1 => ["遥か昔、絶大な力を持った最恐の魔神がいた", ""] ,
    
    2 => ["魔神は恐怖と絶望で人々の心を支配し", "この世の全てを手中に収めようと目論んだ", ""] ,

    3 => ["しかし", "その野望は五人の魔術師によって阻止される", ""] ,

    4 => ["後の世、『五大魔術師』と呼ばれる事になる", "その者達によって魔神は討伐されたのだ", ""] ,

    5 => ["魔神討伐後、五人は魔法王国を建国し", "リーダーであった男性が初代王に就任", "そしてその者の姓を取り、", "王国はサジタリーズと名付けられた", ""] ,
  
    6 => ["――それから1000年――", "これは、『魔法王国サジタリーズ』に仕える", "一人の女性宮廷魔術師の物語…", ""] ,
  
  
  
  
  ]
  
  
  
  
  
  
  
  #--------------------------------------------------------------------------
  # ● モジュールのインスタンス変数
  #--------------------------------------------------------------------------
  @pause_index = 0                # 
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def self.pause_index
    @pause_index
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def self.pause_index_plus(val = 1)
    if val == 0
      @pause_index = 0
    else
      @pause_index += val
    end
  end
  
  #--------------------------------------------------------------------------
  # ● アクター n 番の名前を取得
  #--------------------------------------------------------------------------
  def self.actor_name(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.name : ""
  end
  #--------------------------------------------------------------------------
  # ○ 文字の先頭を指定した数だけ取り出す
  #　　
  #--------------------------------------------------------------------------
  def self.cut_text_start(text, num)
    return text.slice!(0, num)
  end
  #--------------------------------------------------------------------------
  # ○ 文字の先頭を指定した数だけ切り取る
  #　　
  #--------------------------------------------------------------------------
  def self.cut_text_end(text, num)
    text.slice!(0, num)
    return text
  end
  #--------------------------------------------------------------------------
  # ○ 間の一文字を切り取る
  #--------------------------------------------------------------------------
  def self.cut_text_abs(text, num)
    return text.slice!(num, 1)
  end
  #--------------------------------------------------------------------------
  # ○ アイテムやスキルの説明をデータベースから参照して記述
  #--------------------------------------------------------------------------
  def self.item_description_in_text(type, id, event = true)
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
  # ○ アイテム名やスキル名をデータベースから参照して記述
  #　　　アイコンの有無も選べる
  #--------------------------------------------------------------------------
  def self.item_draw_in_text(type, id, icon = false)
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
  # ● ※オートモード等に対応
  #--------------------------------------------------------------------------
  def self.convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)              { "\e" }
    result.gsub!(/\e\e/)            { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i)   { $game_variables[$1.to_i] }
    result.gsub!(/\eQT\[(\d+)\]/i)  { Quest.title($1.to_i) }
    #result.gsub!(/\eQTT\[(\d+)\]/i) { Quest.true_title($1.to_i) }
    result.gsub!(/\eQKM\[(\d+)\]/i) { $game_party.kill_list($1.to_i)}
    result.gsub!(/\eQKMK\[(\w+)\]/i) { $game_party.kill_list($1)}
    result.gsub!(/\eQIN\[(\w+)\,(\d+)\]/i) { $game_party.quest_item_number($1, $2.to_i)}
    result.gsub!(/\eQR\[(\d+)\]/i)  { Quest.reword_text($1.to_i) }
    result.gsub!(/\eN\[(\d+)\]/i)   { "\e>" + "\eC\[#{Person::Color[$1.to_i]}\]" + actor_name($1.to_i) + "\eC\[0\]" }
    result.gsub!(/\eNT\[(\d+)\]/i)  { actor_name($1.to_i) }
    result.gsub!(/\eKP\[(\d+)\]/i)  { "\e>" + "\eC\[#{Person::Name[$1.to_i][1]}\]" + Person::Name[$1.to_i][0] + "\eC\[0\]" }
    result.gsub!(/\eKPT\[(\d+)\]/i) { Person::Name[$1.to_i][0] }
    result.gsub!(/\eSB\[(\d+)\]/i)  { "\e>" + "\eC\[#{Person::Sub[$1.to_i][1]}\]" + Person::Sub[$1.to_i][0] + "\eC\[0\]" }
    result.gsub!(/\eSBT\[(\d+)\]/i) { Person::Sub[$1.to_i][0] }
    result.gsub!(/\eSHOP\[(\w+)\]/i){ "\e>" + "\eC\[#{Person::Shop[$1][1]}\]" + Person::Shop[$1][0] + "\eC\[0\]" }
    result.gsub!(/\eSHOPT\[(\w+)\]/i){ Person::Shop[$1][0] }
    result.gsub!(/\eMOB\[(\w+)\]/i) { "\e>" + "\eC\[#{Person::Mob[$1][1]}\]" + Person::Mob[$1][0] + "\eC\[0\]" }
    result.gsub!(/\eMOBT\[(\w+)\]/i){ Person::Mob[$1][0] }
    result.gsub!(/\eBWH\[(\w+)\]/i) { Person::BWH[$1]}
    result.gsub!(/\eSM/i)           { Vocab::summon }
    result.gsub!(/\eP\[(\d+)\]/i)   { party_member_name($1.to_i) }
    result.gsub!(/\eGN/i)           { FAKEREAL::GOLD_NAME }
    result.gsub!(/\eG/i)            { Vocab::currency_unit }
    result.gsub!(/\eID\[(\w+)\,(\d+)\]/i)  { item_description_in_text($1, $2.to_i, true) }
    result.gsub!(/\ePR\[(\d+)\]/i)   { Vocab::param($1.to_i) }
    result.gsub!(/\eSK\[(\d+)\]/i)   { $data_system.skill_types[$1.to_i] }
    result.gsub!(/\eHP/i)            { Vocab::hp }
    result.gsub!(/\eMP/i)            { Vocab::mp }
    result.gsub!(/\eTP/i)            { Vocab::tp }
    result.gsub!(/\eAP/i)            { Vocab::ap_ex }
    result.gsub!(/\eHT/i)            { "　" }
    result.gsub!(/\eIMP/i)           { "" }
    result.gsub!(/\eKW\[(\d+)\]/i)   { FAKEREAL::KEYWORD[$1.to_i][0] }
    result.gsub!(/\eKWC\[(\d+)\]/i)  { FAKEREAL::KEYWORD[$1.to_i][0] }
    
    result.gsub!(/\eAM\[(\d+)\,(\w+)\]/i)  { a_material($1.to_i, $2) }
    result.gsub!(/\eAN\[(\d+)\,(\w+)\]/i)  { a_name($1.to_i, $2) }
    result.gsub!(/\eAWLP\[(\d+)\]/i) { FAKEREAL::AW_LP_PLICE[$1.to_i][0] }
    result.gsub!(/\eAWAN\[(\d+)\]/i) { $game_actors[FAKEREAL::AW_LP_PLICE[$1.to_i][1]].name }
    result.gsub!(/\eAALP\[(\d+)\]/i) { FAKEREAL::AA_LP_PLICE[$1.to_i][0] }
    result.gsub!(/\eAAAN\[(\d+)\]/i) { $game_actors[FAKEREAL::AA_LP_PLICE[$1.to_i][1]].name }
    
    result.gsub!(/\eDB\[(\w+)\,(\d+)\]/i)  { item_draw_in_text($1, $2.to_i, false) }
    result.gsub!(/\eTS\[(\D+?)\,(\d+)\]/i)   { cut_text_start($1, $2.to_i) }
    result.gsub!(/\eTE\[(\D+?)\,(\d+)\]/i)   { cut_text_end($1, $2.to_i) }
    result.gsub!(/\eTA\[(\D+?)\,(\d+)\]/i)   { cut_text_abs($1, $2.to_i) }
    result.gsub!(/\eCA\[(\d+)\,?(\d*?)\]/i)   { "" }
    result.gsub!(/\e!/i)   { "#" }
    result.gsub!(/\e\./i)   { "＃" }
    result.gsub!(/\e\|/i)   { "＃＃＃＃" }
    result.gsub!(/\e\^/i)   { "" }
    result.gsub!(/\e>/i)   { "" }
    result.gsub!(/\e</i)   { "" }
    result.gsub!(/\e{/i)   { "" }
    result.gsub!(/\e}/i)   { "" }
    result.gsub!(/\e\$/i)   { "" }
    result.gsub!(/\eI\[(\d+)\]/i)   { "　" }
    result.gsub!(/\eC\[(\d+)\]/i)   { "" }
    result.gsub!(/\eSE\[\w+\]/i)   { "" }
    result.gsub!(/\eSTND\[(\w)\,(\d+)\,(\d+)\]/i)   { "" }
    result.gsub!(/\eFACE\[(\d+)\]/i)   { "" }
    result.gsub!(/\eBLN\[(\d+)\,(\-?\d+)\]/i)   { "" }
    result.gsub!(/「/i)   { "" }
    result.gsub!(/」/i)   { "" }
    result.gsub!(/（/i)   { "" }
    result.gsub!(/）/i)   { "" }
    result
  end
  
  
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def self.convert_escape_wait(text)
    result = text.to_s.clone
    result.gsub!(/＃/i)   { "" }
    result
  end
  
  
end

#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　文章表示に使うメッセージウィンドウです。
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ● フラグのクリア
  #--------------------------------------------------------------------------
  alias wait_m_clear_flags clear_flags
  def clear_flags
    wait_m_clear_flags
    FRMassage.pause_index_plus(0)
  end
  #--------------------------------------------------------------------------
  # ● 制御文字の処理
  #     code : 制御文字の本体部分（「\C[1]」なら「C」）
  #     text : 描画処理中の文字列バッファ（必要なら破壊的に変更）
  #     pos  : 描画位置 {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  alias wait_m_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    wait_m_process_escape_character(code, text, pos)
    FRMassage.pause_index_plus if code.upcase == '!'
  end
end


#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias auto_mode_cancel_update update
  def update
    auto_mode_cancel_update
    $game_party.message_auto_mode = false if !$game_map.interpreter.running?
  end
end