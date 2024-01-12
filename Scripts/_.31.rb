#==============================================================================
# ■ RGSS3 戦闘コマンド入力中 立ち絵表示 ver 1.01
#------------------------------------------------------------------------------
# 　配布元:
#     白の魔 http://izumiwhite.web.fc2.com/
#
# 　利用規約:
#     RPGツクールVX Aceの正規の登録者のみご利用になれます。
#     利用報告・著作権表示とかは必要ありません。
#     改造もご自由にどうぞ。
#     何か問題が発生しても責任は持ちません。
#==============================================================================

#--------------------------------------------------------------------------
# ★ 初期設定。
#    立ち絵の透明度設定と表示位置をズラします。
#    このままでも大抵は問題無いハズ…。
#    ここをいじっても駄目な場合は画像グラフィックそのものを加工しましょう。
#--------------------------------------------------------------------------
module WD_battlepicture_ini
 Picture_opacity = 200   #立ち絵の不透明度です。0(透明)～255(不透明)で指定
 Picture_x = 0           #立ち絵のx座標の位置調整
 Picture_y = 0           #立ち絵のy座標の位置調整

 Hidepicture1 = true     #スキル、アイテム選択時に
                         #立ち絵を消す場合はtrue
 Hidepicture2 = true     #敵ターゲット選択時に
                         #立ち絵を消す場合はtrue
 Hidepicture3 = true     #味方ターゲット選択時に
                         #立ち絵を消す場合はtrue

end
                       
#--------------------------------------------------------------------------
# ★ 初期設定おわり
#--------------------------------------------------------------------------


class Window_BattlePicture < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    #super(-16, -16, 544+32, 416+32)
    super(-16, -16, 640+32, 480+32)
  end
  #--------------------------------------------------------------------------
  # ● 立ち絵のセット
  #--------------------------------------------------------------------------
  def set(face_name)
    self.contents.clear
    bitmap1 = Cache.picture(face_name)
    rect1 = Rect.new(0, 0, bitmap1.width, bitmap1.height)
    x = 416-bitmap1.width/2 + WD_battlepicture_ini::Picture_x
    y = 432-bitmap1.height + WD_battlepicture_ini::Picture_y
    self.contents.blt(x, y, bitmap1, rect1, WD_battlepicture_ini::Picture_opacity)
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 情報表示ビューポートの作成
  #--------------------------------------------------------------------------
  alias wd_orig_create_info_viewport_009 create_info_viewport
  def create_info_viewport
    @battle_picture_window = Window_BattlePicture.new
    @battle_picture_window.hide
    @battle_picture_window.opacity = 0
    wd_orig_create_info_viewport_009
  end
  #--------------------------------------------------------------------------
  # ● 次のコマンド入力へ
  #--------------------------------------------------------------------------
  alias wd_orig_next_command_009 next_command
  def next_command
    @battle_picture_window.hide
    wd_orig_next_command_009
  end
  #--------------------------------------------------------------------------
  # ● 前のコマンド入力へ
  #--------------------------------------------------------------------------
  alias wd_orig_prior_command_009 prior_command
  def prior_command
    @battle_picture_window.hide
    wd_orig_prior_command_009
  end
  #--------------------------------------------------------------------------
  # ● アクターコマンド選択の開始
  #--------------------------------------------------------------------------
  alias wd_orig_start_actor_command_selection_009 start_actor_command_selection
  def start_actor_command_selection
    wd_orig_start_actor_command_selection_009
    @battle_picture_window.show
    #@battle_picture_window.set(BattleManager.actor.face_name)
    @battle_picture_window.set(BattleManager.actor)
  end
  #--------------------------------------------------------------------------
  # ● スキル［決定］
  #--------------------------------------------------------------------------
  alias wd_orig_on_skill_ok_009 on_skill_ok
  def on_skill_ok
    @skill = @skill_window.item
    if !@skill.need_selection?
    elsif @skill.for_opponent?
      @battle_picture_window.show if WD_battlepicture_ini::Hidepicture2 == false
    else
      @battle_picture_window.show if WD_battlepicture_ini::Hidepicture3 == false
    end
    wd_orig_on_skill_ok_009
  end  
  #--------------------------------------------------------------------------
  # ● コマンド［スキル］
  #--------------------------------------------------------------------------
  alias wd_orig_command_skill_009 command_skill
  def command_skill
    @battle_picture_window.hide if WD_battlepicture_ini::Hidepicture1
    wd_orig_command_skill_009
  end
  #--------------------------------------------------------------------------
  # ● コマンド［アイテム］
  #--------------------------------------------------------------------------
  alias wd_orig_command_item_009 command_item
  def command_item
    @battle_picture_window.hide if WD_battlepicture_ini::Hidepicture1
    wd_orig_command_item_009
  end
  #--------------------------------------------------------------------------
  # ● スキル［キャンセル］
  #--------------------------------------------------------------------------
  alias wd_orig_on_skill_cancel_009 on_skill_cancel
  def on_skill_cancel
    @battle_picture_window.show
    wd_orig_on_skill_cancel_009
  end
  #--------------------------------------------------------------------------
  # ● アイテム［キャンセル］
  #--------------------------------------------------------------------------
  alias wd_orig_on_item_cancel_009 on_item_cancel
  def on_item_cancel
    @battle_picture_window.show
    wd_orig_on_item_cancel_009
  end
  #--------------------------------------------------------------------------
  # ● アクター選択の開始
  #--------------------------------------------------------------------------
  alias wd_orig_select_actor_selection_009 select_actor_selection
  def select_actor_selection
    if WD_battlepicture_ini::Hidepicture3
      @battle_picture_window.hide
    else
      @battle_picture_window.show
    end
    wd_orig_select_actor_selection_009
  end
  #--------------------------------------------------------------------------
  # ● アクター［キャンセル］
  #--------------------------------------------------------------------------
  alias wd_orig_on_actor_cancel_009 on_actor_cancel
  def on_actor_cancel
    @actor_window.hide
    case @actor_command_window.current_symbol
    when :attack
      @battle_picture_window.show
    when :skill
      if WD_battlepicture_ini::Hidepicture1
        @battle_picture_window.hide
      else
        @battle_picture_window.show
      end
    when :item
      if WD_battlepicture_ini::Hidepicture1
        @battle_picture_window.hide
      else
        @battle_picture_window.show
      end
    end
    wd_orig_on_actor_cancel_009
  end
  #--------------------------------------------------------------------------
  # ● 敵キャラ選択の開始
  #--------------------------------------------------------------------------
  alias wd_orig_select_enemy_selection_cancel_009 select_enemy_selection
  def select_enemy_selection
    if WD_battlepicture_ini::Hidepicture2
      @battle_picture_window.hide
    else
      @battle_picture_window.show
    end
    wd_orig_select_enemy_selection_cancel_009
  end
  #--------------------------------------------------------------------------
  # ● 敵キャラ［キャンセル］
  #--------------------------------------------------------------------------
  alias wd_orig_on_enemy_cancel_009 on_enemy_cancel
  def on_enemy_cancel
    case @actor_command_window.current_symbol
    when :attack
      @battle_picture_window.show
    when :skill
      if WD_battlepicture_ini::Hidepicture1
        @battle_picture_window.hide
      else
        @battle_picture_window.show
      end
    when :item
      if WD_battlepicture_ini::Hidepicture1
        @battle_picture_window.hide
      else
        @battle_picture_window.show
      end
    end
    wd_orig_on_enemy_cancel_009
  end
end