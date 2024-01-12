=begin
#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader     :bp                     # バッドポイント（堕落度）
  attr_accessor   :virgin                 # 処女判定変数
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias bad_point_initialize initialize
  def initialize(actor_id)
    @bp = 0
    @virgin = true
    bad_point_initialize(actor_id)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def bp=(bp)
    @bp = [[bp, 100].min, 0].max
  end
  #--------------------------------------------------------------------------
  # ○ バッドポイントによる能力値の低下率　最大で半減　ＨＰＭＰは除外
  #--------------------------------------------------------------------------
  def bad_point(param_id)
    if param_id == 0 || param_id == 1 || pureness
      1
    else
      1 - @bp * 0.005
    end
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の基本値取得　※エイリアス　
  #　　BPによる低下は装備後の値ではなく基本能力値のみ
  #--------------------------------------------------------------------------
  alias bad_point_param_base param_base
  def param_base(param_id)
    (bad_point_param_base(param_id) * bad_point(param_id)).to_i
  end
  #--------------------------------------------------------------------------
  # ○ バッドポイント無効判定
  #--------------------------------------------------------------------------
  def pureness
    all_note_check("<ピュアネス>")
  end
  #--------------------------------------------------------------------------
  # ○ 処女判定
  #--------------------------------------------------------------------------
  def virgin?
    @virgin
  end
end

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　スプライトや行動に関するメソッドを追加したバトラーのクラスです。このクラス
# は Game_Actor クラスと Game_Enemy クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 使用効果［TP 増加］　※エイリアス　BP浄化追加
  #    BP浄化を行う際は　TP増加を0%　と設定する必要あり
  #--------------------------------------------------------------------------
  alias bad_heal_item_effect_gain_tp item_effect_gain_tp
  def item_effect_gain_tp(user, item, effect)
    if item.note =~ /\<BP浄化:(\d+)\>/
      value = $1.to_i
      #@result.success = true
      self.bp -= value
    else
      bad_heal_item_effect_gain_tp(user, item, effect)
    end
  end
  #--------------------------------------------------------------------------
  # ● 使用効果のテスト　※再定義
  #--------------------------------------------------------------------------
  def item_effect_test(user, item, effect)
    case effect.code
    when EFFECT_RECOVER_HP
      hp < mhp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_RECOVER_MP
      mp < mmp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_GAIN_TP #追加
      if item.note =~ /\<BP浄化:(\d+)\>/
        @bp > 0
      else
        tp < max_tp || effect.value1 < 0 || effect.value2 < 0
      end
    when EFFECT_ADD_STATE
      !state?(effect.data_id)
    when EFFECT_REMOVE_STATE
      state?(effect.data_id)
    when EFFECT_ADD_BUFF
      !buff_max?(effect.data_id)
    when EFFECT_ADD_DEBUFF
      !debuff_max?(effect.data_id)
    when EFFECT_REMOVE_BUFF
      buff?(effect.data_id)
    when EFFECT_REMOVE_DEBUFF
      debuff?(effect.data_id)
    when EFFECT_LEARN_SKILL
      actor? && !skills.include?($data_skills[effect.data_id])
    else
      true
    end
  end
end
=end