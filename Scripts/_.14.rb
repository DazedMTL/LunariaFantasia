=begin
      RGSS3
      
　　　★ ゲーム内共有変数 ★

      設定箇所で指定したスイッチと変数をゲーム全体で共有します。
      
      ● 仕様 ●==========================================================
      スクリプト導入後にセーブするとゲームフォルダ内に新しく
      "PublicData"
      というrvdata2ファイルが自動的に作成されます。
      --------------------------------------------------------------------
      共有データセーブのタイミングは、通常のセーブ時
      共有データロードのタイミングは、通常のロード時＆ゲーム立ち上げ時です。
      ====================================================================
      
      ● イベントについて ●==============================================
      イベントコマンドのスクリプトに、
        write_public_data
      と記述すると、任意のタイミングで共有データのセーブを行うことができます。
      エンディング時などにどうぞ。
      ====================================================================
      
      ver1.00

      Last Update : 2011/12/17
      12/17 : RGSS2からの移植
      
      ろかん　　　http://kaisou-ryouiki.sakura.ne.jp/
=end



module PUBLIC_DATA
#----------------------------------------------------------------------------
# ● 設定箇所ここから
#----------------------------------------------------------------------------
  # 共有するスイッチ番号 (例 : SWITCH = [3, 7, 12])
  SWITCH = [89, 90, 306, 314, *(441..600)]
  MEMORY_S = [*(441..600)]
  # 共有する変数番号 (例 : VARIABLE = [1, 6])
  VARIABLE = [35, *(39..41), *(131..134)]
  # 通常のセーブと同時に共有データのセーブも行うかどうか(true/ false)
  S_AUTOSAVE = true
  #デフォ値追加
  DEFAULT_V = Hash[
                   39 => 4,
                   41 => 4,
                   131 => 1,
                   132 => 4,
                   133 => 4,
                   134 => 6,
  ]
#----------------------------------------------------------------------------
# ● 設定箇所ここまで
#----------------------------------------------------------------------------
end

$rsi ||= {}
$rsi["ゲーム内共有変数"] = true

$public = [{}, {}]
$message = Game_PublicSystem.new # 既読判定追加
#==============================================================================
# ■ PUBLIC_DATA
#------------------------------------------------------------------------------
# 　共有データの書き込み、読み込みを実行するモジュール
#==============================================================================
module PUBLIC_DATA
  # 共有データファイル名
  FILE_NAME = "Save/PublicData.rvdata2"
  READ_NAME = "Save/Message.rvdata2" # 既読判定追加
  #--------------------------------------------------------------------------
  # ● 共有データの書き込み
  #--------------------------------------------------------------------------
  def self.write_public_data
    SWITCH.each do |i|
      if MEMORY_S.include?(i)
        $public[0][i] = $game_switches[i] if $game_switches[i]
      else
        $public[0][i] = $game_switches[i]
      end
    end
    VARIABLE.each{|i| $public[1][i] = $game_variables[i]}
    #$message.memory($game_system.kidoku) # 既読判定追加
    $message.memory($game_temp.kidoku) # 既読判定追加
    save_data($public, FILE_NAME)
    save_data($message, READ_NAME) # 既読判定追加
  end
  #--------------------------------------------------------------------------
  # ● 共有データの読み込み
  #--------------------------------------------------------------------------
  def self.read_public_data
    if File.exist?(FILE_NAME)
      $public = load_data(FILE_NAME)
      $public[0].each_pair{|key, value|
        $game_switches[key] = value if SWITCH.include?(key)
      }
      $public[1].each_pair{|key, value|
        $game_variables[key] = value if VARIABLE.include?(key)
      }
    end
    
    DEFAULT_V.each_pair{|key, value| #デフォ値追加
      $game_variables[key] = value if VARIABLE.include?(key) && $game_variables[key] == 0
    }
    
    if File.exist?(READ_NAME) # 既読判定追加
      $message = load_data(READ_NAME)
      $message.remember
    end
    #p $public
    #p $message
    #p $game_switches
    #p $game_variables
  end
end

class << DataManager
  #--------------------------------------------------------------------------
  # ● 各種ゲームオブジェクトの作成
  #--------------------------------------------------------------------------
  alias public_data_create_game_objects create_game_objects
  def create_game_objects
    public_data_create_game_objects
    PUBLIC_DATA.read_public_data
  end
  #--------------------------------------------------------------------------
  # ● セーブの実行
  #--------------------------------------------------------------------------
  alias public_data_save_game save_game
  def save_game(index)
    if public_data_save_game(index)
      PUBLIC_DATA.write_public_data
      true
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● ロードの実行
  #--------------------------------------------------------------------------
  alias public_data_load_game load_game
  def load_game(index)
    if public_data_load_game(index)
      $game_temp = Game_Temp.new # ロード時に$game_tempを念の為リセット
      PUBLIC_DATA.read_public_data
      true
    else
      false
    end
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 共有データの保存
  #--------------------------------------------------------------------------
  def write_public_data
    PUBLIC_DATA.write_public_data
  end
end
