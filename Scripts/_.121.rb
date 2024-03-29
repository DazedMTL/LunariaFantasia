#==============================================================================
# ★ RGSS3-Extension
# LNX10_バトルスピード調整
# 　バトルテンポを様々な面から改善します。
#
# 　version   : 1.00 (12/02/27)
# 　author    : ももまる
# 　reference : http://peachround.blog.fc2.com/blog-entry-19.html
#
#==============================================================================

module LNX10
  #--------------------------------------------------------------------------
  # ● 設定
  #--------------------------------------------------------------------------
  # ウェイトの長さ(％)
  BASE_WAIT      = 75    # 規定値:75
  
  # 短時間ウェイトの長さ(フレーム)
  SHORT_WAIT     = 15    # 規定値:15
  
  # 早送りボタン(複数指定可) 
  FAST_KEY       = [:C, :A] # 規定値:[:C, :A]

  # 早送りの速さ
  FAST_SPEED     = 4.0   # 規定値:4.0
  
  # 早送り中、アニメーションとエフェクトも早送りする true = 有効 / false = 無効
  EFFECT_FAST    = true  # 規定値：true
  
  # 早送りしないエフェクト(複数指定可)
  NO_FAST_TYPE   = [:boss_collapse, :target_whiten, :command_whiten]

  # アニメーションとエフェクト表示の待ち時間省略(フレーム)
  ANIMATION_OMIT = 12    # 規定値:12
  EFFECT_OMIT    = 8     # 規定値:8
  
  # 早送り無効のウェイトを早送り可能にする true = 有効 / false = 無効
  ADS_FAST_FAST  = true  # 規定値:true
end

#==============================================================================
# ■ LNXスクリプト導入情報
#==============================================================================
$lnx_include = {} if $lnx_include == nil
$lnx_include[:lnx10] = 100 # version
p "OK:LNX10_バトルスピード調整"

#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● [追加]:公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :battle_fastforward  # 早送りしているか
  #--------------------------------------------------------------------------
  # ● [エイリアス]:オブジェクト初期化
  #--------------------------------------------------------------------------
  alias :lnx10_initialize :initialize
  def initialize
    lnx10_initialize
    @battle_fastforward = false
  end
end

#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
# 　バトラー表示用のスプライトです。
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ● [追加]:公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :ani_duration     # アニメーションの残り時間
  attr_reader :effect_duration  # エフェクトの残り時間
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:アニメーションの更新
  #--------------------------------------------------------------------------
  def update_animation
    # スーパークラスのメソッドを呼ぶ
    super
    return unless $game_temp.battle_fastforward
    return unless animation?
    # 早送り中ならさらに1フレーム経過させる
    if @ani_duration % @ani_rate > 1 && LNX10::EFFECT_FAST
      @ani_duration -= @ani_duration % @ani_rate - 1
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:エフェクトの更新
  #--------------------------------------------------------------------------
  alias :lnx10_update_effect :update_effect
  def update_effect
    # 元のメソッドを呼ぶ
    lnx10_update_effect
    return unless $game_temp.battle_fastforward
    return if LNX10::NO_FAST_TYPE.include?(@effect_type)
    # 早送り中ならさらに1フレーム経過させる
    @effect_duration -= 1 if @effect_duration > 1 && LNX10::EFFECT_FAST
  end 
  #--------------------------------------------------------------------------
  # ● [再定義]:点滅エフェクトの更新
  #--------------------------------------------------------------------------
  def update_blink
    # アニメーション表示中に opacity が変化すると都合が悪いので、
    # flash で点滅させる
    self.opacity = 255
    self.flash(nil, 1) if @effect_duration % 10 >= 5
  end
end

#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　バトル画面のスプライトをまとめたクラスです。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● [再定義]:アニメーション表示中判定
  #--------------------------------------------------------------------------
  def animation?
    # 残り時間が skip 以下の場合、再生中とみなさない
    skip = LNX10::ANIMATION_OMIT
    battler_sprites.any? {|sprite| sprite.ani_duration > skip}
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:エフェクト実行中判定
  #--------------------------------------------------------------------------
  def effect?
    # 残り時間が skip 以下の場合、再生中とみなさない
    skip = LNX10::EFFECT_OMIT 
    battler_sprites.any? {|sprite| sprite.effect_duration > skip}
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● [追加]:ウェイトの長さを修正して返す
  #--------------------------------------------------------------------------
  def base_wait(duration)
    [duration * LNX10::BASE_WAIT / 100, duration <= 0 ? 0 : 1].max
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:フレーム更新（ウェイト用）
  #--------------------------------------------------------------------------
  alias :lnx10_update_for_wait :update_for_wait
  def update_for_wait
    # 元のメソッドを呼ぶ
    lnx10_update_for_wait
    # 早送り状態の更新
    show_fast?
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:ウェイト
  #--------------------------------------------------------------------------
  def wait(duration)
    duration = base_wait(duration)
    skip = duration / LNX10::FAST_SPEED
    duration.times {|i| update_for_wait if i < skip || !show_fast? }
    $game_temp.battle_fastforward = false
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:早送り判定
  #--------------------------------------------------------------------------
  def show_fast?
    # 早送りボタンのどれか一つでも押されているか？
    fast = LNX10::FAST_KEY.collect {|key| Input.press?(key) }.include?(true)
    # Scene_Battle 以外のクラスで早送り情報を扱うために $game_temp に書き込む
    $game_temp.battle_fastforward = fast
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:ウェイト（早送り無効）
  #--------------------------------------------------------------------------
  def abs_wait(duration)
    duration = base_wait(duration)
    if LNX10::ADS_FAST_FAST
      # 早送り無効ウェイトが早送り可能なら
      skip = duration / LNX10::FAST_SPEED
      duration.times {|i| update_for_wait if i < skip || !show_fast? }
    else
      # 早送り無効ウェイト
      duration.times {|i| update_for_wait }
    end
    $game_temp.battle_fastforward = false
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:短時間ウェイト（早送り無効）
  #--------------------------------------------------------------------------
  def abs_wait_short
    #wait_for_animation # アニメーションが再生されていたら待つ
    abs_wait(LNX10::SHORT_WAIT)
  end
end
