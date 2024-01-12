#==============================================================================
# ■ RGSS3 逃走後処理修正 Ver1.00　by 星潟
#------------------------------------------------------------------------------
# アクター側の逃走成功時、隠れているはずの敵が出現してしまう不具合を修正します。
#==============================================================================
class Game_BattlerBase
  attr_accessor :void_appear
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_hidden initialize
  def initialize
    initialize_hidden
    @void_appear = false
  end
  #--------------------------------------------------------------------------
  # ● 現れる
  #--------------------------------------------------------------------------
  alias appear_hidden appear
  def appear
    return if @void_appear == true
    appear_hidden
  end
end

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 戦闘終了処理
  #--------------------------------------------------------------------------
  alias on_battle_end_hidden on_battle_end
  def on_battle_end
    self.void_appear = true if self.enemy? && self.hidden?
    on_battle_end_hidden
  end
end

#==============================================================================
# ■ RGSS3 敵スキル選択挙動改善＆戦闘不能無視回復 Ver1.00 by 星潟
#------------------------------------------------------------------------------
#   プリセットスクリプトにおいて
#   敵から敵へ回復スキル（戦闘不能回復含む）を行う際に
#   必ず最後尾（敵選択ウィンドウの最後）を最優先で選択する挙動を変更し
#   ランダムターゲットによる選択を行います。
#
#   また、戦闘不能状態か否かに関わらず回復を行う
#   アイテムやスキルの作成が可能となります。
#==============================================================================

#Game_Actionを一箇所再定義しております。
#極力、素材挿入場所は▼ 素材の直下にしていただく事をお勧めします。

#アイテム・スキルのメモ欄に
#下で設定する戦闘不能無視設定用ワードを記入する事で
#そのアイテム・スキルは味方の戦闘不能状態を無視して
#回復を行う事が出来ます。

module D_V_HEAL
  
  #アイテム・スキルのメモ欄に記入する戦闘不能無視設定用ワードを設定します。
  
  WORD = "[戦闘不能無視]"
  
end
class Game_Action
  #--------------------------------------------------------------------------
  # ● 味方に対するターゲット
  #--------------------------------------------------------------------------
  def targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        if @target_index < 0
          [friends_unit.random_dead_target]
        else
          [friends_unit.smooth_dead_target(@target_index)]
        end
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.note.include?(D_V_HEAL::WORD)
        if item.for_one?
          if @target_index < 0
            [friends_unit.random_target_void_all]
          else
            [friends_unit.smooth_target_void_all(@target_index)]
          end
        else
          friends_unit.exist_members
        end
      else
        if item.for_one?
          if @target_index < 0
            [friends_unit.random_target]
          else
            [friends_unit.smooth_target(@target_index)]
          end
        else
          friends_unit.alive_members
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用対象候補を取得
  #--------------------------------------------------------------------------
  alias item_target_candidates_void_all item_target_candidates
  def item_target_candidates
    if item.note.include?(D_V_HEAL::WORD)
      if item.for_opponent?
        opponents_unit.exist_members
      else
        friends_unit.exist_members
      end
    else
      item_target_candidates_void_all
    end
  end
end

class Game_Unit
  #--------------------------------------------------------------------------
  # ● 戦闘不能の対象を含むターゲットのスムーズな決定
  #--------------------------------------------------------------------------
  def smooth_target_void_all(index)
    member = members[index]
  end
  #--------------------------------------------------------------------------
  # ● 戦闘不能の対象を含むターゲットのランダムな決定
  #--------------------------------------------------------------------------
  def random_target_void_all
    exist_members.empty? ? nil : exist_members[rand(exist_members.size)]
  end
  #--------------------------------------------------------------------------
  # ● 存在しているメンバーの配列取得
  #--------------------------------------------------------------------------
  def exist_members
    members.select {|member| member.exist? }
  end
end

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの適用テスト
  #    使用対象が全快しているときの回復禁止などを判定する。
  #--------------------------------------------------------------------------
  alias item_test_void_all item_test
  def item_test(user, item)
    if item.note.include?(D_V_HEAL::WORD)
      return true if $game_party.in_battle
      return true if item.for_opponent?
      return true if item.damage.recover? && item.damage.to_hp? && hp < mhp
      return true if item.damage.recover? && item.damage.to_mp? && mp < mmp
      return true if item_has_any_valid_effects?(user, item)
      return false
    else
      item_test_void_all(user, item)
    end
  end
end

#==============================================================================
# ■ RGSS3 画面のシェイク不具合修正 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# ウェイト設定が正常に機能しない不具合を修正します。
# 素材欄のなるべく上の方に導入されるといいと思います。
# ぶっちゃけると数字を2箇所変えただけです。
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 画面のシェイク
  #--------------------------------------------------------------------------
  def command_225
    screen.start_shake(@params[0], @params[1], @params[2])
    wait(@params[2]) if @params[3]
  end
