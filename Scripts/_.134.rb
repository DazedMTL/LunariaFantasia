#==============================================================================
# ■ Scene_Gameover
#------------------------------------------------------------------------------
# 　ゲームオーバー画面の処理を行うクラスです。
#==============================================================================

class Scene_Gameover < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias exgo_start start
  def start
    exgo_start
    create_command_window
    create_gohelp_window
    $game_temp.clear_common_event
  end
  #--------------------------------------------------------------------------
  # ● 終了処理　※再定義
  #--------------------------------------------------------------------------
  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_background
  end
  #--------------------------------------------------------------------------
  # ● フェードイン速度の取得　※再定義
  #--------------------------------------------------------------------------
  def fadein_speed
    return 60
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    if Input.trigger?(:C) || Input.trigger?(:B)
      @command_window.open
      @gohelp_window.open
    end
  end
  #--------------------------------------------------------------------------
  # ○ コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gohelp_window
    @gohelp_window = Window_GOHelp.new(@command_window.y)
  end
  #--------------------------------------------------------------------------
  # ○ コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_GOChoice.new
    @command_window.set_handler(:retry, method(:command_retry))
    @command_window.set_handler(:easy, method(:command_easy))
    @command_window.set_handler(:continue, method(:command_continue))
    @command_window.set_handler(:to_title, method(:command_to_title))
  end
  #--------------------------------------------------------------------------
  # ● コマンド［そのままリトライ］
  #--------------------------------------------------------------------------
  def command_retry
    close_command_window
    fadeout_all
    SceneManager.retry_battle
  end
  #--------------------------------------------------------------------------
  # ● コマンド［イージーでリトライ］
  #--------------------------------------------------------------------------
  def command_easy
    close_command_window
    fadeout_all
    $game_system.easy_set
    SceneManager.retry_battle
  end
  #--------------------------------------------------------------------------
  # ● コマンド［ロード］
  #--------------------------------------------------------------------------
  def command_continue
    close_command_window
    #fadeout_all
    SceneManager.call(Scene_Load)
  end
  #--------------------------------------------------------------------------
  # ● コマンド［タイトルへ］
  #--------------------------------------------------------------------------
  def command_to_title
    close_command_window
    fadeout_all
    SceneManager.goto(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウを閉じる
  #--------------------------------------------------------------------------
  def close_command_window
    @gohelp_window.close
    @command_window.close
    update until @command_window.close? && @gohelp_window.close?
  end
end

#==============================================================================
# □ Window_GOChoice
#------------------------------------------------------------------------------
# 　"リトライ"か"タイトル"を選択するウィンドウです。
#==============================================================================

class Window_GOChoice < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    update_placement
    select_symbol(:retry)
    self.openness = 0
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 240
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ位置の更新
  #--------------------------------------------------------------------------
  def update_placement
    self.x = (Graphics.width - width) / 2
    self.y = (Graphics.height * 1.6 - height) / 2
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Retry",      :retry)
    add_command("Retry on Easy",      :easy, easy_enabled)
    add_command("Load", :continue, continue_enabled)
    add_command(Vocab::to_title, :to_title)
  end
  #--------------------------------------------------------------------------
  # ● イージーの有効状態を取得
  #--------------------------------------------------------------------------
  def easy_enabled
    $game_system.difficulty != :easy
  end
  #--------------------------------------------------------------------------
  # ● コンティニューの有効状態を取得
  #--------------------------------------------------------------------------
  def continue_enabled
    DataManager.save_file_exists?
  end
end

#==============================================================================
# □ 
#------------------------------------------------------------------------------
# 
#   
#==============================================================================

class Window_GOHelp < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(cy)
    super(0, cy - window_height, window_width, window_height)
    self.openness = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    return fitting_height(6)
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    gold = $game_actors[1].level * 10
    draw_text_ex(4, line_height * 0, "#{gold} (Cost to retry is Lunaria's level × 10).")
    draw_text_ex(4, line_height * 1, "All characters will be fully healed.")
    draw_text_ex(4, line_height * 2, "Any items used will be returned.")
    draw_text_ex(4, line_height * 3, "If you've changed weapons, it will remain that way")
    draw_text_ex(4, line_height * 4, "You can still retry even if no gold.")
    draw_text_ex(4, line_height * 5, "(If you retry on easy mode, easy mode will be maintained.)")
  end
end

#==============================================================================
# ■ SceneManager
#------------------------------------------------------------------------------
# 　シーン遷移を管理するモジュールです。たとえばメインメニューからアイテム画面
# を呼び出し、また戻るというような階層構造を扱うことができます。
#==============================================================================

module SceneManager
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def self.retry_battle
    RPG::ME.stop
    Graphics.update
    Graphics.freeze
    $game_switches = FAKEREAL.deep_copy($game_temp.retry_data[0]) #スイッチの再設定
    $game_variables = FAKEREAL.deep_copy($game_temp.retry_data[1]) #変数の再設定
    $game_party.item_retry_revival($game_temp.used_item) #使用アイテムの復活
    $game_party.lose_gold($game_actors[1].level * 10) #所持金の減少
    $game_party.inn #パーティ回復
    $game_system.retry_set #敵レベル配列等のセット
    BattleManager.setup($game_temp.troop_id, $game_temp.can_escape, $game_temp.can_lose)
    BattleManager.retry_bgm #戦闘前BGM等のセットし直し
    goto(Scene_Battle)#SceneManager.
    BattleManager.play_battle_bgm
    Sound.play_battle_start
  end
  #--------------------------------------------------------------------------
  # 確認用
  #--------------------------------------------------------------------------
  def self.stack
    @stack
  end
end

class << BattleManager
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias retry_setup setup
  def setup(troop_id, can_escape = true, can_lose = false)
    retry_data_set(troop_id, can_escape, can_lose)
    retry_setup(troop_id, can_escape, can_lose)
  end
  #--------------------------------------------------------------------------
  # ● BGM と BGS の保存
  #--------------------------------------------------------------------------
  alias retry_save_bgm_and_bgs save_bgm_and_bgs
  def save_bgm_and_bgs
    retry_save_bgm_and_bgs
    $game_temp.map_bgm = @map_bgm
    $game_temp.map_bgs = @map_bgs
  end
  #--------------------------------------------------------------------------
  # ● 戦闘終了
  #     result : 結果（0:勝利 1:逃走 2:敗北）
  #--------------------------------------------------------------------------
  alias retry_battle_end battle_end
  def battle_end(result)
    if result == 2
      $game_temp.escape_rate += 0.1
    else
      $game_temp.escape_rate = 0
    end
    retry_battle_end(result)
  end
  #--------------------------------------------------------------------------
  # ● 逃走成功率の作成
  #--------------------------------------------------------------------------
  alias retry_make_escape_ratio make_escape_ratio
  def make_escape_ratio
    retry_make_escape_ratio
    @escape_ratio += $game_temp.escape_rate
  end
  #--------------------------------------------------------------------------
  # ○ BGM と BGS の保存　リトライ用
  #--------------------------------------------------------------------------
  def retry_bgm
    @map_bgm = $game_temp.map_bgm
    @map_bgs = $game_temp.map_bgs
  end
  #--------------------------------------------------------------------------
  # ○ リトライ用保存データの設定
  #--------------------------------------------------------------------------
  def retry_data_set(troop_id, can_escape, can_lose)
    $game_temp.retry_reset
    $game_temp.troop_id = troop_id
    $game_temp.can_escape = can_escape
    $game_temp.can_lose = can_lose
    $game_temp.retry_data.push(FAKEREAL.deep_copy($game_switches))
    $game_temp.retry_data.push(FAKEREAL.deep_copy($game_variables))
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
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :can_escape             # 
  attr_accessor :can_lose               # 
  attr_accessor :troop_id               # 
  attr_accessor :map_bgm                # 
  attr_accessor :map_bgs                # 
  attr_accessor :retry_data             # 
  attr_accessor :used_item              # 
  attr_accessor :escape_rate            # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias retry_initialize initialize
  def initialize
    retry_initialize
    @map_bgm = nil              # 戦闘前の BGM 記憶用
    @map_bgs = nil              # 戦闘前の BGS 記憶用
    retry_reset
    @escape_rate = 0
  end
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def retry_reset
    @can_escape = true
    @can_lose = false
    @troop_id = 1
    @retry_data = []
    @used_item = {}
  end
end

#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは $game_system で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def retry_set
    enemy_level_reset
    enemy_hpp_reset
    $game_troop.members.each{|enemy|
      enemy_level_set(enemy.level)
      enemy_hpp_set(enemy.hpp)
    }
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
  alias retry_terminate terminate
  def terminate
    retry_terminate
    $game_system.enemy_level_reset
    $game_system.enemy_hpp_reset
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
  # ● アイテムの消耗
  #    指定されたオブジェクトが消耗アイテムであれば、所持数を 1 減らす。
  #--------------------------------------------------------------------------
  alias retry_consume_item consume_item
  def consume_item(item)
    if item.is_a?(RPG::Item) && item.consumable && $game_party.in_battle
      $game_temp.used_item[item.id] = 0 if !$game_temp.used_item[item.id]
      $game_temp.used_item[item.id] += 1
    end
    retry_consume_item(item)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def item_retry_revival(item_hash)
    item_hash.each {|id, amount| gain_item($data_items[id], amount) }
  end
end