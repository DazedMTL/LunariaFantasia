#==============================================================================
# ■ Game_ActionResult
#------------------------------------------------------------------------------
# 　戦闘行動の結果を扱うクラスです。このクラスは Game_Battler クラスの内部で
# 使用されます。
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # ● 定数（使用効果）
  #--------------------------------------------------------------------------
  DRAIN_EL     = 2              # 吸収属性番号
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :ex_drain                     # 特殊吸収フラグ
  attr_accessor :user                         # 攻撃者
  attr_accessor :tp_drain                     # TP 吸収
  #--------------------------------------------------------------------------
  # ● ダメージの作成　※再定義
  #--------------------------------------------------------------------------
  def make_damage(value, item)
    @critical = false if value == 0
    @hp_damage = value if item.damage.to_hp?
    @mp_damage = value if item.damage.to_mp?
    @mp_damage = [@battler.mp, @mp_damage].min
    @hp_drain = @hp_damage if item.damage.drain?
    @mp_drain = @mp_damage if item.damage.drain?
    if item.extra_drain?
      if item.drain_rate[0] == "HP"
        @hp_drain = @ex_drain = (@hp_damage * item.drain_rate[1] * @battler.element_rate(DRAIN_EL)).to_i
      elsif item.drain_rate[0] == "MP"
        @mp_damage = (@hp_damage * item.drain_rate[1] * @battler.element_rate(DRAIN_EL)).to_i
        @mp_damage = @mp_drain = @ex_drain = [@battler.mp, @mp_damage].min
      elsif item.drain_rate[0] == "TP"
        @tp_damage = (@hp_damage * item.drain_rate[1] * @battler.element_rate(DRAIN_EL)).to_i
        @tp_damage = @tp_drain = @ex_drain = [@battler.tp, @tp_damage].min
      end
    end
    @hp_drain = [@battler.hp, @hp_drain].min
    @success = true if item.damage.to_hp? || @mp_damage != 0
  end
  #--------------------------------------------------------------------------
  # ● ダメージ値のクリア　※エイリアス
  #--------------------------------------------------------------------------
  alias ex_drain_clear_damage_values clear_damage_values
  def clear_damage_values
    ex_drain_clear_damage_values
    @tp_drain = 0
    @ex_drain = 0
    @user = nil
  end
  #--------------------------------------------------------------------------
  # ● HP ダメージの文章を取得　※エイリアス
  #--------------------------------------------------------------------------
  alias ex_drain_hp_damage_text hp_damage_text
  def hp_damage_text
    if @ex_drain > 0
      if @hp_damage > 0
        fmt = @battler.actor? ? Vocab::ActorDamage : Vocab::EnemyDamage
        sprintf(fmt, @battler.name, @hp_damage)
      elsif @hp_damage < 0
        fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
        sprintf(fmt, @battler.name, Vocab::hp, -hp_damage)
      else
        fmt = @battler.actor? ? Vocab::ActorNoDamage : Vocab::EnemyNoDamage
        sprintf(fmt, @battler.name)
      end
    else
      ex_drain_hp_damage_text
    end
  end
  #--------------------------------------------------------------------------
  # ● TP ダメージの文章を取得
  #--------------------------------------------------------------------------
  alias drain_tp_damage_text tp_damage_text
  def tp_damage_text
    if @tp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, Vocab::tp, @tp_drain)
    else
      drain_tp_damage_text
    end
    #elsif @tp_damage > 0
      #fmt = @battler.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      #sprintf(fmt, @battler.name, Vocab::tp, @tp_damage)
    #elsif @tp_damage < 0
      #fmt = @battler.actor? ? Vocab::ActorGain : Vocab::EnemyGain
      #sprintf(fmt, @battler.name, Vocab::tp, -@tp_damage)
    #else
      #""
    #end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def drain_text
    if @mp_drain > 0
      fmt = @user.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @user.name, Vocab::mp, @mp_drain)
    elsif @tp_drain > 0
      fmt = @user.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @user.name, Vocab::tp, @tp_drain)
    elsif @hp_drain > 0
      fmt = @user.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @user.name, Vocab::hp, @hp_drain)
    end
  end
end

class RPG::UsableItem < RPG::BaseItem
  def extra_drain?
    drain_rate[1] > 0
  end
  def drain_rate
    @drain_rate ||= set_drain_rate
  end
  def set_drain_rate
    return [$1, $2.to_i * 0.01] if self.note =~ /\<(HP|MP|TP)吸収率\:(\d+)\>/ #/\<(\w+)吸収率\:(\d+)\>/
    return ["", 0]
  end
  def tp_drain?
    drain_rate[0] == "TP"
  end
end

#==============================================================================
# ■ Window_BattleLog
#------------------------------------------------------------------------------
# 　戦闘の進行を実況表示するウィンドウです。枠は表示しませんが、便宜上ウィンド
# ウとして扱います。
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● HP ダメージ表示　※エイリアス
  #--------------------------------------------------------------------------
  alias ex_drain_display_hp_damage display_hp_damage
  def display_hp_damage(target, item)
      if target.result.ex_drain > 0
      return if target.result.hp_damage == 0 && item && !item.damage.to_hp?
      if target.result.hp_damage > 0
        target.perform_damage_effect
      end
      Sound.play_recovery if target.result.hp_damage < 0
      add_text(target.result.hp_damage_text)
      wait
    else
      ex_drain_display_hp_damage(target, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● ダメージの表示
  #--------------------------------------------------------------------------
  alias ex_drain_display_damage display_damage
  def display_damage(target, item)
    ex_drain_display_damage(target, item)
    display_ex_drain(target, item)
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def display_ex_drain(target, item)
    return if target.result.ex_drain == 0
    Sound.play_recovery
    add_text(target.result.drain_text)
    wait
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
  # ● ダメージ計算
  #--------------------------------------------------------------------------
  alias ex_drain_make_damage_value make_damage_value
  def make_damage_value(user, item)
    @result.user = user
    ex_drain_make_damage_value(user, item)
  end
  #--------------------------------------------------------------------------
  # ● ダメージの処理
  #    呼び出し前に @result.hp_damage @result.mp_damage @result.hp_drain
  #    @result.mp_drain が設定されていること。
  #--------------------------------------------------------------------------
  alias tp_drain_execute_damage execute_damage
  def execute_damage(user)
    tp_drain_execute_damage(user)
    self.tp -= @result.tp_damage
    user.tp += @result.tp_drain
  end
end
