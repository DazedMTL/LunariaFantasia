#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　マップを扱うクラスです。スクロールや通行可能判定などの機能を持っています。
# このクラスのインスタンスは $game_map で参照されます。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :default_weather               # マップ画面の天気
  attr_reader   :default_weather_power         # マップ画面の天気の強さ
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias weather_map_setup setup
  def setup(map_id)
    weather_map_setup(map_id)
    default_weather_set
  end
  #--------------------------------------------------------------------------
  # ○ マップのデフォルト天候のセットアップ
  #    ※普段からずっと暗い街等を作る際の対策 & 時間システム
  # a = :rain, b = :storm, c = :snow, d = :blizzard, e = :sand　※power = 0～9
  #--------------------------------------------------------------------------
  def default_weather_set
    if note =~ /<天気:(\w):(\d)>/
      case $1
      when "a"
        @default_weather = :rain
      when "b"
        @default_weather = :storm
      when "c"
        @default_weather = :snow
      when "d"
        @default_weather = :blizzard
      when "e"
        @default_weather = :sand
      end
      @default_weather_power = $2.to_i
    else
      @default_weather = :none
      @default_weather_power = 0
    end
    @screen.change_weather(@default_weather, @default_weather_power, 0)
  end
end

#==============================================================================
# ■ Spriteset_Weather
#------------------------------------------------------------------------------
# 　天候エフェクト（雨、嵐、雪）のクラスです。このクラスは Spriteset_Map クラ
# スの内部で使用されます。
#==============================================================================

class Spriteset_Weather
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias blizzard_initialize initialize
  def initialize(viewport = nil)
    blizzard_initialize(viewport)
    create_blizzard_bitmap
    create_sand_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias blizzard_dispose dispose
  def dispose
    blizzard_dispose
    @blizzard_bitmap.dispose
    @sand_bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ○ 天候［吹雪］のビットマップを作成
  #--------------------------------------------------------------------------
  def create_blizzard_bitmap
    @blizzard_bitmap = Bitmap.new(105, 105)
    7.times {|i| 
    @blizzard_bitmap.fill_rect(0+i*15, i*15, 6, 4, particle_color2)
    @blizzard_bitmap.fill_rect(1+i*15, i*15, 4, 6, particle_color2)
    @blizzard_bitmap.fill_rect(1+i*15, i*15+2, 4, 2, particle_color1)
    @blizzard_bitmap.fill_rect(2+i*15, i*15+1, 2, 4, particle_color1)
      }
  end
  #--------------------------------------------------------------------------
  # ○ 天候［砂塵］のビットマップを作成
  #--------------------------------------------------------------------------
  def create_sand_bitmap
    @sand_bitmap = Bitmap.new(100, 100)
    5.times {|i| 
    @sand_bitmap.fill_rect(0+i*21, i*21, 2, 2, particle_color3)
    @sand_bitmap.fill_rect(1+i*21, i*21, 2, 2, particle_color3)
    @sand_bitmap.fill_rect(1+i*21, i*21+1, 3, 2, particle_color1)
    @sand_bitmap.fill_rect(0+i*21, i*21+1, 2, 3, particle_color1)
      }
  end
  #--------------------------------------------------------------------------
  # ● 暗さの取得
  #--------------------------------------------------------------------------
  alias default_dimness dimness
  def dimness
    if (@type == :snow) || (@type == :blizzard)
      (@power * -1).to_i
    elsif @type == :sand
      (@power * 2).to_i
    else
      default_dimness
    end
  end
  #--------------------------------------------------------------------------
  # ● スプライトの更新
  #--------------------------------------------------------------------------
  def update_sprite(sprite)
    sprite.ox = @ox
    sprite.oy = @oy
    case @type
    when :rain
      update_sprite_rain(sprite)
    when :storm
      update_sprite_storm(sprite)
    when :snow
      update_sprite_snow(sprite)
    when :blizzard
      update_sprite_blizzard(sprite)
    when :sand
      update_sprite_sand(sprite)
    end
    create_new_particle(sprite) if sprite.opacity < 64
  end
  #--------------------------------------------------------------------------
  # 〇 粒子の色 3
  #--------------------------------------------------------------------------
  def particle_color3
    Color.new(200, 200, 0, 200)
  end
  #--------------------------------------------------------------------------
  # ○ スプライトの更新［吹雪］
  #--------------------------------------------------------------------------
  def update_sprite_blizzard(sprite)
    sprite.bitmap = @blizzard_bitmap
    sprite.x -= 9
    sprite.y += 5
    sprite.opacity -= 12
  end
  #--------------------------------------------------------------------------
  # ○ スプライトの更新［砂塵］
  #--------------------------------------------------------------------------
  def update_sprite_sand(sprite)
    sprite.bitmap = @sand_bitmap
    sprite.x -= 7
    sprite.y -= rand(3)
    sprite.opacity -= rand(12) + 1
  end
end