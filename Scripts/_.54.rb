module FAKEREAL
  
  CHARA_NAME      = "fr_main_cos"
  COSTUME_CHANGE_SWITCH = 18
  COSCHANGE = "<着替え>"
  NOT_COSCHANGE = "<着替え禁止！>"
  
end

module COSTUME
  # npcの画像配列　keyが「fr_subXX_cosYY」のXX部分で、配列の順番はcharacter_index
  # 配列内はcharacter_indexに対応するnpc_id
  NPC_DATA = Hash[
    "01" => [5,6,11,3,1,2,0,12],
    "02" => [0,0,0,0,0,0,13,0],
    "03" => [0,0,0,0,0,0,0,14],
  ]
  
  # keyがアクターID、配列の番号が衣装による特徴の職業ID　nilは特徴無し
  #配列先頭は衣装0(裸)
  FEATURES = Hash[
  1 => [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,212],
  2 => [],
  3 => [],
  4 => [],
  5 => [nil,nil,nil,nil,206,nil],
  6 => [],
  7 => [],
  8 => [],
  9 => [],
  10 => [],
  11 => [],
  12 => [],
  13 => [],
  14 => [],
  15 => [],
  16 => [],
  17 => [],
  18 => [],
  19 => [],
  20 => [],
  21 => [],
  22 => [],
  23 => [],
  24 => [],
  25 => [],
  ]
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def cos_w_name(name)
    return name if !name.include?("衣装「")
    c_name = name.clone
    c_name.slice!(/^衣装「/i)
    c_name.slice!(/」$/i)
    return c_name
  end
end

module FRCS
  #--------------------------------------------------------------------------
  # ● 次のアクターに切り替え
  #--------------------------------------------------------------------------
  def next_actor
    @actor = $game_party.costume_actor_next
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターに切り替え
  #--------------------------------------------------------------------------
  def prev_actor
    @actor = $game_party.costume_actor_prev
    on_actor_change
  end