end

#==============================================================================
# ■ RGSS3 ステート行動制限修正 Ver1.01 by 星潟
#------------------------------------------------------------------------------
# プリセットスクリプトでは、行動制限のあるステートにかかっている状態で
# 新たに何らかのステートを付与された際、強制的に行動がクリアさせられます。
# この仕様を変更し、行動制限レベルに変動がない場合は
# 行動のクリアを行わないように修正します。
#
# 例.スクリプト適用前
#    混乱中のキャラクターが行動前に毒を受けた場合
#    混乱による無差別攻撃がキャンセルされる。
# 
#    スクリプト適用後
#    混乱中のキャラクターが行動前に毒を受けた場合でも
#    混乱による無差別攻撃はキャンセルされない。
#    ただし、制限レベルの高いステート（麻痺や、味方のみを攻撃するステート等）を
#    付与された場合は、行動をキャンセルされる。
#------------------------------------------------------------------------------
# Ver1.01 戦闘不能ステート付与時の処理を修正
#==============================================================================
class Game_Battler < Game_BattlerBase
  alias add_new_state_restrict add_new_state
  def add_new_state(state_id)
    if restriction == 0 or state_id == death_state_id
      
      #元々の制限がない場合
      #もしくは指定IDが戦闘不能ステートIDの場合
      
      #プリセットスクリプトの処理を実行する
      add_new_state_restrict(state_id)
    else
      
      #元々何らかの制限がある場合
      #ステート付与前に制限レベルを取得
      pre_restriciton = restriction
      
      #ステート付与
      @states.push(state_id)
      
      #付与前と制限レベルを比較して
      #制限レベルの変動があった場合にのみ行動を制限する。
      on_restrict if restriction != pre_restriciton
      
      #ステート並び替え
      sort_states
      
      #リフレッシュ
      refresh
    end
  end
end

#==============================================================================
# ■ RGSS3 通常攻撃時の攻撃追加回数強制適用 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# 通常攻撃時、攻撃範囲がランダム、もしくは全体になっている場合は
# 攻撃回数が追加されず、1回しか攻撃しない不具合を修正します。
#==============================================================================
class Game_Action
  #--------------------------------------------------------------------------
  # ● 敵に対するターゲット
  #--------------------------------------------------------------------------
  alias targets_for_opponents_attack_change targets_for_opponents
  def targets_for_opponents
    
    #本来の処理を行い、ターゲット配列を取得する。
    
    array_data = targets_for_opponents_attack_change
    
    #行動が通常攻撃の場合は分岐する。
    
    if attack?
      
      #行動者の攻撃追加回数を取得する。
      
      number = @subject.atk_times_add.to_i
      
      #行動者の攻撃追加回数が0以下の場合は既存の配列を返す。
      
      return array_data if number <= 0
      
      if item.for_random?#行動がランダムターゲットの場合
        
        #攻撃追加回数分だけ、ランダムターゲットを配列に加える。
        
        number.times do
          #array_data += Array.new(item.number_of_targets) { opponents_unit.random_target }
          #ランダムターゲット最適化合わせ
          array_data += opponents_unit.random_target_extra(item.number_of_targets)
        end
        
      elsif item.for_one?#行動が単体の場合
        
        #何もしない
        
      else#行動が全体の場合
        
        #攻撃追加回数分だけ、敵全体を配列に加える。
        
        number.times do
          array_data += opponents_unit.alive_members
        end
        
      end
      
    end
    
    #配列を返す。
    
    return array_data
  end
end

#==============================================================================
# ■ RGSS3 暗号化作品テストモード禁止 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# 暗号化ファイルが作成されている状態でも特定の手順を踏む事で
# テストモードでゲームプレイを行える問題を解決します。
# エディタ上でのテストモードには影響ありません。
#==============================================================================
class Scene_Base
  #--------------------------------------------------------------------------
  # ● フレーム更新（基本）
  #--------------------------------------------------------------------------
  alias update_basic_exit update_basic
  def update_basic
    SceneManager.illegal_test_mode_prevent
    update_basic_exit
  end
end

class << SceneManager
  attr_reader :protect_flag
  #--------------------------------------------------------------------------
  # ● 実行
  #--------------------------------------------------------------------------
  alias :run_exit :run
  def run
    protect_execute
    run_exit
  end
  #--------------------------------------------------------------------------
  # ● 暗号化ファイルの有無を確認し、保護の有無を設定する
  #--------------------------------------------------------------------------
  def protect_execute
    @protect_flag = !Dir.glob('Game.rgss3a').empty?
  end
  #--------------------------------------------------------------------------
  # ● 不正テストモードの場合、ゲームを強制終了させる
  #--------------------------------------------------------------------------
  def illegal_test_mode_prevent
    exit if illegal_test?
  end
  #--------------------------------------------------------------------------
  # ● 不正テストモード判定
  #--------------------------------------------------------------------------
  def illegal_test?
    #保護が有効で、なおかつテストモードの場合は不正テストモードと判定
    protect_flag == true && ($TEST or $DEBUG)
  end
