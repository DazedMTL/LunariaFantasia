#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● アイテムの増加（減少）
  #     include_equip : 装備品も含める
  #--------------------------------------------------------------------------
  alias book_gain_item gain_item
  def gain_item(item, amount, include_equip = false)
    book_gain_item(item, amount, include_equip)
    $game_system.item_record(item) if has_item?(item, include_equip)
  end
end


#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは Book で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :book            # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias book_initialize initialize
  def initialize
    book_initialize
    book_set
  end
  #--------------------------------------------------------------------------
  # ○ 図鑑用意
  #--------------------------------------------------------------------------
  def book_set
    @book ||= {}
    @book["monster"] ||= {}
    @book["character"] ||= {}
    @book["quest"] ||= {}
    @book["item"] ||= {}
  end
  #--------------------------------------------------------------------------
  # ○ アイテム図鑑登録
  #--------------------------------------------------------------------------
  def item_record(item)
    @book ||= {}
    @book["item"] = {} if !@book["item"]
    return if Book::OMIT_ITEM[item_category(item)].include?(item.id)
    @book["item"][[item_category(item),item.id]] ||= true
  end
  #--------------------------------------------------------------------------
  # ○ アイテム図鑑手動登録
  #--------------------------------------------------------------------------
  def item_record_manual(symbol, id)
    @book ||= {}
    @book["item"] = {} if !@book["item"]
    @book["item"][[symbol, id]] ||= true
  end
  #--------------------------------------------------------------------------
  # ○ 魔物図鑑手動登録
  #--------------------------------------------------------------------------
  def enemy_record_manual(id,level, d = false)
    @book ||= {}
    @book["monster"] = {} if !@book["monster"]
    if d
      @book["monster"].delete(id)
    else
      @book["monster"][id] ||= level
      @book["monster"][id] = level if @book["monster"][id] && @book["monster"][id] < level
    end
  end
  #--------------------------------------------------------------------------
  # ○ アイテム分類
  #--------------------------------------------------------------------------
  def item_category(item)
    if item.is_a?(RPG::Item) && !item.key_item? && !item.skill_book? && !item.hide_item?
      :item
    elsif item.is_a?(RPG::Item) && item.key_item? && !item.hide_item?
      :key_item
    elsif item.is_a?(RPG::Weapon)
      :weapon
    elsif item.is_a?(RPG::Armor) && !item.rune?
      :armor
    elsif item.is_a?(RPG::Armor) && item.rune?
      :rune
    elsif item.is_a?(RPG::Item) && !item.key_item? && item.skill_book?
      :skill_book
    else
      :none
    end
  end
  #--------------------------------------------------------------------------
  # ○ 魔物図鑑登録
  #--------------------------------------------------------------------------
  def enemy_record(enemy)
    @book ||= {}
    @book["monster"] = {} if !@book["monster"]
    @book["monster"][enemy.enemy_id] ||= enemy.base_level
    @book["monster"][enemy.enemy_id] = enemy.base_level if @book["monster"][enemy.enemy_id] && @book["monster"][enemy.enemy_id] < enemy.base_level
  end
  #--------------------------------------------------------------------------
  # ○ クエスト図鑑登録　※variables クエスト管理変数
  #--------------------------------------------------------------------------
  def quest_record(variables)
    @book ||= {}
    @book["quest"] = {} if !@book["quest"]
    @book["quest"][variables] = true
  end
  #--------------------------------------------------------------------------
  # ○ 人物図鑑登録　※ id = n1 kp1 等の識別子　：　num = 説明進行度 
  #       マリアナの様に後半に説明が変化するタイプは説明進行度を増やしていく
  #--------------------------------------------------------------------------
  def character_record(id, num)
    @book ||= {}
    @book["character"] = {} if !@book["character"]
    @book["character"][id] ||= num
    @book["character"][id] = num if @book["character"][id] < num
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias book_terminate terminate
  def terminate
    book_terminate
    $game_troop.members.each {|enemy| $game_system.enemy_record(enemy)} unless $game_switches[FAKEREAL::NO_RECORD]
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
  # ○ 人物図鑑登録　　※ idは "" で囲む事, numは数字
  #--------------------------------------------------------------------------
  def character_record(id, num = 1)
    $game_system.character_record(id, num)
  end
  #--------------------------------------------------------------------------
  # ○ アイテム図鑑手動登録　※ symbolは頭に : をつける
  #--------------------------------------------------------------------------
  def item_record_manual(symbol, id)
    $game_system.item_record_manual(symbol, id)
  end
  #--------------------------------------------------------------------------
  # ○ アイテム図鑑手動登録　
  #--------------------------------------------------------------------------
  def enemy_record_manual(id, level, d = false)
    $game_system.enemy_record_manual(id, level, d)
  end
end

