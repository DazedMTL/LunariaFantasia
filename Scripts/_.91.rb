=begin #=======================================================================
  
◆◇入手インフォメーション＋マップエフェクトベース RGSS3◇◆ ※starさんの移植品

◆DEICIDE ALMA
◆レーネ　
◆http://blog.goo.ne.jp/exa_deicide_alma

★変更点
●インフォの文章はヘルプの１行目の文章になります。
　(<info:任意の文字列>で指定した場合はそちらを優先)

●GET = true ならインフォを出したアイテムを入手します。
　(アイテム、武器、防具、お金が対象)

●ヘルプで使用できる制御文字に対応


◆導入箇所
▼素材のところ、mainより上

=end #=========================================================================
#==============================================================================
# ★RGSS2 
# STEMB_マップエフェクトベース v0.8
# 
# ・エフェクト表示のための配列定義、フレーム更新、ビューポート関連付け
#
#==============================================================================
# ★RGSS2 
# STR20_入手インフォメーション v1.2 09/03/17
# 
# ・マップ画面にアイテム入手・スキル修得などの際に表示するインフォです。
# ・表示内容は 任意指定の名目+アイテム名+ヘルプメッセージとなります。
# ・アイテムのメモ欄に <info:任意の文字列> と記述することで
# 　通常とは別の説明文をインフォに表示させることができます。
# [仕様]インフォが表示されている間も移動できます。
# 　　　移動させたくない場合はウェイトを入れてください。
#
#==============================================================================
class Window_Getinfo < Window_Base
  # 設定箇所
  G_ICON  = 361   # ゴールド入手インフォに使用するアイコンインデックス 
  Y_TYPE  = 1     # Y座標の位置(0 = 上基準　1 = 下基準)
  Z       = 188   # Z座標(問題が起きない限り変更しないでください)
  TIME    = 180   # インフォ表示時間(1/60sec)
  OPACITY = 32    # 透明度変化スピード
  B_COLOR = Color.new(0, 0, 0, 160)        # インフォバックの色
  INFO_SE = RPG::SE.new("Chime2", 80, 100) # インフォ表示時の効果音
  
  #STR20W  = /info\[\/(.*)\/\]/im # メモ設定ワード(VXと同じ)
  STR20W  = /<info:(.*?)>/im      # メモ設定ワード
  
  GET = true # インフォを出したアイテムを入手するかどうか(スキルは除く)
end
#
if false
# ★以下をコマンドのスクリプト等に貼り付けてテキスト表示----------------★

# 種類 / 0=ｱｲﾃﾑ 1=武器 2=防具 3=ｽｷﾙ 4=金
type = 0
# ID  / 金の場合は金額を入力
id   = 1
# 入手テキスト / 金の場合無効
text = "アイテム入手！"
#
e = $game_temp.streffect
e.push(Window_Getinfo.new(id, type, text))

# ★ここまで------------------------------------------------------------★
#
# ◇スキル修得時などにアクター名を直接打ち込むと
# 　アクターの名前が変えられるゲームなどで問題が生じます。
# 　なので、以下のようにtext部分を改造するといいかもしれません。
#
# 指定IDのアクターの名前取得
t = $game_actors[1].name 
text = t + " / スキル修得！"
#
end

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :streffect
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_stref initialize
  def initialize
    initialize_stref
    @streffect = []
  end
end

class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● エフェクトの作成
  #--------------------------------------------------------------------------
  def create_streffect
    $game_temp.streffect = []
  end
  #--------------------------------------------------------------------------
  # ● エフェクトの解放
  #--------------------------------------------------------------------------
  def dispose_streffect
    (0...$game_temp.streffect.size).each do |i|
      $game_temp.streffect[i].dispose if $game_temp.streffect[i] != nil
    end
    $game_temp.streffect = []
  end
  #--------------------------------------------------------------------------
  # ● エフェクトの更新
  #--------------------------------------------------------------------------
  def update_streffect
    (0...$game_temp.streffect.size).each do |i|
      if $game_temp.streffect[i] != nil
        $game_temp.streffect[i].viewport = @viewport1
        $game_temp.streffect[i].update
        $game_temp.streffect.delete_at(i) if $game_temp.streffect[i].disposed?
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 遠景の作成(エイリアス)
  #--------------------------------------------------------------------------
  alias create_parallax_stref create_parallax
  def create_parallax
    create_parallax_stref
    create_streffect
  end
  #--------------------------------------------------------------------------
  # ● 解放(エイリアス)
  #--------------------------------------------------------------------------
  alias dispose_stref dispose
  def dispose
    dispose_streffect
    dispose_stref
  end
  #--------------------------------------------------------------------------
  # ● 更新(エイリアス)
  #--------------------------------------------------------------------------
  alias update_stref update
  def update
    update_stref
    update_streffect
  end