end

#==============================================================================
# ■ RGSS3 イベントステート付与/解除不具合修正 Ver1.01 by 星潟
#------------------------------------------------------------------------------
# イベントコマンドでステートを一度解除してから
# ステート付与を行うと、ステート付与が無効化される不具合を修正します。
# VXAce_SP1で修正されたように見えますが、あの修正では不完全です。
#==============================================================================
# [×]VXAce_SP1なし
# 不具合発生の手順を踏む事で無条件に不具合発生。
#------------------------------------------------------------------------------
# [△]VXAce_SP1あり
# 不具合発生の手順を踏む事で
# 味方パーティメンバーのみ不具合の影響を受けない
# パーティにいないアクター、戦闘中であれば、戦闘メンバー以外のアクターや
# 敵側は不具合の影響をしっかり受けてしまう。
#------------------------------------------------------------------------------
# [○]本スクリプト導入
# 不具合発生の手順を踏んでも異常は起きない。
#==============================================================================
class Game_Temp
  attr_accessor :event_state_changing
end
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ステートの変更
  #--------------------------------------------------------------------------
  alias command_313_event_state_changing command_313
  def command_313
    $game_temp.event_state_changing = true
    command_313_event_state_changing
    $game_temp.event_state_changing = nil
  end
  #--------------------------------------------------------------------------
  # 敵キャラのステート変更
  #--------------------------------------------------------------------------
  alias command_333_event_state_changing command_333
  def command_333
    $game_temp.event_state_changing = true
    command_333_event_state_changing
    $game_temp.event_state_changing = nil
  end
end
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ステートの付加
  #--------------------------------------------------------------------------
  alias add_state_event_state_changing add_state
  def add_state(state_id)
    add_state_event_state_changing(state_id)
    @result.clear_status_effects if $game_temp.event_state_changing
  end
  #--------------------------------------------------------------------------
  # ステートの解除
  #--------------------------------------------------------------------------
  alias remove_state_event_state_changing remove_state
  def remove_state(state_id)
    remove_state_event_state_changing(state_id)
    @result.clear_status_effects if $game_temp.event_state_changing
  end
end

#==============================================================================
# ■ RGSS3 連続回数/攻撃追加回数評価不具合修正 Ver1.01 by 星潟
#------------------------------------------------------------------------------
# アイテム/スキルの連続回数や通常攻撃に対する攻撃追加回数特徴の効果が
# 行動評価時に反映されない不具合を修正します。
# これにより、連続攻撃系のスキルが自動戦闘で選択されにくい現象を解消出来ます。
#==============================================================================
class Game_Action
  #--------------------------------------------------------------------------
  # スキル／アイテムの評価
  #--------------------------------------------------------------------------
  alias evaluate_item_i_repeats evaluate_item
  def evaluate_item
    
    #本来の処理を実行。
    
    evaluate_item_i_repeats
    
    #連続回数を適用。
        
    @value *= item.repeats
    
    #通常攻撃の場合、攻撃追加回数を反映。
    
    @value *= (1 + subject.atk_times_add.to_i) if attack?
    
  end
end

#==============================================================================
# ■ RGSS3 イベントコマンド「HPの増減」
#          「敵キャラのHP増減」不具合修正 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# イベントコマンド「敵キャラのHP増減」実行時
# 対象が敵全体で、敵先頭インデックスの敵キャラが戦闘不能になっている場合
# 後続インデックスの敵に対して処理が行われない不具合を修正します。
# 
# また、ステート無効化で「戦闘不能」を無効化したアクター/敵キャラの
# HPを0にした後、イベントコマンド「HPの増減」/「敵キャラのHP増減」を実行し
# 操作で「減らす」を選択、「戦闘不能を許可」のチェックをしない場合
# HPが0から1に回復してしまう不具合を修正します。
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # 敵キャラの HP 増減
  #--------------------------------------------------------------------------
  def command_331
    
    #途中まで通常処理で進める。
    
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      
      #ここだけ変更。returnをnextへ。
      
      next if enemy.dead?
      
      #以降は通常処理。
      
      enemy.change_hp(value, @params[4])
      enemy.perform_collapse_effect if enemy.dead?
      
    end
  end
end
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # HP の増減（イベント用）
  #--------------------------------------------------------------------------
  alias change_hp_no_h1 change_hp
  def change_hp(value, enable_death)
    
    #現在HPが0以下で変動値が負の値（ダメージ）の場合は何もしない。
    
    return if self.hp <= 0 && value < 0
    
    #本来の処理を実行。
    
    change_hp_no_h1(value, enable_death)
    
  end
