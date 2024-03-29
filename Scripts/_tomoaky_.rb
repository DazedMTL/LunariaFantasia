#==============================================================================
# ★ RGSS3_視界制限 Ver1.2
#==============================================================================
=begin

作者：tomoaky
webサイト：ひきも記 (http://hikimoki.sakura.ne.jp/)

設定した番号のマップだけ視界を制限します。

アクター、職業、武器（防具）、ステートなどのメモ欄にタグを書き込むことで
視界制限のサイズを補正することができます。
  例）<視界補正 32>
視界が 32 ドット広がります。
視界補正値の計算をおこなうのは戦闘メンバーのみとなります。

ゲーム変数（初期設定では９番）を使って視界のサイズを補正できます。

実際の視界制限サイズは上記の設定値をすべて加算したものになります。
ただし、マップに視界制限値が設定されていない場合はすべて無効です。

プレイヤーの画面上の座標が常に変わるような状況（１画面分の小さなマップなど）、
視界補正値がリアルタイムに変化する状況などでは頻繁にスプライトの再描画を
実行するため処理が重くなります

動作に必要な画像
  Graphics/System/sight_shadow.png
  
使用するゲーム変数（初期設定）
  0009

2013.01.22  Ver1.2
  ・毎フレーム再描画をおこなっていた処理を改善
  ・環境によってエラー落ちの原因となる部分を修正
  
2012.03.07  Ver1.11
　・メニューから復帰したときに視界制限が途切れる不具合を修正
  
2012.02.05  Ver1.1
  ・タイマーが隠れてしまわないようにＺ座標を調整
  ・ゲーム変数を使って視界制限サイズを補正する機能を追加
  
2012.01.20  Ver1.0
  公開

=end

#==============================================================================
# □ 設定項目
#==============================================================================
module TMBLSIGHT
  # 何番のマップをどれだけ視界制限するか
  # 例）SIGHT[3] = 128  # ３番のマップの視界を128ドット四方に制限する
  SIGHT = {}
  SIGHT[370] = [256,128,false] #改造 配列０がドット四方、配列１が全体の暗さ(不透明度)、配列２が視界補正の効果の有無
  SIGHT[19] = [256,128,false] #セネシオ酒場・上も同じダンスイベントマップ
  SIGHT[433] = [256,128,false] #セネシオ酒場・上も同じダンスイベントマップ
  
  SIGHT[306] = [256,255,true] #地下水路
  SIGHT[307] = [256,255,true] #地下水路
  SIGHT[308] = [256,255,true] #地下水路
  SIGHT[309] = [256,255,true] #地下水路
  SIGHT[310] = [256,255,true] #地下水路
  SIGHT[311] = [256,255,true] #地下水路
  SIGHT[312] = [256,255,true] #地下水路

  SIGHT[231] = [256,255,true] #九条迷宮

  SIGHT[374] = [256,255,true] #ハイドラ水路
  SIGHT[375] = [256,255,true] #ハイドラ水路
  SIGHT[391] = [256,255,true] #ハイドラ水路
  SIGHT[392] = [256,255,true] #ハイドラ水路
  SIGHT[393] = [256,255,true] #ハイドラ水路
  SIGHT[394] = [256,255,true] #ハイドラ水路
  SIGHT[395] = [256,255,true] #ハイドラ水路
  SIGHT[396] = [256,255,true] #ハイドラ水路
  SIGHT[397] = [256,255,true] #ハイドラ水路
  
  SIGHT[70] = [128,255,true] #暗闇の廃坑
  SIGHT[81] = [128,255,true] #暗闇の廃坑
  
  SIGHT[202] = [256,255,true] #レオンタイス砂漠
  
  SIGHT[419] = [128,255,true] #淫堕の洗脳砦
  
  MAX_SIGHT = 896 # 追加
  
  VN_SIGHT = 36    # 視界のサイズ補正に利用するゲーム変数番号
end

#==============================================================================
# □ RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ○ 視界制限の補正値
  #--------------------------------------------------------------------------
  def sight_power
    unless @sight_power
      @sight_power = /<視界補正\s*(\-*\d+)\s*>/ =~ @note ? $1.to_i : 0
    end
    @sight_power
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor
  #--------------------------------------------------------------------------
  # ○ 視界制限の補正値
  #--------------------------------------------------------------------------
  def sight_power
    feature_objects.inject(0) {|result, object| result + object.sight_power }
  end
end

#==============================================================================
# □ Sprite_SightShadow
#==============================================================================
class Sprite_SightShadow < Sprite
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    self.z = 99
    self.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @bitmap_shadow = Bitmap.new("Graphics/System/sight_shadow")
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    @bitmap_shadow.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    if TMBLSIGHT::SIGHT[$game_map.map_id]
      self.visible = true
      #w = TMBLSIGHT::SIGHT[$game_map.map_id]      # マップに設定された補正値
      # 改造
      w = TMBLSIGHT::SIGHT[$game_map.map_id][0]    # マップに設定された補正値
      # 改造
      if TMBLSIGHT::SIGHT[$game_map.map_id][2]
        w += $game_variables[TMBLSIGHT::VN_SIGHT]   # ゲーム変数による補正値
        $game_party.battle_members.each do |actor|
          w = [w + actor.sight_power, 48].max       # 戦闘メンバーの補正値
        end
        $game_party.summon_members_set_actor.each do |actor|
          w = [w + actor.sight_power, 48].max       # サーヴァントの補正値
        end
        $game_party.states.each do |st|
          w = [w + st.sight_power, 48].max       # パーティステートの補正値
        end
      end
      # 改造
      w = [w, TMBLSIGHT::MAX_SIGHT].min
      x = $game_player.screen_x - w / 2
      y = $game_player.screen_y - w / 2 - 16
      if w != @last_w || x != @last_x || y != @last_y
        @last_w = w
        @last_x = x
        @last_y = y
        self.bitmap.clear
        rect = Rect.new(x, y, w, w)
        # 改造
        op = TMBLSIGHT::SIGHT[$game_map.map_id][1] # 視界制限の暗さ(不透明度)
        op = op ? op : 255
        self.bitmap.stretch_blt(rect, @bitmap_shadow, @bitmap_shadow.rect, op)
        #color = Color.new(0, 0, 0)
        color = Color.new(0, 0, 0, op)
        self.bitmap.fill_rect(0, 0, Graphics.width, y, color)
        self.bitmap.fill_rect(0, y + w, Graphics.width, Graphics.height - y - w, color)
        self.bitmap.fill_rect(0, y, x, w, color)
        self.bitmap.fill_rect(x + w, y, Graphics.width - x - w, w, color)
      end
    else
      self.visible = false
    end
  end
end

#==============================================================================
# ■ Spriteset_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tmblsight_spriteset_map_initialize initialize
  def initialize
    tmblsight_spriteset_map_initialize
    create_sight_shadow
  end
  #--------------------------------------------------------------------------
  # ○ 視界制限スプライトの作成
  #--------------------------------------------------------------------------
  def create_sight_shadow
    @sight_shadow_sprite = Sprite_SightShadow.new(@viewport2)
    update_sight_shadow
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias tmblsight_spriteset_map_dispose dispose
  def dispose
    dispose_sight_shadow
    tmblsight_spriteset_map_dispose
  end
  #--------------------------------------------------------------------------
  # ○ 視界制限スプライトの解放
  #--------------------------------------------------------------------------
  def dispose_sight_shadow
    @sight_shadow_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias tmblsight_spriteset_map_update update
  def update
    update_sight_shadow
    tmblsight_spriteset_map_update
  end
  #--------------------------------------------------------------------------
  # ○ 視界制限スプライトの更新
  #--------------------------------------------------------------------------
  def update_sight_shadow
    @sight_shadow_sprite.update if @sight_shadow_sprite
  end
end