end
#==============================================================================
# ■ Window_MenuStatus
#------------------------------------------------------------------------------
# 　メニュー画面でパーティメンバーのステータスを表示するウィンドウです。
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :pending_index            # 保留位置（並び替え用）
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @pending_index = -1
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return $game_party.members.size
  end
  #--------------------------------------------------------------------------
  # ● 横に項目が並ぶときの空白の幅を取得
  #--------------------------------------------------------------------------
  def spacing
    return 8
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の幅を計算
  #--------------------------------------------------------------------------
  def contents_width
    (item_width + spacing) * item_max - spacing
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の高さを計算
  #--------------------------------------------------------------------------
  def contents_height
    item_height
  end
  #--------------------------------------------------------------------------
  # ● 先頭の桁の取得
  #--------------------------------------------------------------------------
  def top_col
    ox / (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # ● 先頭の桁の設定
  #--------------------------------------------------------------------------
  def top_col=(col)
    col = 0 if col < 0
    col = col_max - 1 if col > col_max - 1
    self.ox = col * (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # ● 末尾の桁の取得
  #--------------------------------------------------------------------------
  def bottom_col
    top_col + col_max - 1
  end
  #--------------------------------------------------------------------------
  # ● 末尾の桁の設定
  #--------------------------------------------------------------------------
  def bottom_col=(col)
    self.top_col = col - (col_max - 1)
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置が画面内になるようにスクロール
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
    self.top_col = index if index < top_col
    self.bottom_col = index if index > bottom_col
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = super
    rect.x = index * (item_width + spacing)
    rect.y = 0
    rect
  end
  #--------------------------------------------------------------------------
  # ● アライメントの取得
  #--------------------------------------------------------------------------
  def alignment
    return 1
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    (Graphics.width - 160)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height - fitting_height(1)
  end
  #--------------------------------------------------------------------------
  # ● 項目の高さを取得
  #--------------------------------------------------------------------------
  def item_height
    (height - standard_padding * 2)
  end
  #--------------------------------------------------------------------------
  # ○ シンプルなステータスの描画
  #--------------------------------------------------------------------------
  def draw_actor_simple_status_fr(actor, x, y)
    case $game_party.members.size
    when 4
      w = 92
    else
      w = 124
    end
    num = contents_height / line_height
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_icons(actor, x, y + line_height * 2)
    draw_actor_class(actor, x, y + line_height * 3)
    draw_actor_hp(actor, x, y + line_height * (num - 3), w)
    draw_actor_mp(actor, x, y + line_height * (num - 2), w)
    draw_actor_tp(actor, x, y + line_height * (num - 1), w)
    #draw_actor_hp(actor, x, y + line_height * 14, w)
    #draw_actor_mp(actor, x, y + line_height * 15, w)
    #draw_actor_tp(actor, x, y + line_height * 16, w)
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.members[index]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    case col_max
    when 1; ox = 100
    when 2; ox = 4
    when 3; ox = 4
    else  ; ox = 0
    end
    draw_actor_stand(actor, rect.x + ox, rect.y, enabled)
    draw_actor_simple_status_fr(actor, rect.x + 1, rect.y)
  end
  #--------------------------------------------------------------------------
  # ● 項目の背景を描画
  #--------------------------------------------------------------------------
  def draw_item_background(index)
    if index == @pending_index
      contents.fill_rect(item_rect(index), pending_color)
    end
  end
end


#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　ゲーム中の全てのウィンドウのスーパークラスです。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● グラフィックの描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_stand(actor, member_size, x, y, enabled = true)
    bitmap = Cache.stand("#{actor.graphic_name}_cos#{actor.costume}")
    case member_size
    when 1; space = 0;
    else  ; space = 8;
    end
    rect = Rect.new(actor.stand_ox[member_size - 1], actor.stand_oy[member_size - 1], item_width - space, item_height) #Rect.new(stand_index % 4 * 96, stand_index / 4 * 96, item_width, 288)# / num, 288) #272 / num, 288)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● アクターの胸像グラフィック描画
  #--------------------------------------------------------------------------
  def draw_actor_stand(actor, x, y, enabled = true)
    draw_stand(actor, $game_party.members.size, x, y, enabled)
  end
end

#==============================================================================
# ■ Cache
#------------------------------------------------------------------------------
# 　各種グラフィックを読み込み、Bitmap オブジェクトを作成、保持するモジュール
# です。読み込みの高速化とメモリ節約のため、作成した Bitmap オブジェクトを内部
# のハッシュに保存し、同じビットマップが再度要求されたときに既存のオブジェクト
# を返すようになっています。
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # ○ 胸像グラフィックの取得
  #--------------------------------------------------------------------------
  def self.stand(filename)
    load_bitmap("Graphics/Pictures/Stands/", filename)
  end
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :costume                     # 衣装
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias costume_setup setup
  def setup(actor_id)
    costume_setup(actor_id)
    default_costume_set
    cos_temp_init
  end
  #--------------------------------------------------------------------------
  # ○ デフォルトの衣装
  #--------------------------------------------------------------------------
  def default_costume_set
    @costume = actor.note =~ /\<初期衣装:(\d+?)\>/ ? $1 : "01"
  end
  #--------------------------------------------------------------------------
  # ○ 衣装の変更
  #--------------------------------------------------------------------------
  def costume_change(cos)
    @costume = format("%02d",cos)
    @character_name = "#{FAKEREAL::CHARA_NAME}" + @costume
  end
  #--------------------------------------------------------------------------
  # ○ 衣装の記憶
  #--------------------------------------------------------------------------
  def costume_memory
    @cos_temp.push(@costume.to_i)
  end
  #--------------------------------------------------------------------------
  # ○ 記憶した衣装の呼び出し
  #--------------------------------------------------------------------------
  def costume_remember
    costume_change(@cos_temp.pop) if !@cos_temp.empty?
  end
  #--------------------------------------------------------------------------
  # ○ 衣装の記憶配列の初期化
  #--------------------------------------------------------------------------
  def cos_temp_init
    @cos_temp = [] # 直前の衣装を記憶する配列
  end
  #--------------------------------------------------------------------------
  # ○ 胸像の表示開始位置の指定　メンバー数に対応（[一人表示, 二人表示, 三人表示, 四人表示]）
  #--------------------------------------------------------------------------
  def stand_ox
    return [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if actor.note =~ /\<メニューox:(\-?\d+?),(\-?\d+?),(\-?\d+?),(\-?\d+?)\>/
    return [0, 0, 0, 0]
  end
  #--------------------------------------------------------------------------
  # ○ 胸像の表示開始位置の指定　メンバー数に対応（[一人表示, 二人表示, 三人表示]）
  #--------------------------------------------------------------------------
  def stand_oy
    return [$1.to_i, $2.to_i, $3.to_i, $4.to_i] if actor.note =~ /\<メニューoy:(\-?\d+?),(\-?\d+?),(\-?\d+?),(\-?\d+?)\>/
    return [0, 0, 0, 0]
  end
  #--------------------------------------------------------------------------
  # 〇 衣装の特徴　※パッシブ装備スキルに追加
  #--------------------------------------------------------------------------
  def costume_feature
    #$data_classes[COSTUME::FEATURES[@actor_id][@costume.to_i]]
    [$data_classes[(COSTUME::FEATURES[@actor_id][@costume.to_i] ? COSTUME::FEATURES[@actor_id][@costume.to_i] : 0)]]
  end
end

#==============================================================================
# ■ Window_MenuActor
#------------------------------------------------------------------------------
# 　アイテムやスキルの使用対象となるアクターを選択するウィンドウです。
#==============================================================================

class Window_MenuActor < Window_MenuStatus
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height
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
  # ○ スクリプトから衣装の変更
  #--------------------------------------------------------------------------
  def cos_change(cos, a_id = 1)
    $game_actors[a_id].costume_change(cos)
    cos_refresh
  end
  #--------------------------------------------------------------------------
  # ○ スクリプトからNPC衣装の変更
  #--------------------------------------------------------------------------
  def npc_cos_change(cos, npc_id = 1)
    $game_system.npc_costume_set(npc_id, cos)
    cos_refresh
  end
  #--------------------------------------------------------------------------
  # ○ スクリプトから衣装の記憶
  #--------------------------------------------------------------------------
  def cos_memory(a_id = 1)
    $game_actors[a_id].costume_memory
  end
  #--------------------------------------------------------------------------
  # ○ スクリプトから記憶した衣装へ変更
  #--------------------------------------------------------------------------
  def cos_remember(a_id = 1, init = true)
    $game_actors[a_id].costume_remember
    cos_refresh
    cos_temp_init(a_id) if init
  end
  #--------------------------------------------------------------------------
  # ○ 記憶した衣装を消去　※基本的にはリメンバーとセットで運用
  #--------------------------------------------------------------------------
  def cos_temp_init(a_id = 1)
    $game_actors[a_id].cos_temp_init
  end
  #--------------------------------------------------------------------------
  # ○ 衣装のチェック
  #--------------------------------------------------------------------------
  def cos_check(cos, a_id = 1)
    $game_actors[a_id].costume == format("%02d",cos)
  end
  #--------------------------------------------------------------------------
  # ○ 衣装変更後の処理
  #--------------------------------------------------------------------------
  def cos_refresh
    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # ○ 混浴判定　淫性値１００以上・パーティ一人・
  #　　　　　　　非処女・絶頂回数４０以上・セクハラ回数１０以上
  #　　　　　　　富豪ゴードと３P済・ラグラス娼館４回目済・カクタス酒場バイト２回目済
  #--------------------------------------------------------------------------
  def man_and_woman
    $game_variables[FAKEREAL::SEX_POINT] >= 100 && $game_party.members.size == 1 && 
      !$game_actors[1].virgin && $game_actors[1].ecstasy >= 40 && $game_actors[1].harassment >= 10 &&
        $game_switches[207] && $game_switches[172] && $game_switches[184]
  end
  #--------------------------------------------------------------------------
  # ○ 精油按摩判定　淫性値５０以上・パーティ一人・
  #　　　　　　　非処女・セックス回数３以上・セクハラ回数５以上
  #--------------------------------------------------------------------------
  def hypno_oil
    $game_variables[FAKEREAL::SEX_POINT] >= 50 && cos_check(0) && $game_party.members.size == 1 && 
      !$game_actors[1].virgin && $game_actors[1].sex >= 3 && $game_actors[1].harassment >= 5
  end
  #--------------------------------------------------------------------------
  # ○ 衣装によるチップの計算
  #--------------------------------------------------------------------------
  def battle_tip(tips, plus, a_id = 1)
    tip = tips + (1 + rand(plus))
    if a_id == 1
      case $game_actors[a_id].costume
      when "06" ; return tip * 1
      when "03" ; return tip * 2
      when "05" ; return tip * 4
      when "10" ; return tip * 5
      else      ; return tip * 0
      end
    elsif a_id == 2
    elsif a_id == 3
    end
  end
end

class RPG::Event::Page::Graphic
  alias cos_character_name character_name
  def character_name
    if @character_name =~ /fr_main_(cos|down|sleep)$/ #== "fr_main_cos01" 
      @character_name + "#{$game_actors[@character_index + 1].costume}"
    elsif @character_name =~ /fr_sub(\d+)_(cos|down|sleep)$/
      npc_id = COSTUME::NPC_DATA[$1][@character_index]
      @character_name + "#{$game_system.npc_costume(npc_id)}"
    else
      cos_character_name
    end
=begin
    if @character_name =~ /fr_main_(cos|down)\d+/ #== "fr_main_cos01" 
      cos_character_name
    elsif @character_name.include?("fr_main_") #== "fr_main_cos"
      @character_name + "#{$game_actors[@character_index + 1].costume}"
    else
      cos_character_name
    end
=end
  end
end

#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　イベントを扱うクラスです。条件判定によるイベントページ切り替えや、並列処理
# イベント実行などの機能を持っており、Game_Map クラスの内部で使用されます。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● グラフィックの変更
  #     character_name  : 新しい歩行グラフィック ファイル名
  #     character_index : 新しい歩行グラフィック インデックス
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index)
    if character_name =~ /fr_main_(cos|down|sleep)$/
      @tile_id = 0
      @character_name = character_name + "#{$game_actors[character_index + 1].costume}"
      @character_index = character_index
      @original_pattern = 1
    elsif character_name =~ /fr_sub(\d+)_(cos|down|sleep)$/
      @tile_id = 0
      npc_id = COSTUME::NPC_DATA[$1][character_index]
      @character_name = character_name + "#{$game_system.npc_costume(npc_id)}"
      @character_index = character_index
      @original_pattern = 1
    else
      super(character_name, character_index)
    end
    #@tile_id = 0
    #@character_name = character_name
    #@character_index = character_index
    #@original_pattern = 1
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
=begin
  alias cos_refresh refresh
  def refresh
    cos_refresh
    if @character_name.include?("fr_main_cos")
      @tile_id = 0
      @character_name = "fr_main_cos" + "#{$game_actors[character_index + 1].costume}"
      @character_index = character_index
      @original_pattern = 1
    end
    #new_page = @erased ? nil : find_proper_page
    #setup_page(new_page) if !new_page || new_page != @page
  end
=end
end

#==============================================================================
# ■ Game_Character
#------------------------------------------------------------------------------
# 　主に移動ルートなどの処理を追加したキャラクターのクラスです。Game_Player、
# Game_Follower、GameVehicle、Game_Event のスーパークラスとして使用されます。
#==============================================================================

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # ○ 目を閉じる
  #--------------------------------------------------------------------------
  def sleep
    if @character_name.include?("_cos")
      @tile_id = 0
      @character_name = @character_name.gsub(/cos/) { "sleep" }
      @original_pattern = 1
    end
  end
  #--------------------------------------------------------------------------
  # ○ 目を開ける
  #--------------------------------------------------------------------------
  def wakeup
    if @character_name.include?("_sleep")
      @tile_id = 0
      @character_name = @character_name.gsub(/sleep/) { "cos" }
      @original_pattern = 1
    end
  end
end


#==============================================================================
# □ Window_Costume
#------------------------------------------------------------------------------
# 　着替え画面で表示するアクターグラフィックウィンドウです。
#==============================================================================

class Window_Costume < Window_Base
  include COSTUME
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(hh)
    super(240, hh, window_width, window_height - hh)
    @actor = nil
    #@temp_actor = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 240
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height
  end
  #--------------------------------------------------------------------------
  # ○ アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_stand(@actor, 1, 4, 0) if @actor
    draw_costume(@actor, 4, 0) if @actor
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def draw_costume(actor, x, y)
    change_color(system_color)
    draw_text(x, y, 172, line_height, "現在の衣装")
    wear = $game_temp.wear_items[actor.id].select {|item| item.costume[1] == actor.costume.to_i }
    change_color(normal_color)
    draw_item_name(wear[0], x + 8, y + line_height)
    #draw_text(x + 8, y + linheight, 172, line_height, wear[0].name)
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, cos_w_name(item.name))
  end
  #--------------------------------------------------------------------------
  # ○ グラフィックの描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_stand(actor, member_size, x, y, enabled = true)
    bitmap = Cache.stand("#{actor.graphic_name}_cos#{actor.costume}")
    space = 0
    rect = Rect.new(actor.stand_ox[member_size - 1] - 25, actor.graphic_status_oy, contents_width - space, contents_height) #Rect.new(stand_index % 4 * 96, stand_index / 4 * 96, item_width, 288)# / num, 288) #272 / num, 288)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
end

#==============================================================================
# □ Window_CostumeList
#------------------------------------------------------------------------------
# 　
#==============================================================================

class Window_CostumeList < Window_ItemList
  include COSTUME
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # ステータスウィンドウ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @actor = nil
    select(0)
    activate
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false if item.costume.empty?
    return @actor.id == item.costume[0]
  end
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    !wearing?(item) && wearable_switch(item) && wearable_point(item)
  end
  #--------------------------------------------------------------------------
  # ○ 衣装を装備中か
  #--------------------------------------------------------------------------
  def wearing?(item)
    return false if item == nil
    return format("%02d",item.costume[1]) == @actor.costume
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def wearable_switch(item)
    return false if item == nil
    return true if item.wearing_conditions[0] <= 0
    return $game_switches[item.wearing_conditions[0]]
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def wearable_point(item)
    return false if item == nil
    return true if item.wearing_conditions[1] <= 0
    #return @actor.sex_all_count >= item.wearing_conditions[1]
    return $game_variables[FAKEREAL::SEX_POINT] >= item.wearing_conditions[1]
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    if wearing?(item)
      draw_icon(item.icon_index, x, y)
      change_color(system_color)
    else
      draw_icon(item.icon_index, x, y, enabled)
      change_color(normal_color, enabled)
    end
    draw_text(x + 24, y, width, line_height, cos_w_name(item.name))
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの設定
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウ更新メソッドの呼び出し
  #--------------------------------------------------------------------------
  #def call_update_help
    #update_help if active
  #end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
    #if @actor && @status_window && item
      #temp_actor = Marshal.load(Marshal.dump(@actor))
      #temp_actor.costume_change(item.costume[1])
      #@status_window.set_temp_actor(temp_actor)
    #end
  end
end

class RPG::BaseItem
  def costume
    @costume ||= costume_set
  end
  def costume_set #                                   アクターID 衣装ID
    return [$1.to_i, $2.to_i] if self.note =~ /\<衣装:(\d+)\,(\d+)\>/
    return []
  end
  def wearing_conditions
    @wearing_conditions ||= wearing_conditions_set
  end
  def wearing_conditions_set #                     スイッチ 0で関係なし　性経験
    return [$1.to_i, $2.to_i] if self.note =~ /\<着衣条件:(\d+)\,(\d+)\>/
    return [0, 0]
  end
end

#==============================================================================
# ■ Window_ItemList
#------------------------------------------------------------------------------
# 　アイテム画面で、所持アイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか　※エイリアス
  #--------------------------------------------------------------------------
  alias costume_enable? enable?
  def enable?(item)
    #return false if !item
    if note_check(item, FAKEREAL::COSCHANGE)#item.note.include?(TelepoMap::TELEPO)
      costume_enable?(item) && $game_party.costume_change_ok?
    else
      costume_enable?(item)
    end
  end
end

#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 着替えの許可状態 
  #--------------------------------------------------------------------------
  def costume_change_ok?
    can_costume_change? && ccc_map?
  end
  #--------------------------------------------------------------------------
  # ○ 着替え可能判定
  #--------------------------------------------------------------------------
  def can_costume_change?
    !$game_switches[FAKEREAL::COSTUME_CHANGE_SWITCH]
  end
  #--------------------------------------------------------------------------
  # ○ 着替え可能マップか
  #--------------------------------------------------------------------------
  def ccc_map?
    !$game_map.note.include?(FAKEREAL::NOT_COSCHANGE)
  end
  #--------------------------------------------------------------------------
  # 〇 着替えメンバーの取得
  #--------------------------------------------------------------------------
  def costume_members
    $game_actors[1].skill_learn?($data_skills[94]) ? members + [$game_actors[5]] : members
  end
  #--------------------------------------------------------------------------
  # 〇 着替え画面で次のアクターを選択
  #--------------------------------------------------------------------------
  def costume_actor_next
    index = costume_members.index(menu_actor) || -1
    index = (index + 1) % costume_members.size
    self.menu_actor = costume_members[index]
  end
  #--------------------------------------------------------------------------
  # 〇 着替え画面で前のアクターを選択
  #--------------------------------------------------------------------------
  def costume_actor_prev
    index = costume_members.index(menu_actor) || 1
    index = (index + costume_members.size - 1) % costume_members.size
    self.menu_actor = costume_members[index]
  end
end

#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 　装備画面の処理を行うクラスです。
#==============================================================================

class Scene_CostumeChange < Scene_MenuBase
  include FRCS
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    @actor = $game_party.menu_actor = $game_party.target_actor
    create_help_window
    create_status_window
    create_item_window
  end
  #--------------------------------------------------------------------------
  # ● ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_Costume.new(@help_window.height)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # ● アイテムウィンドウの作成
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 0
    wy = @status_window.y
    ww = Graphics.width - @status_window.width
    wh = Graphics.height - wy
    @item_window = Window_CostumeList.new(wx, wy, ww, wh)
    @item_window.viewport = @viewport
    #@item_window.help_window = @help_window
    @item_window.status_window = @status_window
    @item_window.actor = @actor
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:return_scene))
    @item_window.set_handler(:pagedown, method(:next_actor))
    @item_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● アイテム［決定］
  #--------------------------------------------------------------------------
  def on_item_ok
    Sound.play_equip
    @actor.costume_change(@item_window.item.costume[1])
    @status_window.refresh
    @item_window.refresh
    @item_window.activate
    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    @status_window.actor = @actor
    #@status_window.set_temp_actor(nil)
    @item_window.actor = @actor
    #@status_window.refresh
    @item_window.select(0)
    @item_window.activate
  end