end

#==============================================================================
# ■ RGSS3 行動条件合致判定ターン数修正 Ver1.00 by 星潟
#==============================================================================
# 敵の行動条件合致処理がターン数増加前に判定される為に
# 1ターン目が0ターン目の行動として計算される現象を修正します。
#==============================================================================
class Game_Troop < Game_Unit
  attr_accessor :tc_p1_flag
  #--------------------------------------------------------------------------
  # 現在のターン数
  #--------------------------------------------------------------------------
  alias turn_count_plus1 turn_count
  def turn_count
    
    #行動条件合致判定時は1を足す。
    
    turn_count_plus1 + (@tc_p1_flag ? 1 : 0)
    
  end
end
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # 行動条件合致判定［ターン数］
  #--------------------------------------------------------------------------
  alias conditions_met_turns_tc_p1_flag? conditions_met_turns?
  def conditions_met_turns?(param1, param2)
    
    #行動条件合致判定をtrueにする。
    
    $game_troop.tc_p1_flag = true
    
    #本来の処理を実行し、結果を取得しておく。
    
    f = conditions_met_turns_tc_p1_flag?(param1, param2)
    
    #行動条件合致判定をnilにする。
    
    $game_troop.tc_p1_flag = nil
    
    #結果を返す。
    
    f
    
  end
end

#==============================================================================
# ■ RGSS3 タイトルでゲームオブジェクト再生成 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# RPGツクールVXAceではRPGツクールVXと違い
# 起動時とニューゲームの選択時にのみゲームオブジェクトが生成され
# タイトル画面でゲームオブジェクトが生成されません。
# 
# これにより、コモンイベントを設定したアイテム・スキルにより全滅した場合や
# メニュー画面やイベントからタイトル画面に戻った際等に
# セーブデータをロードすると、発生するはずだったコモンイベントが
# ロードしたタイミングで発動し、致命的な進行異常が発生する場合があります。
# 
# このスクリプトを使用する事で、選択したゲームオブジェクトを
# タイトル画面で毎回再生成するように変更出来ます。
# 
# ただし、デフォルト仕様のタイトル画面での実行を想定しております。
# マップ画面を背景にする等の場合は
# 正常に動作しない場合がありますのでご容赦下さい。
#==============================================================================
module TitleReset
  
  #Game_Tempを初期化するか？
  
  TEM = true
  
  #Game_Systemを初期化するか？
  
  SYS = true
  
  #Game_Timerを初期化するか？
  
  TIM = true
  
  #Game_Messageを初期化するか？
  
  MES = true
  
  #Game_Switchesを初期化するか？
  
  SWI = true
  
  #Game_Variablesを初期化するか？
  
  VAR = true
  
  #Game_SelfSwitchesを初期化するか？
  
  SEL = true
  
  #Game_Actorsを初期化するか？
  
  ACT = true
  
  #Game_Partyを初期化するか？
  
  PAR = true
  
  #Game_Troopを初期化するか？
  
  TRO = true
  
  #Game_Mapを初期化するか？
  
  MAP = true
  
  #Game_Playerを初期化するか？
  
  PLA = true
  
end
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # 開始処理
  #--------------------------------------------------------------------------
  alias start_create_game_objects start
  def start
    $game_temp          = Game_Temp.new if TitleReset::TEM
    $game_system        = Game_System.new if TitleReset::SYS
    $game_timer         = Game_Timer.new if TitleReset::TIM
    $game_message       = Game_Message.new if TitleReset::MES
    $game_switches      = Game_Switches.new if TitleReset::SWI
    $game_variables     = Game_Variables.new if TitleReset::VAR
    $game_self_switches = Game_SelfSwitches.new if TitleReset::SEL
    $game_actors        = Game_Actors.new if TitleReset::ACT
    $game_party         = Game_Party.new if TitleReset::PAR
    $game_troop         = Game_Troop.new if TitleReset::TRO
    $game_map           = Game_Map.new if TitleReset::MAP
    $game_player        = Game_Player.new if TitleReset::PLA
    start_create_game_objects
  end
end

#==============================================================================
# ■ RGSS3 VXAce_SP1ピクチャ処理致命的不具合修正 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# ファイル名を指定せずに基準位置を中心にしてピクチャの表示を行った際
# エラーが出る致命的不具合を修正します。
#==============================================================================
class Sprite_Picture < Sprite
  #--------------------------------------------------------------------------
  # 原点の更新
  #--------------------------------------------------------------------------
  alias update_origin_noname update_origin
  def update_origin
    if @picture.name.empty?
      self.ox = 0
      self.oy = 0
    else
      update_origin_noname
    end
  end
end