#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは $game_system で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 定数（特徴）
  #--------------------------------------------------------------------------
  TRUE_ROUTE  = 20              # トゥルールート判定スイッチ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias chapter_initialize initialize
  def initialize
    chapter_initialize
    chapter_reset
  end
=begin
  attr_accessor :route              # 現在のルート
  #--------------------------------------------------------------------------
  #  ○ ルート変更
  #--------------------------------------------------------------------------
  def route_change(symbol)
    @route = symbol
  end
=end
  #--------------------------------------------------------------------------
  #  ○ ※周回テストデータの調整用
  #--------------------------------------------------------------------------
  def chapter_delete
    p @chapter_title
    10.times{|i| @chapter_title.shift }
    p @chapter_title
  end
  #--------------------------------------------------------------------------
  #  ○ チャプターリセット
  #--------------------------------------------------------------------------
  def chapter_reset
    @chapter_title = []
  end
  #--------------------------------------------------------------------------
  #  ○ チャプター進行
  #--------------------------------------------------------------------------
  def next_chapter
    @chapter_title.push(Chapter.chapter_id($game_variables[Chapter::CHAPTER_NUMBER]))
  end
  #--------------------------------------------------------------------------
  #  ○ 現在のチャプタータイトル
  #--------------------------------------------------------------------------
  def now_chapter
    chapter_name($game_variables[Chapter::CHAPTER_NUMBER])
  end
  #--------------------------------------------------------------------------
  #  ○ チャプター名の取得
  #--------------------------------------------------------------------------
  def chapter_name(num)
    Chapter.chapter_name(@chapter_title[num])
  end
  #--------------------------------------------------------------------------
  #  ○ トゥルールートか
  #--------------------------------------------------------------------------
  def true_route?
    $game_switches[TRUE_ROUTE]
    #@route == :true
  end
  #--------------------------------------------------------------------------
  #  ○ トゥルールートの条件チェック
  #--------------------------------------------------------------------------
  def true_check
    $game_actors[1].virgin && $game_variables[FAKEREAL::SEX_POINT] == 0 && $game_actors[1].sex_all_count == 0
  end
  #--------------------------------------------------------------------------
  #  ○ 塔にてトゥルールートに入るかチェック
  #--------------------------------------------------------------------------
  def tower_check
    true_check && $game_switches[212] && $game_switches[213]
  end
end

module Chapter
  #--------------------------------------------------------------------------
  # 〇 定数
  #--------------------------------------------------------------------------
  CHAPTER_NUMBER  = 22              # チャプター管理変数
  BEFORE_TR  = 19               # トゥルールート事前確定スイッチ
  #--------------------------------------------------------------------------
  #  ○ チャプター名
  #--------------------------------------------------------------------------
  def self.chapter_name(id)
    case id
    when "00"  ; "Prologue: The Magic Kingdom and the Court Magician"
    when "01"  ; "Chapter One: The Ruins Deep in the Forest"
    when "02"  ; "Chapter Two: Encounter"
    when "03"  ; "Chapter Three: The Ice Temple"
    when "04"  ; "Chapter Four: The Shrine Maiden's Village"
    when "05"  ; "Chapter Five: To the Kingdom of Dalia"
    when "06a" ; "Chapter Six: The Lurking Shadows"
    when "06b" ; "Chapter Six: The Dark Conspiracy and the Tycoon"
    when "07"  ; "Chapter Seven: The Religion of Depravity"
    when "08"  ; "Chapter Eight: The Last Jewel and Then..."
    when "09a" ; "Chapter Nine: Attack on Sagittarius!"
    when "09b" ; "Final Chapter: The Court Magician of Sagittarius"
    when "10"  ; "Chapter Ten: The Revival of Ancient Monsters"
    when "11"  ; "Chapter Eleven: The Evil Dragon"
    when "12"  ; "Chapter Twelve: The City of Decadence and Pleasure"
    when "13"  ; "Chapter Thirteen: The Brainwashing Demon's Trap"
    when "14"  ; "Final Chapter: The Inherited Magical Power"
    else       ; ""
    end
  end
  #--------------------------------------------------------------------------
  #  ○ チャプター名
  #--------------------------------------------------------------------------
  def self.chapter_id(num)
    case num
    when 0  ; "00"
    when 1  ; "01"
    when 2  ; "02"
    when 3  ; "03"
    when 4  ; "04"
    when 5  ; "05"
    when 6 
      if $game_system.true_check
        "06a"
      else
        "06b"
      end
    when 7  ; "07"
    when 8  ; "08"
    when 9
      if $game_switches[BEFORE_TR]
        "09a"
      else
        "09b"
      end
    when 10  ; "10"
    when 11  ; "11"
    when 12  ; "12"
    when 13  ; "13"
    when 14  ; "14"
    else       ; ""
    end
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
  #  ○ チャプター進行
  #--------------------------------------------------------------------------
  def next_chapter
    $game_system.next_chapter
  end
  #--------------------------------------------------------------------------
  #  ○ チャプター進行
  #--------------------------------------------------------------------------
  def chapter_reset
    $game_system.chapter_reset
  end
end