=begin
  #--------------------------------------------------------------------------
  # ● 次のアクターに切り替え
  #--------------------------------------------------------------------------
  def next_actor
    #@actor = $game_party.menu_actor_next
    @actor = $game_party.costume_actor_next
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターに切り替え
  #--------------------------------------------------------------------------
  def prev_actor
    #@actor = $game_party.menu_actor_prev
    @actor = $game_party.costume_actor_prev
    on_actor_change
  end
=end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  #def create_help_window
    #@help_window = Window_Help.new(1)
    #@help_window.viewport = @viewport
    #@help_window.set_text("変更する衣装を選択して下さい。青文字は現在の衣装です")
  #end
end

#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ○ 衣装アイテム
  #--------------------------------------------------------------------------
  def wear_items
    @wear_items ||= wear_item_set
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def wear_item_set
    wear = {}
    data = $data_items.select {|item| item && !item.costume.empty? }
    5.times do |id|
      wear[id + 1] = data.select {|item| item.costume[0] == (id + 1)}
    end
    return wear
  end
end


#==============================================================================
# ■ Window_MenuActor
#------------------------------------------------------------------------------
# 　アイテムやスキルの使用対象となるアクターを選択するウィンドウです。
#==============================================================================

class Window_MenuActorWear < Window_MenuActor
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - (col_max == 4 ? 80 : 160)
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return $game_party.costume_members.size
  end
  #--------------------------------------------------------------------------
  # ○ シンプルなステータスの描画
  #--------------------------------------------------------------------------
  def draw_actor_simple_status_fr(actor, x, y)
    case $game_party.costume_members.size
    when 4
      w = 92
    else
      w = 124
    end
    num = contents_height / line_height
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_icons(actor, x, y + line_height * 2)
    draw_actor_class(actor, x, y + line_height * 3)
    draw_actor_hp(actor, x, y + line_height * (num - 3), w)
    draw_actor_mp(actor, x, y + line_height * (num - 2), w)
    draw_actor_tp(actor, x, y + line_height * (num - 1), w)
    #draw_actor_hp(actor, x, y + line_height * 14, w)
    #draw_actor_mp(actor, x, y + line_height * 15, w)
    #draw_actor_tp(actor, x, y + line_height * 16, w)
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.costume_members[index]
    enabled = true#$game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    case col_max
    when 1; ox = 100
    when 2; ox = 4
    when 3; ox = 4
    when 4; ox = 4
    else  ; ox = 0
    end
    draw_actor_stand(actor, rect.x + ox, rect.y, enabled)
    draw_actor_simple_status_fr(actor, rect.x + 1, rect.y)
  end
  #--------------------------------------------------------------------------
  # ● アクターの胸像グラフィック描画
  #--------------------------------------------------------------------------
  def draw_actor_stand(actor, x, y, enabled = true)
    draw_stand(actor, $game_party.costume_members.size, x, y, enabled)
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    $game_party.costume_members.size
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    $game_party.target_actor = $game_party.costume_members[index] unless @cursor_all
    call_ok_handler
  end
