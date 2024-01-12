#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  HEVENT_MAP  = 56              # Hイベント置き場のマップID
  EX_HEVENT_MAP  = 239          # サブキャラ等のHイベント置き場のマップID
  TR_HEVENT_MAP  = 432          # 高潔ルートHイベント置き場のマップID
  #--------------------------------------------------------------------------
  # ○ マップイベント呼び出し　※エロイベントをマップに設定して呼び出す用
  #--------------------------------------------------------------------------
  def another_ce(event_id, page = 0, map_id = HEVENT_MAP)
    a_me = load_data(sprintf("Data/Map%03d.rvdata2", map_id)).events[event_id]
    #a_list = a_map.events[event_id] ? a_map.events[event_id].pages[page].list : nil
    a_list = a_me ? (a_me.pages[page] ? a_me.pages[page].list : nil) : nil
    if a_list
      child = Game_Interpreter.new(@depth + 1)
      #child.setup(a_list, same_map? ? @event_id : 0)
      child.h_event_setup(a_list, event_id, map_id, page)
      child.neutral_run
    end
  end
  #--------------------------------------------------------------------------
  # ○ マップイベント呼び出し　※サブキャラエロイベントをマップに設定して呼び出す用
  #--------------------------------------------------------------------------
  def another_ce_ex(event_id, page = 0, map_id = EX_HEVENT_MAP)
    another_ce(event_id, page, map_id)
=begin
    a_me = load_data(sprintf("Data/Map%03d.rvdata2", map_id)).events[event_id]
    a_list = a_me ? (a_me.pages[page] ? a_me.pages[page].list : nil) : nil
    if a_list
      child = Game_Interpreter.new(@depth + 1)
      child.h_event_setup(a_list, event_id, map_id, page)
      child.neutral_run
    end
=end
  end
  #--------------------------------------------------------------------------
  # ○ マップイベント呼び出し　※高潔ルートエロイベントをマップに設定して呼び出す用
  #--------------------------------------------------------------------------
  def another_ce_tr(event_id, page = 0, map_id = TR_HEVENT_MAP)
    another_ce(event_id, page, map_id)
=begin
    a_me = load_data(sprintf("Data/Map%03d.rvdata2", map_id)).events[event_id]
    a_list = a_me ? (a_me.pages[page] ? a_me.pages[page].list : nil) : nil
    if a_list
      child = Game_Interpreter.new(@depth + 1)
      child.h_event_setup(a_list, event_id, map_id, page)
      child.neutral_run
    end
=end
  end
  #--------------------------------------------------------------------------
  # ○ マップイベント呼び出し　※セクハラ用
  #--------------------------------------------------------------------------
  def another_ce_sh(event_id, page = 0, map_id = HEVENT_MAP)
    a_me = load_data(sprintf("Data/Map%03d.rvdata2", map_id)).events[event_id]
    a_list = a_me ? (a_me.pages[page] ? a_me.pages[page].list : nil) : nil
    if a_list
      child = Game_Interpreter.new(@depth + 1)
      child.h_event_setup(a_list, event_id, map_id, page, true)
      child.neutral_run
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def next_cg(plus = 1, number = 1)
    name = screen.pictures[number].name
    name = name.gsub(/^DMZ\//) { "" }
    name = name.gsub(/^FUTA\//) { "" }
    name = name.gsub(/^SAN\//) { "" }
    if name =~ /^\w+_\d+?_(\d+?)$/
      sn = $1.to_i + plus
      name = name.gsub(/\d+?$/) { format("%02d",sn) }
      name = FAKEREAL.cg_select(name)
      screen.pictures[number].change(name)
      #if !$game_switches[Option::EXH_D] && FAKEREAL.cg_exists?(name)
        #screen.pictures[number].change("DMZ/" + name)
      #else
        #screen.pictures[number].change(name)
      #end
    end
    #@character_name = @character_name.gsub(/cos/) { "sleep" }
    #if @character_name =~ /fr_main_(cos|down|sleep)$/ #== "fr_main_cos01" 
    #  @character_name + "#{$game_actors[@character_index + 1].costume}"
    #else
    #  cos_character_name
    #end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def disp_cg(cg = 0, number = 1)
    name = screen.pictures[number].name
    if name =~ /^\w+_\d+?_(\d+?)$/
      sn = $1.to_i + 1
      name = name.gsub(/\d+?_\d+?$/) { "#{format("%02d",cg)}_#{format("%02d",sn)}" }
      screen.pictures[number].change(name)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def skip_disp_cg(cg = 0, number = 1, skip)
    name = screen.pictures[number].name
    if name =~ /^\w+_\d+?_(\d+?)$/
      sn = $1.to_i + skip
      name = name.gsub(/\d+?_\d+?$/) { "#{format("%02d",cg)}_#{format("%02d",sn)}" }
      screen.pictures[number].change(name)
    end
  end
  #--------------------------------------------------------------------------
  # 〇 Hイベントのセットアップ
  #--------------------------------------------------------------------------
  def h_event_setup(list, event_id, map_id, page, harassment = false)
    clear
    @map_id = map_id
    @event_id = event_id
    @page = page
    @harassment = harassment
    @list = list
    create_fiber
  end
  #--------------------------------------------------------------------------
  # 〇 セクハライベントのセットアップ
  #--------------------------------------------------------------------------
  def harassment_setup(list, event_id, map_id, page)
    clear
    @map_id = map_id
    @event_id = event_id
    @page = page
    @harassment = true
    @list = list
    create_fiber
  end
  #--------------------------------------------------------------------------
  # ● クリア
  #--------------------------------------------------------------------------
  alias harassment_clear clear
  def clear
    harassment_clear
    @harassment = false
  end
  #--------------------------------------------------------------------------
  # ● キャラクターの取得
  #     param : -1 ならプレイヤー、0 ならこのイベント、それ以外はイベント ID
  #--------------------------------------------------------------------------
  alias harassment_get_character get_character
  def get_character(param)
    if @harassment
      if $game_party.in_battle
        nil
      elsif param < 0
        $game_player
      else
        events = $game_map.events
        events[param > 0 ? param : @event_id]
      end
    else
      harassment_get_character(param)
    end
  end
end

#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　マップを扱うクラスです。スクロールや通行可能判定などの機能を持っています。
# このクラスのインスタンスは $game_map で参照されます。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :map_id                   # マップ画面の状態
end