#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  #alias book_initialize initialize
  #def initialize
    #book_initialize
    #book_reset
  #end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def item_book_reset
    @item_book = nil
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def monster_book
    @monster_book ||= monster_book_set #$data_enemies.select{|enemy| !enemy.name.empty? && enemy.id < 89 if enemy }#.each{|e| @monster_book.push(e.id) }
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def monster_book_set(true_route = false)
    #book = []
    #m = $data_enemies.select{|enemy| !enemy.name.empty? && enemy.id < 89 if enemy }#.each{|e| @monster_book.push(e.id) }
    #m.each{|e| book.push(e.id) }
    book = []
    if true_route
      m = $data_enemies.select{|enemy| !enemy.name.empty? && enemy.id > 90 if enemy }#.each{|e| @monster_book.push(e.id) }
    else
      m = $data_enemies.select{|enemy| !enemy.name.empty? && enemy.id < 89 if enemy }#.each{|e| @monster_book.push(e.id) }
    end
    m = m.sort_by {|e| [e.category_id, e.id] }
    m.each{|e| book.push([e.id, e.base_level]) }
    return book
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def true_monster_book
    @true_monster_book ||= monster_book_set(true)#$data_enemies.select{|enemy| !enemy.name.empty? && enemy.id > 90 }
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def change_level_search(id, lv)
    @enemy_change_level[id] ||= change_level_set(id)
    @enemy_change_level[id][lv]
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def change_level_set(id)
    change_level = Hash.new
    enemy = $data_enemies[id]
    if enemy.note.include?("<LV")
      enemy.note.each_line do |line|
        case line
        when /\<LV(\d+)\s*:\s*HP(\d+)\s*:\s*MP(\d+)\s*:\s*SP(\d+)\s*:\s*攻(\d+)\s*:\s*防(\d+)\s*:\s*魔(\d+)\s*:\s*魔防(\d+)\s*:\s*敏(\d+)\s*:\s*運(\d+)\s*:\s*E(\d+)\s*:\s*G(\d+)\s*:\s*A(\d+)\>/
          change_level[$1.to_i] = [$2.to_i, $3.to_i, $5.to_i, $6.to_i, $7.to_i, $8.to_i, $9.to_i, $10.to_i, $4.to_i, $11.to_i, $12.to_i, $13.to_i]
        end
      end
    end
    return change_level
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def item_book
    @item_book ||= item_book_set($game_switches[FAKEREAL::BOOK_EXTEND]) #$data_enemies.select{|enemy| !enemy.name.empty? && enemy.id < 89 if enemy }#.each{|e| @monster_book.push(e.id) }
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def item_book_set(true_route = false)
    book = {}
    book[:item] = []
    book[:key_item] = []
    book[:weapon] = []
    book[:armor] = []
    book[:rune] = []
    book[:skill_book] = []
    i = $data_items.select{|item| item_category(item, :item) if item }
    i = i.select {|item| !Book::TRUE_ITEM[:item].include?(item.id) } if !true_route
    i = i.sort_by {|item| [item.category_id, item.id] }
    book[:item] = i#i.each{|item| book[:item].push(item.id) }
    k = $data_items.select{|item| item_category(item, :key_item) if item }
    k = k.select {|item| !Book::TRUE_ITEM[:key_item].include?(item.id) } if !true_route
    k = k.sort_by {|item| [item.category_id, item.id] }
    book[:key_item] = k
    w = $data_weapons.select{|item| item_category(item, :weapon) if item }
    w = w.select {|item| !Book::TRUE_ITEM[:weapon].include?(item.id) } if !true_route
    w = w.sort_by {|item| [item.category_id, item.id] }
    book[:weapon] = w
    a = $data_armors.select{|item| item_category(item, :armor) if item }
    a = a.select {|item| !Book::TRUE_ITEM[:armor].include?(item.id) } if !true_route
    a = a.sort_by {|item| [item.category_id, item.id] }
    book[:armor] = a
    r = $data_armors.select{|item| item_category(item, :rune) if item }
    r = r.select {|item| !Book::TRUE_ITEM[:rune].include?(item.id) } if !true_route
    r = r.sort_by {|item| [item.category_id, item.id] }
    book[:rune] = r
    s = $data_items.select{|item| item_category(item, :skill_book) if item }
    s = s.select {|item| !Book::TRUE_ITEM[:skill_book].include?(item.id) } if !true_route
    s = s.sort_by {|item| [item.category_id, item.id] }
    book[:skill_book] = s
    return book
  end
  #--------------------------------------------------------------------------
  # ○ アイテム分類
  #--------------------------------------------------------------------------
  def item_category(item, symbol)
    (!item.name.empty? && item.name != "------------------" && omit_condition(item, symbol)) && !Book::OMIT_ITEM[symbol].include?(item.id) && $game_system.item_category(item) == symbol
  end
  #--------------------------------------------------------------------------
  # ○ アイテム分類
  #--------------------------------------------------------------------------
  def omit_condition(item, symbol)
    !(item.name =~ /^×.*/) && !(item.name =~ /^△.*/)
  end
end


