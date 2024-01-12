#==============================================================================
# ■ GiveUp
#------------------------------------------------------------------------------
#　戦闘でのお手軽敗北用のモジュールです。
#==============================================================================

module GiveUp
  #--------------------------------------------------------------------------
  # ○ 定数
  #--------------------------------------------------------------------------
  NAME = "降参"                 # コマンド名
  SWITCH = 1                    # 降参可能戦闘前にオンにするスイッチ番号
  SE = "Bell1"                  # 降参時のSE名
  VOL = 80                      # 降参SEのボリューム
  PITCH = 100                   # 降参SEのピッチ
end

#==============================================================================
# ■ Window_PartyCommand
#------------------------------------------------------------------------------
# 　バトル画面で、戦うか逃げるかを選択するウィンドウです。
#==============================================================================

class Window_PartyCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  alias giveup_make_command_list make_command_list
  def make_command_list
    giveup_make_command_list
    add_command(Vocab::escape, :escape, BattleManager.can_escape?) if !$game_switches[GiveUp::SWITCH] #BattleManager.can_escape?
    add_command(GiveUp::NAME,  :giveup, $game_switches[GiveUp::SWITCH], true) if $game_switches[GiveUp::SWITCH]
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    if command_giveup?(index)
      change_color(important_color, command_enabled?(index))
      draw_text(item_rect_for_text(index), command_name(index), alignment)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # 〇 コマンドの有効状態を取得
  #--------------------------------------------------------------------------
  def command_giveup?(index)
    @list[index][:ext]
  end
end

#==============================================================================
# □ Window_GiveUp
#------------------------------------------------------------------------------
# 　降参用のウィンドウ
#==============================================================================

class Window_GiveUp < Window_Base
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(2))
    self.y = Graphics.height / 2 - self.height / 2
    self.x = Graphics.width / 2 - self.width / 2
    self.z = 300
    self.back_opacity = 255
    self.visible = false
    self.arrows_visible = false
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 240
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_giveup(0, 0)
  end
  #--------------------------------------------------------------------------
  # ○ 降参の描画
  #--------------------------------------------------------------------------
  def draw_giveup(x, y)
    change_color(normal_color)
    draw_text(x + 4, y, contents_width, line_height, "この戦闘を降参します", 1)
    draw_text(x, y + line_height, contents_width, line_height, "よろしいですか？", 1)
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias giveup_create_all_windows create_all_windows
  def create_all_windows
    giveup_create_all_windows
    create_giveup_window
    create_yesno_window
  end
  #--------------------------------------------------------------------------
  # ○ ギブアップウィンドウの作成
  #--------------------------------------------------------------------------
  def create_giveup_window
    @giveup_window = Window_GiveUp.new
  end
  #--------------------------------------------------------------------------
  # ○ はい、いいえウィンドウの作成
  #--------------------------------------------------------------------------
  def create_yesno_window
    @yesno_window = Window_YesNoChoice.new
    @yesno_window.y = @giveup_window.y + @giveup_window.height
    @yesno_window.set_handler(:yes_select,     method(:on_giveup_ok))
    @yesno_window.set_handler(:no_select,      method(:on_giveup_cancel))
    @yesno_window.set_handler(:cancel,         method(:on_giveup_cancel))
  end
  #--------------------------------------------------------------------------
  # ● パーティコマンドウィンドウの作成　※エイリアス
  #--------------------------------------------------------------------------
  alias giveup_create_party_command_window create_party_command_window
  def create_party_command_window
    giveup_create_party_command_window
    @party_command_window.set_handler(:giveup,  method(:command_giveup))
  end
  #--------------------------------------------------------------------------
  # ○ コマンド［降参］
  #--------------------------------------------------------------------------
  def command_giveup
    @party_command_window.hide
    @giveup_window.show
    @yesno_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ○ 降参
  #--------------------------------------------------------------------------
  def on_giveup_ok
    play_se_for_giveup
    @giveup_window.hide
    @yesno_window.hide
    BattleManager.process_defeat
  end
  #--------------------------------------------------------------------------
  # ○ パーティコマンド選択へ
  #--------------------------------------------------------------------------
  def on_giveup_cancel
    Sound.play_cancel
    @giveup_window.hide
    @yesno_window.select(0)
    @yesno_window.hide.deactivate
    @party_command_window.show.activate
  end
  #--------------------------------------------------------------------------
  # ○ 降参時の SE 演奏
  #--------------------------------------------------------------------------
  def play_se_for_giveup
    Audio.se_play("Audio/SE/#{GiveUp::SE}", GiveUp::VOL, GiveUp::PITCH)
  end
end
