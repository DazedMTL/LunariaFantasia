#==============================================================================
# ■ [追加]:Window_TargetHelp
#------------------------------------------------------------------------------
# 　ターゲットの名前情報やスキルやアイテムの名前を表示します。
#==============================================================================

class Window_TargetHelp < Window_Help
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :random_change  # 効果範囲ランダムの変更 ※追加
  attr_accessor :plus_random    # "+ ランダム○体"表示の数 ※追加
  #--------------------------------------------------------------------------
  # ● 選択対象の情報の描画
  #--------------------------------------------------------------------------
  def draw_target_info
    # バトラー情報の描画
    param = @text.actor? ? LNX11::HELP_ACTOR_PARAM : LNX11::HELP_ENEMY_PARAM
    # ゲージ付きステータス配列
    status = [param[:hp],param[:mp],param[:tp]&&$data_system.opt_display_tp]
    # 名前
    lv_disclose = @text.enemy? && $game_party.lv_disclose? #追加★
    #lv_text = "" #追加★
    lv_text = " Lv#{@text.level}" #if lv_disclose #追加★
    random = "" #追加★
    random = " + #{FAKEREAL::RANDOM}#{plus_random}体" if @random_change #追加★
    #　↓二行lv_text追加★
    x = contents_width / 2 - contents.text_size(@text.name + lv_text + random).width / 2
    name_width = contents.text_size(@text.name + lv_text + random).width + 4
    if weak_disclose? #弱点描画追加★
      x += weak_width(@text.most_weak.size) / 2 #弱点描画幅分ずらす
      draw_weak_icons(@text)
    end
    if !status.include?(true)
      # ゲージ付きステータスを描画しない場合
      draw_targethelp_name(@text, x, name_width, param[:hp])
      x += name_width
      state_width = contents_width - x
    else
      # ゲージ付きステータスを描画する場合
      status.delete(false)
      x -= param_width(status.size) / 2
      draw_targethelp_name(@text, x, name_width, param[:hp])
      x += name_width
      state_width = contents_width - x - param_width(status.size)
    end
    # ステートアイコン
    #↓!@random_change追加★
    if param[:state] && !@random_change # ランダム最適化時はアイコン未表示
      draw_actor_icons(@text, x, 0, state_width) 
    end
    # パラメータの描画
    x = contents_width - param_width(status.size)
    # HP
    if param[:hp]
      draw_actor_hp(@text, x, 0, gauge_width)
      x += gauge_width_spacing
      draw_life(@text) if lv_disclose #追加★
      #disclose_hp = @text.hp
      #draw_text(contents.rect, disclose_hp, 2) if lv_disclose #x, 0, 600, 24, @text.hp, 1) if lv_disclose
    end
    # MP
    if param[:mp]
      draw_actor_mp(@text, x, 0, gauge_width)
      x += gauge_width_spacing
    end
    # TP
    if param[:tp] && $data_system.opt_display_tp
      draw_actor_tp(@text, x, 0, gauge_width)
      x += gauge_width_spacing
    end
  end
  #--------------------------------------------------------------------------
  # ○ 選択対象の情報の描画　※追加
  #--------------------------------------------------------------------------
  def draw_summon_info
      summon = "召喚"
      change = ""
    if $game_party.summon_max?
      summon = " 入れ替え召喚"
      change = @text.summon_type? ? @text.name : $game_party.summon_members_top.name
      change += " → "
    end
    name = BattleManager.actor.input.item.name
    draw_text(contents.rect, change + name + summon, 1)
  end
  #--------------------------------------------------------------------------
  # ○ 名前の描画　※追加
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y, width = 112)
    random = @random_change ? " + #{FAKEREAL::RANDOM}#{plus_random}体" : ""
    #if actor.enemy? && $game_party.lv_disclose?
    text = actor.name + " Lv#{actor.level}" + random
    change_color(hp_color(actor))
    draw_text(x, y, width + 24, line_height, text)
    #else
      #change_color(hp_color(actor))
      #draw_text(x, y, width, line_height, actor.name + random)
    #end
  end
  #--------------------------------------------------------------------------
  # ○ 弱点の描画　※追加
  #--------------------------------------------------------------------------
  def draw_weak_icons(actor, x = 0, y = 0)
    if actor.enemy?
      icons = actor.most_weak
      width = weak_width(icons.size)
      text = "弱点"
      change_color(power_down_color)
      draw_text(x, y, width, line_height, text)
      x = contents.text_size(text).width
      icons.each_with_index {|n, i| draw_icon(n, x + 24 * i, y) }
      change_color(normal_color)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 残りHPの描画　※追加
  #--------------------------------------------------------------------------
  def draw_life(actor)
    text = (actor.hp).to_s
    text = text.gsub(/./) {"?"} if unknown?(actor)
    fontsize = contents.font.clone
    contents.font.size = 20
    change_color(hp_color(actor))
    draw_text(contents.rect, text, 2)
    change_color(normal_color)
    contents.font = fontsize
  end
  #--------------------------------------------------------------------------
  # ○ 敵HPのハテナ表示判定　※追加
  #--------------------------------------------------------------------------  
  def unknown?(actor)
    actor.boss? || $game_switches[FAKEREAL::UNKNOWN_SWITCH]
  end
  #--------------------------------------------------------------------------
  # ○ 弱点エリアの幅　※追加
  #--------------------------------------------------------------------------  
  def weak_width(size)
    contents.text_size("弱点").width + 24 * size + 0
  end
  #--------------------------------------------------------------------------
  # ○ 弱点描画の有無　※追加
  #--------------------------------------------------------------------------  
  def weak_disclose?
    @text.enemy? && $game_party.weak_disclose? && @text.most_weak.size > 0
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    if @text == :party
      draw_text(contents.rect, "味方全体", 1)
    elsif @text == :troop
      draw_text(contents.rect, "敵全体", 1)
    elsif @text == :troop_random
      case LNX11::RANDOMSCOPE_DISPLAY
      when 0 ; draw_text(contents.rect, "敵全体 ランダム", 1)
      when 1 ; draw_text(contents.rect, "ランダム #{random_number}回", 1)
      # 上記を一部変更★
      #when 1 ; draw_text(contents.rect, random_target(random_number), 1)#"敵#{random_number}#{random_target} ランダム", 1)
      end
    elsif @text.is_a?(Game_Battler)
      if SummonSystem.summon_skill? #追加★
        # 召喚の種類を描画
        draw_summon_info #追加★
      else
      # 選択対象の情報を描画
        draw_target_info
      end
    elsif @text.is_a?(RPG::UsableItem)
      # アイテムかスキルならアイテム名を描画
      draw_item_name_help(@text)
    else
      # 通常のテキスト
      super
    end
  end
  #--------------------------------------------------------------------------
  # ○ 　※追加
  #--------------------------------------------------------------------------  
  def plus_random 
    @plus_random.to_s.tr('0-9','０-９')
  end
  #--------------------------------------------------------------------------
  # ○ ターゲット内容により"体"か"回"か　※追加
  #--------------------------------------------------------------------------