module Book
  
    CHARA = Hash[ # The second costume for display is selected by draw_costume_set when the array case
                    # id => 0 List notation name   1 Stand graphic name   2 Display costume   3 Age   4 Full name   5 Chara id   6 Presence of 3 sizes   7 How many character progress points to reveal the name   8 Display image adjustment value nil then 50
                    "n1" => {0=>"Lunaria",1=>"Lunaria",2=>[["cos01","story",2],["cos02","", 0]],3=>19,4=>"Lunaria Serenes Moonlit",5=>"n1",6=>true,7=>1,
                    },
                    
                    "n1_3" => {0=>"Lunaria (Awakened)",1=>"Lunaria",2=>"cos11b",3=>19,4=>"Lunaria Serenes Moonlit",5=>"n1",6=>true,7=>1,
                    },
                    
                    "n1_2" => {0=>"Lunaria (Succubus)",1=>"Lunaria",2=>"cos08b",3=>19,4=>"Succubus Queen Lunaria",5=>"n1b",6=>true,7=>1,
                    },
                    
                    "n2" => {0=>"Sonia",1=>"Sonia",2=>"cos01",3=>36,4=>"Sonia Sandiel",5=>"n2",6=>true,7=>1,
                    },
                    
                    "n2_2" => {0=>"Sonia (Brainwashed)",1=>"Sonia",2=>"cos05b",3=>36,4=>"Sonia Sandiel",5=>"n2",6=>true,7=>1,
                    },
                    
                    "n3" => {0=>"Mana",1=>"Mana",2=>"cos01",3=>20,4=>"Kujo Ai",5=>"n3",6=>true,7=>1,
                    },
                    
                    # Sub-character stand graphics ------------------------------------------------------------------------------------------------------------------------------
                    
                    "kp1" => {0=>Person::Name[1][0],1=>Person::Name[1][2],2=>"cos01",3=>28,4=>"Mariana Alter",5=>"kp1",6=>true,7=>1,
                    },
                    
                    "kp1_2" => {0=>"#{Person::Name[1][0]}(2)",1=>Person::Name[1][2],2=>"cos02",3=>28,4=>"Mariana Melticia Sagittarius",5=>"kp1",6=>true,7=>1,
                    },
                    
                    "kp1_3" => {0=>"#{Person::Name[1][0]}(Succubus)",1=>Person::Name[1][2],2=>"cos03b",3=>28,4=>"Succubus Mariana",5=>"kp1b",6=>true,7=>1,
                    },
                    
                    "kp2" => {0=>Person::Name[2][0],1=>Person::Name[2][2],2=>"cos01",3=>27,4=>"Diana Artemia Sagittarius",5=>"kp2",6=>true,7=>1,
                    },
                    
                    "kp2_2" => {0=>"#{Person::Name[2][0]}(Brainwashed)",1=>Person::Name[2][2],2=>"cos03b",3=>27,4=>"Diana Artemia Sagittarius",5=>"kp2",6=>true,7=>1,
                    },
                    
                    "kp3" => {0=>Person::Name[3][0],1=>Person::Name[3][2],2=>"cos01",3=>125,4=>"Mirei Nierenbergia",5=>"kp3",6=>true,7=>1,
                    },
                    
                    "kp3_2" => {0=>"#{Person::Name[3][0]}(Brainwashed)",1=>Person::Name[3][2],2=>"cos03b",3=>125,4=>"Mirei Nierenbergia",5=>"kp3",6=>true,7=>1,
                    },
                    
                    "kp4" => {0=>Person::Name[4][0],1=>Person::Name[4][2],2=>"cos01",3=>19,4=>"Shirley Fennel",5=>"kp4",6=>true,7=>1,
                    },
                    
                    "kp5" => {0=>Person::Name[5][0],1=>Person::Name[5][2],2=>"cos01",3=>19,4=>"Estia Yuki Elingium",5=>"kp5",6=>true,7=>1,
                    },
                    
                    "kp12" => {0=>Person::Name[12][0],1=>Person::Name[12][2],2=>"cos01",3=>41,4=>"Kujo Tsukasa",5=>"kp12",6=>true,7=>1,
                    },
                    
                    "kp13" => {0=>Person::Name[13][0],1=>Person::Name[13][2],2=>"cos01",3=>27,4=>"Filica Rain Daria",5=>"kp13",6=>true,7=>1,
                    },
                    
                    "kp13_2" => {0=>"#{Person::Name[13][0]}(In Heat)",1=>Person::Name[13][2],2=>"cos02b",3=>27,4=>"Filica Rain Daria",5=>"kp13",6=>true,7=>1,
                    },
                    
                    "n5" => {0=>"Anemone",1=>"Anemone",2=>"cos01",3=>"?",4=>"Anemone",5=>"n5",6=>true,7=>1,
                    },
                    
                    "n5_2" => {0=>"Anemone(2)",1=>"Anemone",2=>[["cos02","item",312],["cos01","",0]],3=>"?",4=>"Anemone",5=>"n5",6=>true,7=>1,
                    },
                    
                    "kp14" => {0=>Person::Name[14][0],1=>Person::Name[14][2],2=>"cos01",3=>"?",4=>"Sign Regel Sagittarius",5=>"kp14",6=>false,7=>1,8=>20,
                    },
                    
                    "kp31" => {0=>Person::Name[31][0],1=>Person::Name[31][2],2=>"cos01",3=>"?",4=>"Reno",5=>"kp31",6=>true,7=>2,
                    },
                    
                    "kp31_2" => {0=>"#{Person::Name[31][0]}(True)",1=>Person::Name[31][2],2=>"cos01b",3=>"?",4=>"Reno",5=>"kp31",6=>true,7=>1,
                    },
                    
                    "kp32" => {0=>Person::Name[32][0],1=>Person::Name[32][2],2=>"cos01",3=>"?",4=>"Asmorlios",5=>"kp32",6=>true,7=>1,
                    },
                    
                    "kp32_2" => {0=>"#{Person::Name[32][0]}(True)",1=>Person::Name[32][2],2=>"cos01b",3=>"?",4=>"Asmorlios",5=>"kp32",6=>true,7=>1,8=>180,
                    },
                    
                    "kp21" => {0=>"Mysterious Man",1=>Person::Name[21][2],2=>"cos01",3=>"?",4=>"",5=>"kp21",6=>false,7=>1,8=>20,
                    },
                    
                    "kp21_2" => {0=>Person::Name[21][0],1=>Person::Name[21][2],2=>"cos02",3=>"36",4=>"Light Sandiel",5=>"kp21",6=>false,7=>1,8=>20,
                    },
                    
                    "kp23" => {0=>Person::Name[23][0],1=>Person::Name[23][2],2=>"cos01",3=>"44",4=>"Delta Aberaze",5=>"kp23",6=>false,7=>1,
                    },
                    
                    "kp42" => {0=>Person::Name[42][0],1=>Person::Name[42][2],2=>"cos01",3=>"?",4=>"Magatsu Orochi",5=>"kp42",6=>false,7=>1,
                    },
                    
                    "kp42_2" => {0=>"#{Person::Name[42][0]}(True)",1=>Person::Name[42][2],2=>"cos01b",3=>"?",4=>"Magatsu Orochi",5=>"kp42b",6=>false,7=>1,8=>-10,
                    },
                    
                    "kp41" => {0=>Person::Name[41][0],1=>Person::Name[41][2],2=>"cos01",3=>"?",4=>"Zepar",5=>"kp41",6=>false,7=>1,
                    },
                    
                    "kp51" => {0=>Person::Name[51][0],1=>Person::Name[51][2],2=>"cos01",3=>"?",4=>"Belzerian",5=>"kp51",6=>false,7=>1,
                    },
                    
                    "kp51_2" => {0=>"#{Person::Name[51][0]}(True)",1=>Person::Name[51][2],2=>"cos01b",3=>"?",4=>"Belzerian",5=>"kp51b",6=>false,7=>1,8=>120,
                    },
                    
                    # No stand graphics - Sagittarius ------------------------------------------------------------------------------------------------------------------------------
                                    
                    "kp6" => {0=>Person::Name[6][0],1=>Person::Name[6][2],2=>"cos01",3=>42,4=>"Elenoa Lilies Moonlit",5=>"kp6",6=>true,7=>1,8=>-70,
                    },
                    
                    "kp11" => {0=>Person::Name[11][0],1=>Person::Name[11][2],2=>"cos01",3=>31,4=>"Lili Excoline",5=>"kp11",6=>true,7=>1,8=>-70,
                    },
                    
                    "kp8" => {0=>Person::Name[8][0],1=>Person::Name[8][2],2=>"cos01",3=>34,4=>"Drake Garbenia",5=>"kp8",6=>false,7=>1,
                    },
                    
                    "sb31" => {0=>Person::Sub[31][0],1=>Person::Sub[31][2],2=>"cos01",3=>38,4=>"Velvet Ward",5=>"sb31",6=>true,7=>1,8=>0,
                    },
                    
                    "kp9" => {0=>Person::Name[9][0],1=>Person::Name[9][2],2=>"cos01",3=>43,4=>"Salvia Frohne Elmeralia",5=>"kp9",6=>true,7=>1,8=>-70,
                    },
                    
                    # No stand graphics - Snowflake family ------------------------------------------------------------------------------------------------------------------------------
                    
                    "sb32" => {0=>Person::Sub[32][0],1=>Person::Sub[32][2],2=>"cos01",3=>19,4=>"Eliora Leti Snowflake",5=>"sb32",6=>true,7=>1,8=>-70,
                    },
                    
                    "sb19" => {0=>Person::Sub[19][0],1=>Person::Sub[19][2],2=>"cos01",3=>44,4=>"Elyusia Lumina Snowflake",5=>"sb19",6=>true,7=>1,8=>-70,
                    },
                    
                    "sb17" => {0=>Person::Sub[17][0],1=>Person::Sub[17][2],2=>"cos01",3=>22,4=>"Elis Tione Snowflake",5=>"sb17",6=>true,7=>1,8=>-70,
                    },
                    
                    # No stand graphics - Tikiwa Shrine Maidens ------------------------------------------------------------------------------------------------------------------------------
                    
                    "sb14" => {0=>Person::Sub[14][0],1=>Person::Sub[14][2],2=>"cos01",3=>22,4=>"Omiya Haruna",5=>"sb14",6=>true,7=>1,8=>-70,
                    },
                    
                    "sb42" => {0=>Person::Sub[42][0],1=>Person::Sub[42][2],2=>"cos01",3=>45,4=>"Karazuma Yuri",5=>"sb42",6=>true,7=>1,8=>-70,
                    },
                    
                    "sb43" => {0=>Person::Sub[43][0],1=>Person::Sub[43][2],2=>"cos01",3=>21,4=>"Karazuma Koka",5=>"sb43",6=>true,7=>1,8=>-70,
                    },
                    
                    "sb41" => {0=>Person::Sub[41][0],1=>Person::Sub[41][2],2=>"cos01",3=>20,4=>"Fushimi Sakura",5=>"sb41",6=>true,7=>1,8=>-70,
                    },
                    
                    # No stand graphics - Daria related & Others ------------------------------------------------------------------------------------------------------------------------------
                    
                    "sb16" => {0=>Person::Sub[16][0],1=>Person::Sub[16][2],2=>"cos01",3=>18,4=>"Rosa Selfille",5=>"sb16",6=>true,7=>1,8=>-70,
                    },
                    
                    "sb16_2" => {0=>"#{Person::Sub[16][0]}(In Heat)",1=>Person::Sub[16][2],2=>"cos02",3=>18,4=>"Rosa Selfille",5=>"sb16",6=>true,7=>1,8=>0,
                    },
                    
                    "sb18" => {0=>Person::Sub[18][0],1=>Person::Sub[18][2],2=>"cos01",3=>19,4=>"Felicia Calendula",5=>"sb18",6=>true,7=>1,8=>-70,
                    },
                    
                    "sb33" => {0=>Person::Sub[33][0],1=>Person::Sub[33][2],2=>"cos01",3=>37,4=>"Beriya Marks",5=>"sb33",6=>true,7=>1,8=>-70,
                    },
                    
                    "kp7" => {0=>Person::Name[7][0],1=>Person::Name[7][2],2=>"cos01",3=>19,4=>"Meris Imperialis",5=>"kp7",6=>true,7=>1,8=>-70,
                    },
                    
                    "sb38" => {0=>Person::Sub[38][0],1=>Person::Sub[38][2],2=>"cos01",3=>"?",4=>"Maki",5=>"sb38",6=>true,7=>1,8=>-70,
                    },
                    
                    "sb35" => {0=>Person::Sub[35][0],1=>Person::Sub[35][2],2=>"cos01",3=>"?",4=>"Ranun",5=>"sb35",6=>true,7=>1,8=>0,
                    },
                    
                    "kp44" => {0=>Person::Name[44][0],1=>Person::Name[44][2],2=>"cos01",3=>"?",4=>"Tamamo-no-Mae",5=>"kp44",6=>true,7=>1,8=>0,
                    },
                    
                    "sb6" => {0=>Person::Sub[6][0],1=>Person::Sub[6][2],2=>"cos01",3=>"19",4=>"Arks Davidia",5=>"sb6",6=>false,7=>1,
                    },
                    
                    "kp22" => {0=>Person::Name[22][0],1=>Person::Name[22][2],2=>"cos01",3=>48,4=>"Gord Aldishia",5=>"kp22",6=>false,7=>1,
                    },
                    
                    "sb2" => {0=>Person::Sub[2][0],1=>Person::Sub[2][2],2=>"cos01",3=>"?",4=>"Kamala",5=>"sb2",6=>false,7=>1,
                    },
                    
    ]
  
  TEXT = Hash[
#２８文字＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃#####
#２８文字＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃#
                "n1" => {
1=>"A court magician of the Magic Kingdom of Sagitarius, 
a talented woman who graduated top of her class from the 
Academy of Magic Arts. Doesn't become complacent with her 
high magical power, and has a diligent, serious personality. 
She's considerate of her companions and has a strong sense 
of duty, unable to abandon those in need. Skilled in fire 
magic and also proficient in summoning.
",

:true=>0,
                },
                
                "n1_3" => {
1=>"Lunaria, having awakened the magical powers inherited 
from the ancient five great magicians. Her power was said 
to rival that of the five jewels, far surpassing the demonic 
gods. After defeating the demon god, the power that had 
served its purpose vanished from within Lunaria, returning 
her to her original state.
",

:true=>1,
                },
                
                "n1_2" => {
1=>"The form of Lunaria after having the soul of the queen 
implanted within her using a succubus stone. According to 
Renno's assessment, Lunaria's ego was supposed to be erased 
and the original queen resurrected, but that plan failed, 
and the queen's ego disappeared, giving birth to the new 
queen of succubi, Lunaria.
",

:true=>0,
                },
                
#28 characters####################################
#28 characters####################################
                "n2" => {
1=>"A married female warrior traveling in 
search of her missing husband. In battle, 
she wields swords and is proficient in dual-wielding, 
making her a power-fighter. She's kind-hearted, 
preferring to trust rather than suspect others. 
Has strong moral convictions about chastity and 
faithfulness, but is currently struggling with 
desires due to her mature body.
",

:true=>0,
                },
                
                "n2_2" => {
1=>"Sonia, who infiltrated the Zepar faith at 
the request of Queen Dalia, was brainwashed by 
the cult leader's techniques. After being brainwashed, 
she was assigned to take care of various duties 
for the cult leader, and would be inseminated with 
his seed on a daily basis.
",

:true=>0,
                },
                
#28 characters####################################
#28 characters####################################
                "n3" => {
1=>"A shrine maiden from the island nation of Tokiwa, 
located to the east of Sagitarius. She finds it hard 
to express her emotions and rarely changes her expression, 
but harbors a passionate fervor inside. A formidable 
power in Tokiwa, she's rumored to be a candidate for 
the next village chief.
",

:true=>0,
                },
                
#28 characters####################################
#28 characters####################################
                "kp1" => {
1=>"A senior court magician of Sagitarius. In charge 
of item research and development within the castle 
and leads other magicians in the development of items. 
Her magical power isn't very high, and she's responsible 
for support in combat. She loves sexual activities and 
occasionally indulges with the soldiers in the castle.
",

:true=>0,
                },
                
                "kp1_2" => {
1=>"A senior court magician of Sagitarius, but in fact 
the illegitimate daughter of the former king, thus 
Diana's aunt. Born to a prostitute mother and the 
former king, who was one of her clients. She has 
experience working as a prostitute alongside her 
mother, and the mother-daughter combo was quite 
popular at the time.
",

:true=>1,
                },
                
                "kp1_3" => {
1=>"The appearance of Mariana, who was turned into 
a succubus by Lunaria using a succubus stone as a 
catalyst. Normally, even if she were the queen of 
succubi, using a succubus stone as a catalyst to 
turn a human into a succubus would not be possible but...
",

:true=>0,
                },
                
#28 characters####################################
#28 characters####################################
                "kp2" => {
1=>"The queen who rules the Magic Kingdom of 
Sagitarius, deeply trusted by her people to the 
extent that there is an official fan club for 
her in the town below the castle. Blessed with 
high magical power and talent, she was called a 
genius magician among the royal family during 
her princess days. She's also notably busty.
",

:true=>0,
                },
                
                "kp2_2" => {
1=>"The appearance of Diana, having been brainwashed 
by the enchantment of the brainwashing demon Zepar, 
leaving her body and soul captive to him. Since 
being brainwashed, she has continued to serve Zepar 
daily and has been inseminated with his seed over 250 times.
",

:true=>1,
                },
                
#28 characters####################################
#28 characters####################################
                "kp3" => {
1=>"The leader of the court magicians who has served 
the Magic Kingdom since the reign of the king before 
last, and a half-elf. Diana's magical mentor, a good 
friend, and a confidante. She possesses high magical 
power derived from her elf lineage and is a first-class 
magician with no weak attributes.
",

:true=>0,
                },
                
                "kp3_2" => {
1=>"The appearance of Millay, who has been brainwashed 
by the enchantment of the brainwashing demon Zepar, 
leaving her body and soul captive to him. Since being 
brainwashed, she has continued to serve Zepar daily 
and has been inseminated with his seed over 250 times.
",

:true=>1,
                },
                
#28 characters####################################
#28 characters####################################
                "kp4" => {
1=>"A spirited woman who became a court magician 
alongside Lunaria after graduating from the same 
magic academy. She doesn't have much magical power 
but compensates with her physical strength, agility, 
and strength which she utilizes in her specialized 
martial magic. She's self-conscious about not having 
as large breasts as the other women around her.
",

:true=>0,
                },
                
                "kp5" => {
1=>"A gentle woman who became a court magician 
alongside Lunaria after graduating from the same 
magic academy. She has large breasts comparable 
to Lunaria and high magical power, specializing 
in healing magic.
",

2=>"A gentle woman who became a court magician 
alongside Lunaria after graduating from the same 
magic academy. She has large breasts comparable 
to Lunaria and high magical power, specializing 
in healing magic. Her mother is from the eastern 
island nation of Tokiwa, and she was born and raised there.
",

:true=>0,
                },
                
#28 characters####################################
#28 characters####################################
                "kp12" => {
1=>"The long-serving priestess of the Nine-Fold 
Village of Tokiwa and the most senior of the five 
village chiefs. She has high magical power and is 
the top combatant among the shrine maidens. She is 
Mana's aunt and has been a mother figure to her, 
having lost her own mother early on. Married with one son.
",

:true=>0,
                },
                
                "kp13" => {
1=>"The queen of the martially esteemed kingdom of 
Dalia, always dignified and noble, and known as the 
Knight Queen. Her swordsmanship is unrivaled in the 
kingdom, surpassing even the captain of the kingdom's 
knights. She can't tolerate dishonesty and has worked 
to eradicate corruption in her country, which has made
her the target of those who disapprove of her methods.
",

:true=>0,
                },
                
                "kp13_2" => {
1=>"The form of Filica, who fell to become a flesh 
slave to Delta after being subjected to the arousal 
magic of the succubus queen. Her strong mental 
fortitude kept her resisting, but eventually, she 
ended up begging for Delta's member herself.
",

:true=>1,
                },
                
#28 characters####################################
#28 characters####################################
                "n5" => {
1=>"A Snow Lady whom Lunaria met in the temple. 
Although a monster, she is kind-hearted and does
not enjoy fighting. She's interested in human 
culture and food, with a particular curiosity 
about Tokiwa of late. She's also curious about 
sexual matters, secretly reading human literature 
on such topics.
",

:true=>0,
                },
            
                "n5_2" => {
1=>"To save Anemone's life, Lunaria entered into a forced contract with her
making her her own \esm. Lunaria regrets this decision,
but the person in question is very happy to be able to enter the human town
and is grateful to Lunaria.
",

:true=>0,
                },
                
                "kp14" => {
1=>"The leader of the five great magicians who once defeated the demon god, and 
the first king of the magic kingdom of Sagittarius. He embodies the \"hero who loves color\",
and after the defeat of the demon god, he married all the women who had traveled 
with him as his queens.
",

:true=>1,
                },
                
#28 CHARACTERS#######################################
#28 CHARACTERS#######################################

                "kp31" => {
1=>"A succubus secretly following Lunaria.
Nothing much is known about her...
",

2=>"A succubus secretly following Lunaria.
Her purpose seems to be the resurrection of the succubus queen but...
True to her name, she loves lewd acts, saying \"If I'm going to have sex, 
it has to be with either a fat old man with a belly or a tough warrior.\"
",

:true=>0,
                },
                
#28 CHARACTERS#######################################
#28 CHARACTERS#######################################
                
                "kp31_2" => {
1=>"The true form of the succubus Renno. When Renno gets serious, two more wings appear,
patterns emerge on her face, and her magical power dramatically increases. Different from other succubi
in her uniqueness, and also possessing the ability to become a futanari,
she was favored by Asmolios and had always served as her confidant.
",

:true=>1,
                },
                
                "kp32" => {
1=>"The queen of the succubi who command the night, resurrected by the power of the demon god. She was once 
subdued by the queen of Dalia but was protected by Renno's ability as a soul and spent an eternity in that state.
After her revival, she felt indebted to the demon god and became one of his subordinates.
",

:true=>1,
                },
                
                "kp32_2" => {
1=>"The true form of the succubus queen Asmolios. Her true identity is a half demon and half angel,
possessing both glowing wings of light and dark wings of pitch black.
Her power is immense, with resistance to both light and darkness and mastery
over high-level magic of both attributes.
",

:true=>1,
                },
                
#28 CHARACTERS#######################################
#28 CHARACTERS#######################################

                "kp21" => {
1=>"A mysterious man who stole Lunaria and her companions' source of magical power. He seems to be trailing after Lunaria...
",

2=>"A mysterious man who stole Lunaria and her companions' source of magical power. He was trailing after Lunaria,
but it is revealed that he is Sonia's missing husband Wright, whose consciousness had been overtaken by the demon god.
",

:true=>2,
                },
                
                "kp21_2" => {
1=>"Sonia's husband, who had gone missing. His consciousness was taken over by a demon god at some ruins,
and he was being manipulated by the demon god ever since.
Even after being freed from the demon god, he continued to sleep for a long time, but after the demon god was subdued,
he regained consciousness and returned home with Sonia to their home.
",

:true=>1,
                },
                
                "kp23" => {
1=>"A minister of the Kingdom of Dalia. Obsessed with Queen Filica,
he would resort to any means to make her his own, such as backing the establishment of a suspicious cult.
He wears platform shoes to try to hide his short stature even a little.
",

2=>"A minister of the Kingdom of Dalia. Obsessed with Queen Filica,
he would resort to any means to make her his own, such as establishing a suspicious cult
or even easily agreeing to deals with succubi. He wears platform shoes to try to hide his short stature even a little.
",

:true=>2,
                },
                
#28 CHARACTERS#######################################
#28 CHARACTERS#######################################

                "kp42" => {
1=>"The legendary great monster called the evil dragon that was sealed in Tokiwa. It is said to have been sealed by a great miko of the Kujou family,
and its power is so great that modern mikos are completely powerless against it.
The dragon harbors resentment towards the humans of the Kujou family who sealed it.
",

:true=>1,
                },
                
                "kp42_2" => {
1=>"The true form of the legendary great monster, the evil dragon. Its true nature is a giant three-headed serpent,
and fundamentally, it is also a dragon. The scar on its right eye was inflicted by the Kujou miko who sealed it long ago,
and the resentment for that scar remains to this day.
",

:true=>1,
                },
                
                "kp41" => {
1=>"A demon known as the brainwashing fiend of depravity. In the past, it was subdued by Diana when she was a princess,
along with Millay, but afterward, it wandered as a soul alone and possessed a man named Kamara, with whom it resonated, to survive.
After its revival, it became a subordinate of the demon god and brainwashed Diana and Millay.
",

:true=>1,
                },
                
                "kp51" => {
1=>"A legendary demon god that tried to rule the world a thousand years ago.
Defeated by the five great magicians, it did not perish and passed through eternity,
slowly regaining its power, and finally used the power of five jewels to resurrect in the present world.
",

:true=>1,
                },
                
                "kp51_2" => {
1=>"The true form of the legendary demon god. An embodiment of despair and dominion, it harbors three evil eyes.
The attacks unleashed from its black wings of darkness, the glare from its evil eyes, and its fists enshrouded in darkness are incomparably powerful,
and any defense that is merely half-hearted will not spare one an instant death.
",

:true=>1,
                },
                
#28 CHARACTERS#######################################
#28 CHARACTERS#######################################

                "kp6" => {
1=>"Lunaria's mother and former court magician of Sagittarius.
Now a full-time housewife. Her husband is the former captain of the royal knights.
",

:true=>0,
                },

                "kp11" => {
1=>"A court magician who is a senior to Lunaria and her friends. She has a responsible and caring personality.
She is planning to marry her boyfriend soon.
",

:true=>0,
                },
                
                "kp8" => {
1=>"The captain of the Knights of the Kingdom of Sagittarius. He is serious, honest, and his swordsmanship is first-rate.
",

:true=>0,
                },

#２８文字＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃#####
#２８文字＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃#
               
            "sb31" => {
1=>"One of the female ministers in Sagittarius. An intellectual woman wearing glasses.
A single 38-year-old seeking a lover. She loves alcohol and recently has become
addicted to \edb[i,123].
",

:true=>0,
            },
            
            "kp9" => {
1=>"An instructor of the summoning department at the Royal Magic Academy. Lunaria's summoning technique mentor.
Married, with her husband being one of the magic instructors at the same magic academy.
A bit older than Velvet (taboo), but they enjoy drinking together as good drinking buddies.
",

:true=>1,
            },
            
            "sb32" => {
1=>"One of Lunaria's fellow court magicians. She calls herself Lunaria's
rival. Carrying the alias 'Icebind,' as implied by the name,
she specializes in ice magic.
",

2=>"One of Lunaria's fellow court magicians. She calls herself Lunaria's
rival. Known by the alias 'Icebind,' she specializes in ice magic as implied by the name.
She's actually a lady from the noble Dahlia family.
Her mother was a former court magician of Sagittarius, and she inherited her hair color from her mother.
",

:true=>0,
            },
#28 characters#####################################
#28 characters#####################################

            "sb19" => {
1=>"Eriora's mother and a former court magician of Sagittarius. A senior colleague of Lunaria's
mother Eleanor, the two often partnered up for missions. She is affectionately known as Elly.
",

:true=>0,
            },
            
            "sb17" => {
1=>"Eriora's sister and the captain of the \ekw[4], the Queen's Royal Guard of Dahlia. 
She has the best swordsmanship in the squad and is also an excellent leader.
Although not outspoken about it, she is concerned about her younger sister Eriora, who has left home.
",

:true=>0,
            },

#28 characters#####################################
#28 characters#####################################

            "sb14" => {
1=>"One of the shrine maidens of Tokiwa and a key aide to Tsukiha.
She doesn't trust outsiders much and is wary of Lunaria.
",

:true=>0,
            },
            
            "sb42" => {
1=>"One of the shrine maidens of Tokiwa and mother of \esbt[43]. Among the shrine maidens, she
is considered an elder, but she is beautiful and seductive. Among the maidens, her bosom is
second only to Tsukiha.
",

:true=>0,
            },
            
            "sb43" => {
1=>"One of the shrine maidens of Tokiwa and daughter of \esbt[42]. She has a frenemy-like relationship with Mana,
constantly provoking her. Although she is one year older than Mana, she is self-conscious about
having smaller breasts than her. She believes in the genetics of her mother and is convinced that her breasts will grow bigger eventually.
",

:true=>0,
            },
            
            "sb41" => {
1=>"One of the shrine maidens of Tokiwa. Her hobbies include fashion and love stories.
Once, she tried to cutely modify her shrine maiden hakama but was severely scolded, so she now wears the standard shrine maiden hakama obediently.
",

:true=>0,
            },
            
#28 characters#####################################
#28 characters#####################################

            "sb16" => {
1=>"A maid exclusively serving Queen Filica of Dahlia. She is reserved and well-mannered,
and her appearance has garnered her many fans within the castle.
",

:true=>0,
            },
            
            "sb16_2" => {
1=>"Rosa's appearance after falling as a flesh slave to Delta due to the succubus's estrus spell.
Unlike Filica, she succumbed to the penis from the first stage of being violated
and after succumbing, she willingly serviced Delta's penis,
becoming a submissive female slave.
",

:true=>1,
            },
            
            "sb18" => {
1=>"The vice-captain of the \ekw[4], the Queen's Royal Guard of Dahlia.
A talented individual who became the vice-captain of the Royal Guard based solely on her ability despite her commoner origins.
",

2=>"The vice-captain of the \ekw[4], the Queen's Royal Guard of Dahlia.
A talented individual who became the vice-captain of the Royal Guard based solely on her ability despite her commoner origins.
She loves erotic things, and during her student days, she worked as an erotic dancer in night establishments.
",

:true=>2,
            },
            
#28 characters#####################################
#28 characters#####################################

            "sb33" => {
1=>"A woman who runs a brothel in Ragras. She herself has a past of working as a prostitute.
She seeks out women working in taverns who seem to have potential and scouts them to become prostitutes.
",

:true=>0,
            },
            
            "kp7" => {
1=>"A Sister who travels the world purifying lost souls.
She has a strong spirit of self-sacrifice and a bit of a weak guard against other people.
Oddly, despite her young appearance, she has a large chest.
",

:true=>1,
            },

#28 characters#####################################
#28 characters#####################################

            "sb38" => {
1=>"A short-haired Snow Lady. A close friend of Anemone, who is also a Snow Lady,
and they enjoy erotic chats together as lewd story buddies. She has mixed feelings towards Lunaria, who caused the purge of Anemone but also saved her life.
",

:true=>1,
            },
            
            "sb35" => {
1=>"The Snow Lady of higher rank that rules over the pack, the Ice Demon Queen
Snow Queen. She scarcely shows herself in public, and among demonologists,
there are few who believe in her existence.
",

:true=>1,
            },
            
            "kp44" => {
1=>"A great demon, the Nine-Tailed Fox, sealed in Tokiwa's killing stone. Some influence has weakened the seal, and it once escaped but was resealed by Mana.
It is said that in the past, with its beauty, it deluded the people of Tokiwa and took many lives.
",

:true=>1,
            },
#28 characters#####################################
#28 characters#####################################

            "sb6" => {
1=>"A dark magician who harbored feelings for Lunaria during their academy days.
At that time, he repeatedly challenged her to summoning battles, but he never won once.
After graduation, he secluded himself in a mansion, researching high-level demon summoning for the downfall of Lunaria.
",

:true=>0,
            },

            "kp22" => {
1=>"A trader based in Dahlia, working his way up to his current wealth in one generation.
He has dealings with the kingdom, and his character is considered sincere and gentlemanly.
Although quite lascivious, he does not touch women who are averse to him.
",

2=>"A trader based in Dahlia, working his way up to his current wealth in one generation.
He has dealings with the kingdom, and his character is considered sincere and gentlemanly.
Due to a distant ancestor mating with a succubus, his descendants have inherited sexual allure and stamina capable of captivating the opposite sex generation after generation.
",

:true=>0,
            },
            
#28 characters#####################################
#28 characters#####################################

            "sb2" => {
1=>"The leader of a suspicious religion called Zepar's teaching. There are rumors of
unsavory acts being conducted behind the scenes...
",

2=>"The leader of a suspicious religion called Zepar's teaching. He brainwashed female followers
and violated them daily. Sonia was one of the victims.
",

3=>"The leader of a suspicious religion called Zepar's teaching. He brainwashed female followers
and violated them daily. Sonia was one of the victims. His true form was a demon named Zepar,
and it was the soul of that demon possessing a human named Kamara.
",

:true=>3,
            },

#２８文字＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃#####
#２８文字＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃#
 
  ]
  
  TRUE_ITEM = Hash[
               :item => [48, 199, *(302..309), *(326..328), *(336..340)],
               
               :key_item => [215, 217, *(225..228), *(232..235), 300, 301, 315, 343, 349, 350],
               
               :weapon => [*(13..19), *(25..39), *(45..59), *(63..79), *(100..110),],
               
               :armor => [*(8..19), *(30..34), 43, 44, *(46..49), *(56..63), *(132..139), *(143..159), *(163..169), *(173..179), *(183..194), *(199..214), *(219..234), *(239..254), *(301..309)],
               
               :rune => [*(119..121), *(340..368)],
               
               :skill_book => [55, 90, 256, 259, 346, 347],
               
               :none => [],
  ]
  
  OMIT_ITEM = Hash[
               :item => [],
               
               :key_item => [219, 232],
               
               :weapon => [*(81..89)],
               
               :armor => [328],
               
               :rune => [],
               
               :skill_book => [96],
               
               :none => [],
  ]
end