end

#==============================================================================
# ■ Scene_ItemBase
#------------------------------------------------------------------------------
# 　アイテム画面とスキル画面の共通処理を行うクラスです。
#==============================================================================

class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias wearing_cos_start start
  def start
    wearing_cos_start
    create_actorwear_window
  end
  #--------------------------------------------------------------------------
  # ● アクターウィンドウの作成
  #--------------------------------------------------------------------------
  def create_actorwear_window
    @actorwear_window = Window_MenuActorWear.new
    @actorwear_window.set_handler(:ok,     method(:on_actor_ok))
    @actorwear_window.set_handler(:cancel, method(:on_actor_cos_cancel))
  end
  #--------------------------------------------------------------------------
  # ● アクター［キャンセル］
  #--------------------------------------------------------------------------
  def on_actor_cos_cancel
    hide_sub_window(@actorwear_window)
  end
  #--------------------------------------------------------------------------
  # ● アイテムの決定
  #--------------------------------------------------------------------------
  alias wearing_cos_determine_item determine_item
  def determine_item
    if item.note.include?(FAKEREAL::COSCHANGE)
      @actorwear_window.refresh
      show_sub_window(@actorwear_window)
      @actorwear_window.select_for_item(item)
    else
      wearing_cos_determine_item
    end
  end
  #--------------------------------------------------------------------------
  # ● アクター［決定］
  #--------------------------------------------------------------------------
=begin
  def on_actor_cos_ok
    if item_usable?
      use_item
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムの使用
  #--------------------------------------------------------------------------
  def use_item
    play_se_for_item
    user.use_item(item)
    use_item_to_actors
    check_common_event
    check_gameover
    @actor_window.refresh
  end
=end
end