=begin
  def random_target(num)
    return "敵#{num}体 ランダム" if @random_change
    return "ランダム #{num}回"
    #return "体" if @random_change
    #return "回"
  end
=end
end

#==============================================================================
# ■ LNX11_Window_TargetHelp
#------------------------------------------------------------------------------
# 　バトル画面で、ターゲット選択中にヘルプウィンドウを表示するための
# ウィンドウ用モジュールです。
# Window_BattleActor, Window_BattleEnemy でインクルードされます。
#==============================================================================

module LNX11_Window_TargetHelp
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットチェック
  #--------------------------------------------------------------------------
  def set_target(actor_selection_item)
    @cursor_fix = @cursor_all = @cursor_random = false
    item = actor_selection_item
    @random_change = item.random_change #追加★
    @plus_random = item.number_of_targets - 1
    if actor_selection_item && !item.lnx11a_need_selection?
      # カーソルを固定
      @cursor_fix = true
      # 全体
      @cursor_all = item.for_all? 
      # ランダム
      if item.for_random?
        @cursor_all = true
        @cursor_random = true
        @random_number = item.number_of_targets
      end
    end
    # 戦闘不能の味方が対象か？
    @dead_friend = item.for_dead_friend?
  end
end

#==============================================================================
# ■ Window_BattleEnemy
#------------------------------------------------------------------------------
# 　バトル画面で、行動対象の敵キャラを選択するウィンドウです。
# 横並びの不可視のウィンドウとして扱います。
#==============================================================================

class Window_BattleEnemy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ヘルプテキスト更新 ※エイリアス
  #--------------------------------------------------------------------------
  alias random_change_update_help update_help
  def update_help
    @help_window.random_change = @random_change
    @help_window.plus_random = @plus_random
    random_change_update_help
  end
end

#==============================================================================
# ■ Window_BattleActor
#------------------------------------------------------------------------------
# 　バトル画面で、行動対象のアクターを選択するウィンドウです。
# XPスタイルバトルではバトルステータスを非表示にしないため、
# 選択機能だけを持つ不可視のウィンドウとして扱います。
#==============================================================================

class Window_BattleActor < Window_BattleStatus
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ヘルプテキスト更新 ※エイリアス
  #--------------------------------------------------------------------------
  alias random_change_update_help update_help
  def update_help
    @help_window.random_change = @random_change
    @help_window.plus_random = @plus_random
    random_change_update_help
  end
end


#==============================================================================
# ■ [追加]:BattleGraphicManager
#==============================================================================

module LNX11::BattleGraphicManager
  #--------------------------------------------------------------------------
  # ● コラプスエフェクト条件
  #--------------------------------------------------------------------------
  def self.need_collapse?(battler)
    if battler.alive?
      return false
    end
    if cbg_find(battler, :dead)
      return false
    end
    # ↓後半部分追加　これによりパーティーメンバーが入れ替わっても戦闘不能アクターのグラフィックが表示されることはない
    if battler.sprite_effect_type != nil && battler.sprite_effect_type != :appear
      return false
    end
    return true
  end
end


#==============================================================================
# ■ [追加]:Popup_Data
#------------------------------------------------------------------------------
# 　戦闘中のポップアップをまとめて扱うクラス。ポップアップスプライトの
# initialize 時に自身を参照させて、ポップアップ内容を定義する際にも使います。
#==============================================================================

class Popup_Data
  #--------------------------------------------------------------------------
  # ● TP 吸収回復
  #--------------------------------------------------------------------------
  def popup_tp_drain(target, tp_drain)
    return if tp_drain == 0
    refresh
    @popup = tp_drain
    @battler = target
    @deco = LNX11::DECORATION_NUMBER[:tp_plus]
    @type = LNX11::POPUP_TYPE[:mp_drainrecv]
    @color = :tp_damage
    # ポップアップ作成
    makeup
  end
end

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　スプライトや行動に関するメソッドを追加したバトラーのクラスです。このクラス
# は Game_Actor クラスと Game_Enemy クラスのスーパークラスとして使用されます。
#==============================================================================
=begin
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ダメージの処理
  # 　吸収による回復のポップアップを生成します。
  #--------------------------------------------------------------------------
  alias tp_popup_execute_damage execute_damage
  def execute_damage(user)
    tp_popup_execute_damage(user)
    return unless $game_party.in_battle
    popup_data.popup_tp_drain(user, @result.tp_drain)
  end
end
=end