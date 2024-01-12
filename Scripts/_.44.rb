module FAKEREAL
  
  BGM_SWITCHE      = 10 #場所移動によるBGM自動変更禁止スイッチ
  BGS_SWITCHE      = 11 #場所移動によるBGS自動変更禁止スイッチ
  TONE_SWITCHE     = 12 #場所移動時のトーン変更禁止
  
end

class RPG::Map
  def sbgm
    self.note =~ /<BGM:([^:>]*):v(\d+),p(\d+)>/i ? RPG::BGM.new($1,$2.to_i, $3.to_i) : nil
  end
  def sbgs
    self.note =~ /<BGS:([^:]*):v(\d+),p(\d+)>/i ? RPG::BGS.new($1, $2.to_i, $3.to_i) : nil
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
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias map_setup setup
  def setup(map_id)
    map_setup(map_id)
    setup_tone unless $game_switches[FAKEREAL::TONE_SWITCHE]
    second_bgm_set
    second_bgs_set
  end
  #--------------------------------------------------------------------------
  # ○ マップのメモ内容の取得
  #--------------------------------------------------------------------------
  def note
    @map.note
  end
  #--------------------------------------------------------------------------
  # ○ マップの名前の取得　※セーブ、メニュー画面の現在地表示用
  #--------------------------------------------------------------------------
  def save_name
    r_id = $game_player.region_id
    return $1 if note =~ /<セーブ名:#{r_id}:?(\D+?)>/
    return $1 if note =~ /<セーブ名:(\D+?)>/
    return display_name
  end
  #--------------------------------------------------------------------------
  # ○ トーン変更の影響を受けないマップ判定
  #--------------------------------------------------------------------------
  def no_day_tone
    return true if note =~ /\<時間トーン変更なし\>/
    return false
  end
=begin
  #--------------------------------------------------------------------------
  # ○ マップ上の目標レベル
  #--------------------------------------------------------------------------
  def no_encount_level
    plus = ($game_system.true_route? && $game_map.note =~ /\<トゥルールート:(\d+)\>/) ? $1.to_i : 0
    return plus + $1.to_i if note =~ /\<目標Lv:(\d+)\>/
    return 99
  end
=end
  #--------------------------------------------------------------------------
  # ○ マップのデフォルト色調のセットアップ
  #    ※普段からずっと暗い街等を作る際の対策 & 時間システム
  #--------------------------------------------------------------------------
  def setup_tone
    if note =~ /<色調変更:([+|-]\d+),([+|-]\d+),([+|-]\d+),(\d+)>/
      # 負数判定の為に rgb には必ず + - の記号を付ける事。grayは逆につけないように
      @screen.tone.set($1.to_i, $2.to_i, $3.to_i, $4.to_i)
    elsif no_day_tone
      @screen.tone.set(0, 0, 0, 0)
    else
      case $game_system.game_day
      when :day
        @screen.tone.set(0, 0, 0, 0)
      when :evening
        @screen.tone.set(FAKEREAL::EVEN_TONE)
      when :night
        @screen.tone.set(FAKEREAL::NIGHT_TONE)
      when :midnight
        @screen.tone.set(FAKEREAL::MIDNIGHT_TONE)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 遠景のセットアップ　※エイリアス
  #--------------------------------------------------------------------------
  alias game_time_setup_parallax setup_parallax
  def setup_parallax
    game_time_setup_parallax
    if note =~ /<遠景:(\w+),(\w+),(\w+)>/
      case $game_system.game_day
      when :evening
        @parallax_name = $1
      when :night
        @parallax_name = $2
      when :midnight
        @parallax_name = $3
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ　※エイリアス
  #--------------------------------------------------------------------------
  alias game_time_parallax_refresh refresh
  def refresh
    time_change_parallax
    game_time_parallax_refresh
  end
  #--------------------------------------------------------------------------
  # ○ 時間変更に伴う遠景の更新
  #--------------------------------------------------------------------------
  def time_change_parallax
    if note =~ /<遠景:(\w+),(\w+),(\w+)>/
      case $game_system.game_day
      when :day
        @parallax_name = @map.parallax_name
      when :evening
        @parallax_name = $1
      when :night
        @parallax_name = $2
      when :midnight
        @parallax_name = $3
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● BGM / BGS 自動切り替え　※再定義
  #--------------------------------------------------------------------------
  def autoplay
    #if $game_switches[FAKEREAL::BGM_SWITCHE] || $game_switches[FAKEREAL::BGS_SWITCHE]
      map_bgm_play if @map.autoplay_bgm && !$game_switches[FAKEREAL::BGM_SWITCHE]
      map_bgs_play if @map.autoplay_bgs && !$game_switches[FAKEREAL::BGS_SWITCHE]
    #else
      #map_bgm_play if @map.autoplay_bgm
      #map_bgs_play if @map.autoplay_bgs
    #end
  end
  #--------------------------------------------------------------------------
  # 〇 BGMの演奏　※トゥルールートでBGMを変更する処理を可能に
  #--------------------------------------------------------------------------
  def map_bgm_play
    #if $game_system.true_route? && @second_bgm
      #second_bgm_play
    #else
      #@map.bgm.play
    #end
    ($game_system.true_route? && @second_bgm) ? second_bgm_play : @map.bgm.play
  end
  #--------------------------------------------------------------------------
  # 〇 BGSの演奏
  #--------------------------------------------------------------------------
  def map_bgs_play
    #if $game_system.true_route? && @second_bgs
      #second_bgs_play
    #else
      #@map.bgs.play
    #end
    ($game_system.true_route? && @second_bgs) ? second_bgs_play : @map.bgs.play
  end
  #--------------------------------------------------------------------------
  # 〇 別ルート用BGM
  #--------------------------------------------------------------------------
  def second_bgm_set
    @second_bgm = @map.sbgm #note =~ /<BGM:([^:>]*):v(\d+),p(\d+)>/i ? RPG::BGM.new($1,$2.to_i, $3.to_i) : nil
    #@second_bgm = note =~ /<BGM:([^:>]*):v(\d+),p(\d+)>/i ? [$1, $2.to_i, $3.to_i] : nil
  end
  #--------------------------------------------------------------------------
  # 〇 別ルート用BGMの演奏
  #--------------------------------------------------------------------------
  def second_bgm_play
    #(RPG::BGM.new(@second_bgm[0], @second_bgm[1], @second_bgm[2])).play
    @second_bgm.play
  end
  #--------------------------------------------------------------------------
  # 〇 別ルート用BGS
  #--------------------------------------------------------------------------
  def second_bgs_set
    @second_bgs = @map.sbgs #note =~ /<BGS:([^:]*):v(\d+),p(\d+)>/i ? RPG::BGS.new($1, $2.to_i, $3.to_i) : nil
    #@second_bgs = note =~ /<BGS:([^:]*):v(\d+),p(\d+)>/i ? [$1, $2.to_i, $3.to_i] : nil
  end
  #--------------------------------------------------------------------------
  # 〇 別ルート用BGSの演奏
  #--------------------------------------------------------------------------
  def second_bgs_play
    @second_bgs.play
    #(RPG::BGS.new(@second_bgs[0], @second_bgs[1], @second_bgs[2])).play
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
  # ○ BGM / BGS デフォルトに切り替え
  #--------------------------------------------------------------------------
  def bgm_play
    $game_map.autoplay
  end
end