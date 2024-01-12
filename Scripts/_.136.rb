#==============================================================================
# ■ Scene_Logo
#------------------------------------------------------------------------------
# 　ロゴ画面の処理を行うクラスです。
#==============================================================================

class Scene_Logo < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    Graphics.screen_zoom += 1 if !$game_switches[Option::ScreenZoom] && Graphics.screen_zoom == 1
    super
    Graphics.freeze
    create_background
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_background
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    logo_duration.times do
      Graphics.update
      Input.update
      break if Input.trigger?(:C) || Input.trigger?(:B)
    end
    goto_title
  end
  #--------------------------------------------------------------------------
  # ● トランジション実行
  #--------------------------------------------------------------------------
  def perform_transition
    Graphics.transition(fadein_speed)
  end
  #--------------------------------------------------------------------------
  # ○ ロゴ表示時間
  #--------------------------------------------------------------------------
  def logo_duration
    180
  end
  #--------------------------------------------------------------------------
  # ● 固定済みグラフィックのフェードアウト
  #--------------------------------------------------------------------------
  #def fadeout_frozen_graphics
    #Graphics.transition(fadeout_speed)
    #Graphics.freeze
  #end
  #--------------------------------------------------------------------------
  # ● 背景の作成
  #--------------------------------------------------------------------------
  def create_background
    @sprite = Sprite.new
    @sprite.bitmap = Cache.system("Logo")
  end
  #--------------------------------------------------------------------------
  # ● 背景の解放
  #--------------------------------------------------------------------------
  def dispose_background
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● フェードアウト速度の取得
  #--------------------------------------------------------------------------
  def fadeout_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● フェードイン速度の取得
  #--------------------------------------------------------------------------
  def fadein_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● タイトル画面へ遷移
  #--------------------------------------------------------------------------
  def goto_title
    fadeout_all
    SceneManager.goto(Scene_Title)
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
  # ● 最初のシーンクラスを取得
  #--------------------------------------------------------------------------
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_Logo
  end
end