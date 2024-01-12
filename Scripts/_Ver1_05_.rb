#==============================================================================
# ■ RGSS3 特殊エラー検出 Ver1.05 by 星潟
#------------------------------------------------------------------------------
# 解放済みビューポート内のスプライトやウィンドウ等を解放しようとした際や
# 解放せずに他シーンに移った際に生じると思われる
# RGSS Playerの動作停止エラーの原因となっている部分を検出します。
# 
# ゲーム内で画像が作られたり、シーンが移り変わったりする際に
# 異常があるとコンソール画面に出力されます。
# 
# 必ずしも原因になる物が検出されるとは限りませんのでご了承ください。
# 例.デフォルト状態でもセーブ/ロード時の画面切り替わりで検出しますが
#    この処理は他要因が絡まない限り、直ちに問題のある処理ではありません。
#==============================================================================
=begin
module SPR_E_C
  
  #問題のある処理の実行までの経緯を表示するかどうかを設定します。
  #(true 表示する/false 表示しない)
  
  DETAIL = true
  
  #--------------------------------------------------------------------------
  # 初期化時処理
  #--------------------------------------------------------------------------
  def self.check_add(object,ct)
    @check[object.object_id] = [object.class.to_s,SceneManager.scene.class.to_s,ct[1].to_s.scan(/{(\S+)}/)[0][0].to_s]
  end
  #--------------------------------------------------------------------------
  # 解放時処理
  #--------------------------------------------------------------------------
  def self.check_dlt(object)
    @check.delete(object.object_id)
  end
  #--------------------------------------------------------------------------
  # コンソールへの出力（未解放）
  #--------------------------------------------------------------------------
  def self.console_d
    return if @check.empty?
    p "エラー要因を検出しました"
    @check.each_value {|v| 
    p v[1] + "内において"
    p v[2] + "番目のセクション - " + $RGSS_SCRIPTS[v[2].to_i][1].to_s + "で作成された"
    p v[0] + "が解放されずに残っています！"}
  end
  #--------------------------------------------------------------------------
  # コンソールへの出力（ビューポート）
  #--------------------------------------------------------------------------
  def self.console_v(object,cd,order)
    text = []
    text.push(cd[1].to_s.scan(/{(\S+)}/)[0][0].to_s)
    text.push(cd[1].to_s.scan(/:(\S+):/)[0][0].to_s)
    text.push(object.to_s.scan(/#<(\S+):/)[0][0].to_s)
    p "エラー要因を検出しました"
    p text[0] + "番目のセクション - " + $RGSS_SCRIPTS[text[0].to_i][1].to_s + "の"
    p text[1] + "行目に呼び出された#{order}命令の対象である"
    p text[2] + "のビューポートが既に解放されています"
    if SPR_E_C::DETAIL
      p "詳細な処理順"
      cd.reverse!
      cd.each {|t| p t}
    end
  end
  #--------------------------------------------------------------------------
  # リセット
  #--------------------------------------------------------------------------
  def self.check_reset
    @check = {}
  end
  check_reset
end
class << SceneManager
  #--------------------------------------------------------------------------
  # 実行
  #--------------------------------------------------------------------------
  alias :run_spr_e_c :run
  def run
    SPR_E_C.check_reset
    run_spr_e_c
  end
end
class Scene_Base
  #--------------------------------------------------------------------------
  # メイン
  #--------------------------------------------------------------------------
  alias main_spr_ec main
  def main
    SPR_E_C.console_d
    main_spr_ec
  end
end
class Sprite
  #--------------------------------------------------------------------------
  # スプライトの生成
  #--------------------------------------------------------------------------
  alias initialize_check initialize unless $!
  def initialize(viewport = nil)
    SPR_E_C.check_add(self,caller)
    if viewport != nil
      begin
        #ビューポートの可視状態を参照
        viewport.visible
        #エラーになった場合は既にそのビューポートは解放されているので
        #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"スプライト生成")
      end
    end
    initialize_check(viewport)
  end
  #--------------------------------------------------------------------------
  # ビューポートの指定
  #--------------------------------------------------------------------------
  alias viewport_check viewport= unless $!
  def viewport=(viewport)
    if viewport != nil
      begin
        #ビューポートの可視状態を参照
        viewport.visible
        #エラーになった場合は既にそのビューポートは解放されているので
        #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"ビューポート指定")
      end
    end
    viewport_check(viewport)
  end
  #--------------------------------------------------------------------------
  # スプライトの解放
  #--------------------------------------------------------------------------
  alias dispose_check dispose unless $!
  def dispose
    SPR_E_C.check_dlt(self)
    #ビューポートが設定されているスプライトでなければ飛ばす
    if !self.disposed? && self.viewport != nil
      begin
      #ビューポートの可視状態を参照
        self.viewport.visible
      #エラーになった場合は既にそのビューポートは解放されているので
      #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"スプライト解放")
      end
    end
    dispose_check
  end
end
class Tilemap
  #--------------------------------------------------------------------------
  # タイルマップの生成
  #--------------------------------------------------------------------------
  alias initialize_check initialize unless $!
  def initialize(viewport = nil)
    SPR_E_C.check_add(self,caller)
    if viewport != nil
      begin
        #ビューポートの可視状態を参照
        viewport.visible
        #エラーになった場合は既にそのビューポートは解放されているので
        #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"タイルマップ生成")
      end
    end
    initialize_check(viewport)
  end
  #--------------------------------------------------------------------------
  # ビューポートの指定
  #--------------------------------------------------------------------------
  alias viewport_check viewport= unless $!
  def viewport=(viewport)
    if viewport != nil
      begin
        #ビューポートの可視状態を参照
        viewport.visible
        #エラーになった場合は既にそのビューポートは解放されているので
        #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"ビューポート指定")
      end
    end
    viewport_check(viewport)
  end
  #--------------------------------------------------------------------------
  # タイルマップの解放
  #--------------------------------------------------------------------------
  alias dispose_check dispose unless $!
  def dispose
    SPR_E_C.check_dlt(self)
    #ビューポートが設定されているタイルマップでなければ飛ばす
    if !self.disposed? && self.viewport != nil
      begin
      #ビューポートの可視状態を参照
        self.viewport.visible
      #エラーになった場合は既にそのビューポートは解放されているので
      #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"タイルマップ解放")
      end
    end
    dispose_check
  end
end
class Plane
  #--------------------------------------------------------------------------
  # プレーンの生成
  #--------------------------------------------------------------------------
  alias initialize_check initialize unless $!
  def initialize(viewport = nil)
    SPR_E_C.check_add(self,caller)
    if viewport != nil
      begin
        #ビューポートの可視状態を参照
        viewport.visible
        #エラーになった場合は既にそのビューポートは解放されているので
        #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"プレーン生成")
      end
    end
    initialize_check(viewport)
  end
  #--------------------------------------------------------------------------
  # ビューポートの指定
  #--------------------------------------------------------------------------
  alias viewport_check viewport= unless $!
  def viewport=(viewport)
    if viewport != nil
      begin
        #ビューポートの可視状態を参照
        viewport.visible
        #エラーになった場合は既にそのビューポートは解放されているので
        #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"ビューポート指定")
      end
    end
    viewport_check(viewport)
  end
  #--------------------------------------------------------------------------
  # プレーンの解放
  #--------------------------------------------------------------------------
  alias dispose_check dispose unless $!
  def dispose
    SPR_E_C.check_dlt(self)
    #ビューポートが設定されている天候でなければ飛ばす
    if !self.disposed? && self.viewport != nil
      begin
      #ビューポートの可視状態を参照
        self.viewport.visible
      #エラーになった場合は既にそのビューポートは解放されているので
      #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"プレーン解放")
      end
    end
    dispose_check
  end
end
class Window_Base
  #--------------------------------------------------------------------------
  # ビューポートの指定
  #--------------------------------------------------------------------------
  alias viewport_check viewport= unless $!
  def viewport=(viewport)
    SPR_E_C.check_add(self,caller)
    if viewport != nil
      begin
        #ビューポートの可視状態を参照
        viewport.visible
        #エラーになった場合は既にそのビューポートは解放されているので
        #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"ビューポート指定")
      end
    end
    viewport_check(viewport)
  end
  #--------------------------------------------------------------------------
  # ウィンドウの解放
  #--------------------------------------------------------------------------
  alias dispose_check dispose unless $!
  def dispose
    SPR_E_C.check_dlt(self)
    #ビューポートが設定されているウィンドウでなければ飛ばす
    if !self.disposed? && self.viewport != nil
      begin
      #ビューポートの可視状態を参照
        self.viewport.visible
      #エラーになった場合は既にそのビューポートは解放されているので
      #出力処理を実行する
      rescue RGSSError
        SPR_E_C.console_v(self,caller,"ウィンドウ解放")
      end
    end
    dispose_check
  end
end
=end