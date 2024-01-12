module FAKEREAL
  
  LIBERATE          = 7 #魔力解放率の格納変数
  LIBERATE_OPACITY  = 7 #魔力解放率ウインドウを表示するかの判定スイッチ
  
  
  LUNA_M = Hash[
                       1 => 5, #MP
                       4 => 1.5, #魔力
                       5 => 1.0 #法力
                                      ]
  MAX_POTENTIAL = 120
  
end

class RPG::Actor < RPG::BaseItem
  def summon_growth
    @summon_growth ||= growth_set
  end
  def growth_set
    sg = Array.new(9, 0)
    if note =~ /\<HP:(\d+?\.?\d*?),MP:(\d+?\.?\d*?),SP:(\d+?\.?\d*?)\>/
      st_up = [$1.to_f, $2.to_f, $3.to_f]
      2.times {|i| sg[i] += st_up[i]}
      sg[8] += st_up[2]
    end
    if note =~ /\<攻:(\d+?\.?\d*?),防:(\d+?\.?\d*?),魔:(\d+?\.?\d*?),魔防:(\d+?\.?\d*?),敏:(\d+?\.?\d*?),運:(\d+?\.?\d*?)\>/
      st_up = [$1.to_f, $2.to_f, $3.to_f, $4.to_f, $5.to_f, $6.to_f]
      st_up.size.times {|i| sg[i + 2] += st_up[i]}
    end
    sg
  end
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
=begin
  alias summon_growth_setup setup
  def setup(actor_id)
    @sg_base = Array.new(9, 0)
    summon_growth_setup(actor_id)
    summon_growth_base_set if summon_type?
    recover_all
  end
  #--------------------------------------------------------------------------
  # ○ 解放率による召喚ユニットの能力値の上昇　全ステータス
  #--------------------------------------------------------------------------
  def summon_growth_base_set
    if actor.note =~ /\<HP:(\w+?),MP:(\w+?),SP:(\w+?)\>/
      st_up = [FAKEREAL::SG_HP[$1], FAKEREAL::SG_MSP[$2], FAKEREAL::SG_MSP[$3]]
      2.times {|i| @sg_base[i] += st_up[i]}
      @sg_base[8] += st_up[2]
    end
    if actor.note =~ /\<攻:(\w+?),防:(\w+?),魔:(\w+?),魔防:(\w+?),敏:(\w+?),運:(\w+?)\>/
      st_up = [$1, $2, $3, $4, $5, $6]
      st_up.size.times {|i| @sg_base[i + 2] += FAKEREAL::SUMMON_GROWTH[st_up[i]]}
    end
  end
=end
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :pp                     # ポテンシャルポイント
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias pp_setup setup
  def setup(actor_id)
    @pp = 0
    pp_setup(actor_id)
    pp_initialize
  end
  #--------------------------------------------------------------------------
  # 〇ポテンシャルポイントセット
  #--------------------------------------------------------------------------
  def pp_initialize
    @pp = main? ? FAKEREAL::MAX_POTENTIAL : 0
  end
  #--------------------------------------------------------------------------
  # 〇ポテンシャルポイントラストバトルセット
  #--------------------------------------------------------------------------
  def pp_spell_quintet
    @pp = 200
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ポテンシャルポイントの変更
  #--------------------------------------------------------------------------
  def pp=(pp)
    @pp = [[pp, FAKEREAL::MAX_POTENTIAL].min, 0].max
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 魔力吸収率を含めたポテンシャルポイント
  #--------------------------------------------------------------------------
  #def potential_point
    #[[$game_variables[FAKEREAL::LIBERATE] + @pp, FAKEREAL::MAX_POTENTIAL].min, 0].max
  #end
  #--------------------------------------------------------------------------
  # ○ 解放率による能力値の上昇　ＭＰ・魔力・魔法防御のみ
  #--------------------------------------------------------------------------
  def liberate_point(param_id)
    case param_id
    when 1,4,5;   (@pp * FAKEREAL::LUNA_M[param_id] * liberate_lv_point(param_id)).to_i
    else      ;    0
    end
  end
  #--------------------------------------------------------------------------
  # ○ 能力値の上昇　レベル反映
  #--------------------------------------------------------------------------
  def liberate_lv_point(param_id)
    return 0.04 * (1 + self.level / 4) if param_id == 1
    return 0.1 * (1 + self.level / 10)
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の基本値取得　※エイリアス　
  #　　解放率による上昇は装備後の値ではなく基本能力値のみ
  #--------------------------------------------------------------------------
  alias liberate_point_param_base param_base
  def param_base(param_id)
    if main?
      liberate_point_param_base(param_id) + liberate_point(param_id)
    else
      liberate_point_param_base(param_id)
    end
  end
end
