#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　マップを扱うクラスです。スクロールや通行可能判定などの機能を持っています。
# このクラスのインスタンスは $game_map で参照されます。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ● フィールドタイプか否か
  #--------------------------------------------------------------------------
  alias japan_overworld? overworld?
  def overworld?
    japan_overworld? || overworld_jp? || overworld_demon?
  end
  #--------------------------------------------------------------------------
  # 〇 和風フィールドタイプか否か
  #--------------------------------------------------------------------------
  def overworld_jp?
    tileset.mode == 2 && note.include?("<フィールド>")
  end
  #--------------------------------------------------------------------------
  # 〇 浮遊大陸フィールドタイプか否か
  #--------------------------------------------------------------------------
  def overworld_demon?
    tileset.mode == 0 && note.include?("<浮遊フィールド>")
  end
end

#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　バトル画面のスプライトをまとめたクラスです。このクラスは Scene_Battle クラ
# スの内部で使用されます。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 地形に対応する戦闘背景（壁）ファイル名の取得　※再定義
  #--------------------------------------------------------------------------
  def terrain_battleback2_name(type)
    case type
    when 20,21        # 森
      "Forest1"
    when 22,30,38     # 低い山
      "Cliff"
    when 24,25,26,27  # 荒れ地、土肌
      "Wasteland"
    when 32,33        # 砂漠
      "Desert"
    when 34,35        # 岩地
      "Lava"
    when 40,41        # 雪原
      "Snowfield"
    when 42           # 雲
      "Clouds"
    when 46           # 岩山 ※追加
      "RockCave"
    when 4,5          # 毒の沼
      "PoisonSwamp"
    end
  end
end
  
#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　バトル画面のスプライトをまとめたクラスです。このクラスは Scene_Battle クラ
# スの内部で使用されます。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 地形に対応する戦闘背景（床）ファイル名の取得
  #--------------------------------------------------------------------------
  alias terrain_battleback1_name_japan terrain_battleback1_name
  def terrain_battleback1_name(type)
    if $game_map.overworld_jp?
      case type
      when 19,20,35,36,38        # 濃い草
        "Meadow"
      when 32,33        # 濃い枯れ草
        "Meadow2"
      when 22        # 砂地
        "Sand"
      when 24,25,28        # 荒れ地
        "Wasteland"
      when 30        # 土肌
        "DirtField"
      when 40,41,43,44,46        # 雪原
        "Snowfield"
      end
    elsif $game_map.overworld_demon?
      case type
      when 16        # 草原
        "Grassland"
      when 20,21        # 森
        "GrassMaze"
      when 24,25        # 荒れ地
        "Wasteland"
      when 26,27        # 土肌
        "DirtField"
      when 32,33        # 砂漠
        "Desert"
      when 34           # 岩地
        "Lava1"
      when 35           # 岩地（溶岩）
        "Lava2"
      when 40,41        # 雪原
        "Snowfield"
      when 42           # 雲
        "Clouds"
      when 4,5          # 毒の沼
        "PoisonSwamp"
      end
    else
      terrain_battleback1_name_japan(type)
    end
=begin
    case type
    when 24,25        # 荒れ地
      "Wasteland"
    when 26,27        # 土肌
      "DirtField"
    when 32,33        # 砂漠
      "Desert"
    when 34           # 岩地
      "Lava1"
    when 35           # 岩地（溶岩）
      "Lava2"
    when 40,41        # 雪原
      "Snowfield"
    when 42           # 雲
      "Clouds"
    when 4,5          # 毒の沼
      "PoisonSwamp"
    end
=end
  end
  #--------------------------------------------------------------------------
  # ● 地形に対応する戦闘背景（壁）ファイル名の取得
  #--------------------------------------------------------------------------
  alias terrain_battleback2_name_japan terrain_battleback2_name
  def terrain_battleback2_name(type)
    if $game_map.overworld_jp?
      case type
      when 17,25        # 森
        "Forest1"
      when 33        # 紅葉
        "Forest3"
      when 22,24,28,30        # 荒れ地
        "Wasteland"
      when 40,41,43,44,46        # 雪原
        "Snowfield"
      end
    elsif $game_map.overworld_demon?
      "PoisonSwamp"
    else
      terrain_battleback2_name_japan(type)
    end
=begin
    case type
    when 20,21        # 森
      "Forest1"
    when 22,30,38     # 低い山
      "Cliff"
    when 24,25,26,27  # 荒れ地、土肌
      "Wasteland"
    when 32,33        # 砂漠
      "Desert"
    when 34,35        # 岩地
      "Lava"
    when 40,41        # 雪原
      "Snowfield"
    when 42           # 雲
      "Clouds"
    when 4,5          # 毒の沼
      "PoisonSwamp"
    end
=end
  end
  #--------------------------------------------------------------------------
  # ● デフォルト 戦闘背景（床）ファイル名の取得
  #--------------------------------------------------------------------------
  alias float_default_battleback1_name default_battleback1_name
  def default_battleback1_name
    return "Translucent" if $game_map.overworld_demon?
    float_default_battleback1_name
  end
end