end

class Window_Getinfo < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(id, type, text = "", se_on = true)
    #super(-16, 0, 544 + 32, 38 + 32)
    super(-16, 0, 640 + 32, 38 + 32)
    self.z = Z
    self.contents_opacity = 0
    self.back_opacity = 0
    self.opacity = 0
    @count = 0
    @i = $game_temp.getinfo_size.index(nil)
    @i = $game_temp.getinfo_size.size if (@i == nil)
    if Y_TYPE == 0
      self.y = -14 + (@i * 40)
    else
      #self.y = 416 - 58 - (@i * 40)
      self.y = 480 - 58 - (@i * 40)
    end
    $game_temp.getinfo_size[@i] = true 
    refresh(id, type, text)
    INFO_SE.play if se_on
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    $game_temp.getinfo_size[@i] = nil
    super
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    self.viewport = nil
    @count += 1
    unless @count >= TIME
      self.contents_opacity += OPACITY
    else
      if Y_TYPE == 0
        self.y -= 1
      else
        self.y += 1
      end
      self.contents_opacity -= OPACITY
      dispose if self.contents_opacity == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh(id, type, text = "")
    #ランダム要素を入れるためidを配列にしてその中からランダムで取り出すことも
    #可能にした　またidが配列でなければそのままの数値を返すのでどちらでもOK
    id = id_select(id)
    case type
    when 0 ; data = $data_items[id]
    when 1 ; data = $data_weapons[id]
    when 2 ; data = $data_armors[id]
    when 3 ; data = $data_skills[id]
    when 4 ; data = id
    else   ; p "typeの値がおかしいです><;"
    end
    c = B_COLOR
    #self.contents.fill_rect(0, 14, 544, 24, c)
    self.contents.fill_rect(0, 14, 640, 24, c)
    if type < 4
      draw_item_name(data, 4, 14)
      #ix = data.name.size * 20 + 48
      #draw_text_ex(204, 14, description(data))
      draw_text_ex(204, 14, description(data))
      #draw_text_ex(ix, 14, description(data))
    else
      draw_icon(G_ICON, 4, 14)
      draw_text(28, 14, 176, line_height, 
      data.to_s + Vocab.currency_unit)
      $game_party.gain_gold(id) if GET
    end
    self.contents.font.size = 14
    w = contents.text_size(text).width
    change_color(normal_color)
    contents.fill_rect(0, 0, w + 4, 14, c)
    contents.draw_text_f(4, 0, 340, 14, text)
    $game_party.gain_item(data,1) if type <= 2 && GET
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● 配列の要素をランダムに取得
  #--------------------------------------------------------------------------
  def id_select(id)
    if id.is_a?(Array)
      id1 = id[0] #候補１：配列先頭は必ず候補に入れて確率を少し高める
      id2 = id.size > 2 ? id[rand(id.size - 1)] : id[1] #候補２：配列最後のアイテムを候補から外して少しレア目にする
      id3 = id[rand(id.size)] #候補３：全てのアイテムから候補を選択
      id_x = [id1, id2, id3] #全ての候補を配列にする
      id = id_x[rand(id_x.size)] #３つの候補から１つを選択
    end
    #id = id[rand(id.size)] if id.is_a?(Array) #idが配列なら要素をランダムに選択
    return id
  end
  #--------------------------------------------------------------------------
  # ● 解説文取得
  #--------------------------------------------------------------------------
  def description(data)
    data.note =~ /#{STR20W}/ ? $1 : data.description.sub(/[\r\n]+.*/m, "")
  end
end

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :getinfo_size
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_str20 initialize
  def initialize
    initialize_str20
    @getinfo_size = []
  end
end

class Bitmap
unless public_method_defined?(:draw_text_f)
  #--------------------------------------------------------------------------
  # ● 文字縁取り描画
  #--------------------------------------------------------------------------
  def draw_text_f(x, y, width, height, str, align = 0, color = Color.new(64,32,128))
    shadow = self.font.shadow
    b_color = self.font.color.dup
    outline = self.font.outline
    self.font.outline = false
    font.shadow = false
    font.color = color
    draw_text(x + 1, y, width, height, str, align) 
    draw_text(x - 1, y, width, height, str, align) 
    draw_text(x, y + 1, width, height, str, align) 
    draw_text(x, y - 1, width, height, str, align) 
    font.color = b_color
    draw_text(x, y, width, height, str, align)
    font.shadow = shadow
    self.font.outline = outline
  end
  def draw_text_f_rect(r, str, align = 0, color = Color.new(64,32,128)) 
    draw_text_f(r.x, r.y, r.width, r.height, str, align, color) 
  end
end
end
