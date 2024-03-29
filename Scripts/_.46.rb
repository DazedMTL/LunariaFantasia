class RPG::Enemy < RPG::BaseItem
  def base_level
    @base_level ||= base_level_set
  end
  def base_level_set
    self.note =~ /\<初期レベル:(\d+)\>/ ? $1.to_i : 1
  end
end



module FAKEREAL
  
  DISCLOSE = "暴く"
  TEST_LEVEL = 1
  LEVELUP_SWITCHES = 217
  
end
#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :enemy_change_level                # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias enemy_level_initialize initialize
  def initialize
    enemy_level_initialize
    @enemy_change_level = {}#[]
  end
end

#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　敵キャラを扱うクラスです。このクラスは Game_Troop クラス（$game_troop）の
# 内部で使用されます。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :base_level
  attr_reader :lv_params
  attr_reader :level
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化　※エイリアス
  #--------------------------------------------------------------------------
  alias enemy_lv_initialize initialize
  def initialize(index, enemy_id)
    init_enemy_lv
    enemy_lv_initialize(index, enemy_id)
    change_set
    base_set
    level_set
    pfo_set
    base_level_change
    lv_plus_set
    @hp = mhp
    @mp = mmp
  end
  #--------------------------------------------------------------------------
  # ○ 追加項目の初期化
  #    予め設定して置かないとmhp等の値を呼び出す時にエラーが出て
  #    上記のオブジェクト初期化をエイリアスで処理出来ない為
  #--------------------------------------------------------------------------
  def init_enemy_lv
    @base_level = 1
    @level = 1
    @lv_params = Array.new(9, 0)
    @change_level = Hash.new
    @base_param_change = false
    @plus_feature_objects = []
    @skill_turn = {}
  end
  #--------------------------------------------------------------------------
  # ○ 初期設定レベルのセット
  #--------------------------------------------------------------------------
  def base_set
    @base_level = enemy.base_level #enemy.note =~ /\<初期レベル:(\d+)\>/ ? $1.to_i : 1
  end
  #--------------------------------------------------------------------------
  # ○ ステータスチェンジレベルと数値のセット
  #--------------------------------------------------------------------------
  def change_set
    return @change_level = $game_temp.enemy_change_level[enemy_id] if $game_temp.enemy_change_level[enemy_id]
    if enemy.note.include?("<LV")
      enemy.note.each_line do |line|
        case line
        when /\<LV(\d+)\s*:\s*HP(\d+)\s*:\s*MP(\d+)\s*:\s*SP(\d+)\s*:\s*攻(\d+)\s*:\s*防(\d+)\s*:\s*魔(\d+)\s*:\s*魔防(\d+)\s*:\s*敏(\d+)\s*:\s*運(\d+)\s*:\s*E(\d+)\s*:\s*G(\d+)\s*:\s*A(\d+)\>/
          @change_level[$1.to_i] = [$2.to_i, $3.to_i, $5.to_i, $6.to_i, $7.to_i, $8.to_i, $9.to_i, $10.to_i, $4.to_i, $11.to_i, $12.to_i, $13.to_i]
        end
      end
    end
    $game_temp.enemy_change_level[enemy_id] = @change_level
  end
  #--------------------------------------------------------------------------
  # ○ 基準レベルの変更
  #--------------------------------------------------------------------------
  def base_level_change
    ary = @change_level.keys
    ary.sort!
    ary.each {|lv|
      if lv <= @level
        @base_level = lv
        @base_param_change = true
      end
    }
  end
  #--------------------------------------------------------------------------
  # ○ 上限レベルの設定
  #--------------------------------------------------------------------------
  def max_level
    enemy.note =~ /\<上限レベル:(\d+)\>/ ? $1.to_i : 99
  end
  #--------------------------------------------------------------------------
  # ○ 下限レベルの設定
  #--------------------------------------------------------------------------
  def min_level
    enemy.note =~ /\<下限レベル:(\d+)\>/ ? $1.to_i : @base_level
  end
  #--------------------------------------------------------------------------
  # ○ レベルのセット
  #--------------------------------------------------------------------------
  def level_set
    return self.level = (@base_level < FAKEREAL::TEST_LEVEL ? FAKEREAL::TEST_LEVEL : @base_level ) if $BTEST
    if $game_system.enemy_level?
      lv = $game_system.enemy_level_pop #イベント戦闘等の場合、事前にレベル指定が可能
    else
      lv = fix_lv? ? fix_lv? : area_level(@base_level)
      lv = level_fluctuation(lv) unless boss? || fix_lv? # マップ毎のレベル変動
      lv = region_plus(lv) unless boss? || $game_player.region_id == 0 # マップ毎のレベル変動
      #lv += $game_map.true_route_plus unless boss? # トゥルールートにおけるレベルプラス
    end
    self.level = lv.to_i
  end
  #--------------------------------------------------------------------------
  # ○ エリアレベル 
  # リージョンID１以上の表記があればそれを、なければID０を、それもなければ
  # レベル１をセット
  #--------------------------------------------------------------------------
  def area_level(base)
    r_id = $game_player.region_id
    r_l = $game_map.region_level(r_id)
    region_zero = $game_map.region_level(0)
    area = r_l ? r_l : (region_zero ? region_zero : 1) #note =~ /\<一律レベル:(\d+)\>/ ? $1.to_i : 1
    area += $game_map.true_route_plus unless boss?
    lv = base < area ? area : base
    return lv
  end
  #--------------------------------------------------------------------------
  # ○ レベルの変動　マップ毎、敵種類毎にレベルを範囲設定可能
  #--------------------------------------------------------------------------
  def level_fluctuation(lv)
    lv += $game_map.region_plus(enemy.name)
=begin
    if $game_map.note =~ /\<#{enemy.name}:(\-?\+?\d+)\>/
      lv += $1.to_i
    elsif $game_map.note =~ /\<敵レベル:(\-?\+?\d+)\>/
      lv += $1.to_i
    end
=end
    #lv_list = [lv - 1, lv]
    #lv = [lv_list[rand(2)], @base_level].max
    lv = [lv, @base_level].max
    return lv
  end
  #--------------------------------------------------------------------------
  # ○ リージョンIDによるレベルの変動　敵毎にレベルを範囲設定可能
  #--------------------------------------------------------------------------
  def region_plus(lv)
    r_id = $game_player.region_id
    lv += $game_map.region_plus("#{r_id},#{enemy.name}")
    return lv
  end
  #--------------------------------------------------------------------------
  # ○ トゥルールートにおけるレベルの増加値
  #--------------------------------------------------------------------------
=begin
  def true_route_plus
    return 0 unless $game_switches[FAKEREAL::LEVELUP_SWITCHES]
    r_id = $game_player.region_id
    if $game_map.note =~ /\<トゥルールート:#{r_id}\s(\-?\+?\d+)\>/
      return $1.to_i
    else
      return $game_map.note =~ /\<トゥルールート:(\-?\+?\d+)\>/ ? $1.to_i : 0
    end
  end
=end
  #--------------------------------------------------------------------------
  # ○ レベルアップにより増えるステータスの基本値のセット
  # HPMPTPは10分の1、その他の数値は20分の1
  #--------------------------------------------------------------------------
  def lv_plus_set
    sg = Array.new(9, 0)
    if enemy.note =~ /\<HP:(\d+?\.?\d*?),MP:(\d+?\.?\d*?),SP:(\d+?\.?\d*?)\>/
      st_up = [$1.to_f, $2.to_f, $3.to_f]
      2.times {|i| sg[i] += st_up[i]}
      sg[8] += st_up[2]
    end
    9.times do |param_id|
      if param_id == 0 || param_id == 1 || param_id == 8
        value = param_base(param_id) * (adjust? ? 0.1 : (adjust?(3) ? 0.05 : 0.02))#0.05)#(adjust?(2) ? 0.05 : (adjust?(4) ? 0.1 : 0.05)))
        sg[param_id] = value if value > sg[param_id]
      else
        sg[param_id] += (param_base(param_id) * (adjust?(2) ? 0.05 : (adjust?(3) ? 0.025 : 0.01)))
      end
    end
=begin
    if enemy.note =~ /\<HP:(\d+?\.?\d*?),MP:(\d+?\.?\d*?),SP:(\d+?\.?\d*?)\>/
      st_up = [$1.to_f, $2.to_f, $3.to_f]
      2.times {|i| sg[i] += st_up[i]}
      sg[8] += st_up[2]
    end
    if enemy.note =~ /\<攻:(\d+?\.?\d*?),防:(\d+?\.?\d*?),魔:(\d+?\.?\d*?),魔防:(\d+?\.?\d*?),敏:(\d+?\.?\d*?),運:(\d+?\.?\d*?)\>/
      st_up = [$1.to_f, $2.to_f, $3.to_f, $4.to_f, $5.to_f, $6.to_f]
      st_up.size.times {|i| sg[i + 2] += st_up[i]}
    end
=end
    @lv_params = sg
  end
  #--------------------------------------------------------------------------
  # ○ 最大HP　※一部の敵のHP操作
  #--------------------------------------------------------------------------
  def mhp
    super + hpp
  end
  #--------------------------------------------------------------------------
  # ○ 最大HPプラス数値　※一部の敵のHP操作
  #--------------------------------------------------------------------------
  def hpp
    @hpp ||= $game_system.enemy_hpp? ? $game_system.enemy_hpp_pop : 0
  end
  #--------------------------------------------------------------------------
  # ○ 通常能力値の変化率取得　※オーバーライド　難易度反映
  #--------------------------------------------------------------------------
  def param_rate(param_id)
    super * (param_id == 0 ? difficulty_rate[0] : difficulty_rate[1])
  end
  #--------------------------------------------------------------------------
  # ○ 難易度による能力値変化
  #--------------------------------------------------------------------------
  def difficulty_rate
    case $game_system.difficulty
    when :hard;      [1.5, 1.2]
    when :ex_hard;   [2.0, 1.5]
    when :unlimited; [3.0, 2.0]
    when :easy;      [0.8, 0.9]
    else ;           [1.0, 1.0]
    end
  end
  #--------------------------------------------------------------------------
  # ○ ベースレベルとの差
  #--------------------------------------------------------------------------
  def level_gap
    @level - @base_level
  end
  #--------------------------------------------------------------------------
  # ○ 調整
  #--------------------------------------------------------------------------
  def adjust_point(i = 1)
    @level - adjust_level(i)
  end
  #--------------------------------------------------------------------------
  # ○ 調整
  #--------------------------------------------------------------------------
  def adjust_level(i)
    case i
    when 0; 40 #経験値系のみ
    when 1; 20 #共通
    when 2; 35 #ステータス
    when 3; 50 #ステータス
    #when 4; 45 #hpmptp
    else  ; 99
    end
  end
  #--------------------------------------------------------------------------
  # ○ 調整
  #--------------------------------------------------------------------------
  def adjust?(i = 1)
    @base_level < adjust_level(i)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def hmt_point(param_id)
    case param_id
    when 0..1 ; true
    when 8 ; true
    else ; false
    end
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の基本値取得
  #--------------------------------------------------------------------------
  alias enemy_level_param_base param_base
  def param_base(param_id)
    if @base_param_change
      @change_level[@base_level][param_id]
    else
      enemy_level_param_base(param_id)
    end
  end
  #--------------------------------------------------------------------------
  # ○ レベルにより増えるステータス値の取得
  #--------------------------------------------------------------------------
  def param_plus(param_id)
    if adjust_point > 0 && hmt_point(param_id) && adjust?
      (adjust_point * @lv_params[param_id] * 0.5) + ((level_gap - adjust_point) * @lv_params[param_id])
    #elsif adjust_point(3) > 0 && hmt_point(param_id) && adjust?(3)
      #(adjust_point(3) * @lv_params[param_id] * 0.5) + ((level_gap - adjust_point(3)) * @lv_params[param_id])
    #elsif adjust_point(2) > 0 && hmt_point(param_id) && adjust?(2)
      #(adjust_point(2) * @lv_params[param_id] * 2) + ((level_gap - adjust_point(2)) * @lv_params[param_id])
    #elsif adjust_point > 0 && hmt_point(param_id) && adjust?(4)
      #(adjust_point(4) * @lv_params[param_id] * 0.5) + ((level_gap - adjust_point(4)) * @lv_params[param_id])
    elsif adjust_point(2) > 0 && !hmt_point(param_id) && adjust?(2)
      (adjust_point(2) * @lv_params[param_id] * 0.5) + ((level_gap - adjust_point(2)) * @lv_params[param_id])
    #elsif adjust_point(3) > 0 && !hmt_point(param_id) && adjust?(3)
    elsif adjust_point(3) > 0 && adjust?(3)
      (adjust_point(3) * @lv_params[param_id] * 0.4) + ((level_gap - adjust_point(3)) * @lv_params[param_id])
    else
      (level_gap * @lv_params[param_id])
    end
  end
  #--------------------------------------------------------------------------
  # ○ ベースチェンジにより変わる獲得値（EXP等）
  #--------------------------------------------------------------------------
  def change_point(param_id)
    @change_level[@base_level][param_id]
  end
  #--------------------------------------------------------------------------
  # ○ 追加値の取得　総合　※経験値・お金は10分の1　APは20分の1
  #--------------------------------------------------------------------------
  def plus_ary(kind, rate = 0.1)
    case kind
    when "経験値"
      p_id = 9
      base = enemy.exp
    when "ゴールド"
      p_id = 10
      base = enemy.gold
    else
      p_id = 11
      base = enemy.ap
    end
    point = (@base_param_change ? change_point(p_id) : base)
    ary = []
    ary.push(enemy.note =~ /\<追加#{kind}:(\d+?\.?\d*?)\>/ ? $1.to_f : 1)
    ary.push(point * rate * (adjust?(0) ? 1 : 0.25))
    return ary.max
  end
  #--------------------------------------------------------------------------
  # ○ 追加経験値の取得
  #--------------------------------------------------------------------------
  def exp_plus
    #base = (@base_param_change ? @change_level[@base_level][9] : enemy.exp)
    plus_ary("経験値")
  end
  #--------------------------------------------------------------------------
  # ○ 追加ゴールドの取得
  #--------------------------------------------------------------------------
  def gold_plus
    #base = (@base_param_change ? @change_level[@base_level][10] : enemy.gold)
    plus_ary("ゴールド")
    #enemy.note =~ /\<追加ゴールド:(\d+?\.?\d*?)\>/ ? $1.to_f : enemy.gold * 0.1
  end
  #--------------------------------------------------------------------------
  # ○ 追加APの取得
  #--------------------------------------------------------------------------
  def ap_plus
    #base = (@base_param_change ? @change_level[@base_level][11] : enemy.ap)
    plus_ary("AP", 0.05)
    #enemy.note =~ /\<追加AP:(\d+?\.?\d*?)\>/ ? $1.to_f : enemy.ap * 0.1
  end
  #--------------------------------------------------------------------------
  # ○ レベルにより増える各種獲得値の計算
  #--------------------------------------------------------------------------
  def lv_plus_point(point)
    if adjust_point(0) > 0 && adjust?(0)
      [(point * (level_gap - adjust_point(0)) + point * adjust_point(0) * 0.25).to_i, 0].max
    else
      [(point * level_gap).to_i, 0].max
    end
  end
  #--------------------------------------------------------------------------
  # ○ 敵レベル
  #--------------------------------------------------------------------------
  def level=(level)
    @level = [[level, max_level].min, min_level].max
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ ボスか
  #--------------------------------------------------------------------------
  def boss?
    enemy.note.include?("<ボス>")
  end
  #--------------------------------------------------------------------------
  # ○ レベル固定エネミーか
  #--------------------------------------------------------------------------
  def fix_lv?
    if $game_map.note =~ /\<レベル固定:#{enemy.name}:(\d+)\>/
      lv = $1.to_i
      lv += $game_map.true_route_plus unless boss?
      return lv
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ○ 通常のパーティレベル反映の行動に戻すか
  #--------------------------------------------------------------------------
  def default_level_action?
    enemy.note.include?("<デフォルト行動>")
  end
  #--------------------------------------------------------------------------
  # ● 行動条件合致判定
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  alias enemy_lv_conditions_met? conditions_met?
  def conditions_met?(action)
    enemy_lv_conditions_met?(action) && !conditions_except_id(action.skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 行動条件合致判定［パーティレベル］　※エイリアス
  #　　　行動条件をパーティレベルではなく自身のレベルに変更
  #　　　自身のレベルにした場合、ターンとHPで行動合致判定が可能
  #--------------------------------------------------------------------------
  alias enemy_lv_conditions_met_party_level? conditions_met_party_level?
  def conditions_met_party_level?(param1, param2)
    if default_level_action?
      enemy_lv_conditions_met_party_level?(param1, param2)
    else
      self.level >= param1 && conditions_met_turn_extra(param1) && conditions_met_extra_all_t(param1)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 指定レベルになったら特定のスキルを除外
  #--------------------------------------------------------------------------
  def conditions_except_id(skill_id)
    enemy.note =~ /\<行動:除外ID#{skill_id}:LV(\d+)\>/ ? self.level >= $1.to_i : false
  end
  #--------------------------------------------------------------------------
  # ○ 指定難易度以上で行動
  #--------------------------------------------------------------------------
  def conditions_difficulty(param1)
    enemy.note =~ /\<行動:LV#{param1}:難易度(E|N|H)\>/ ? difficulty_pfo($1) : true
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定エクストラ［ターン数］
  #--------------------------------------------------------------------------
  def conditions_met_turn_extra(param1)
    n = $game_troop.turn_count + 1
    ex_t = enemy.note =~ /\<行動:LV#{param1}:(\d+)ターン毎\:?(\d*|x)\>/ ? $1.to_i : 1
    if $2 == "x"
      start = 999
      start = @skill_turn[param1] ||= n if conditions_met_extra_all_t(param1)
    else
      start = $2.to_i
    end
    if ex_t == 0
      n == start
    elsif start == 0
      0 == n % ex_t
    else
      n > 0 && n >= start && n % ex_t == start % ex_t
    end
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定エクストラ［HP］
  #--------------------------------------------------------------------------
  def conditions_met_hp_extra(param1)
    hp_min_param = enemy.note =~ /\<行動:LV#{param1}:HP(\d+)\%以上\>/ ? $1.to_i * 0.01 : 0.0
    hp_max_param = enemy.note =~ /\<行動:LV#{param1}:HP(\d+)\%以下\>/ ? $1.to_i * 0.01 : 1.0
    return hp_rate >= hp_min_param && hp_rate <= hp_max_param
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定エクストラ［回復の必要性］
  #--------------------------------------------------------------------------
  def conditions_met_heal_extra(param1)
    rate = enemy.note =~ /\<行動:LV#{param1}:回復(\d+)\>/ ? $1.to_i : 100
    return true if rate == 100
    return !$game_troop.dead_members.empty? if rate == 0
    return !$game_troop.need_heal_members(rate).empty?
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定ターン判定以外まとめ
  #--------------------------------------------------------------------------
  def conditions_met_extra_all_t(param1)
    conditions_met_hp_extra(param1) && conditions_met_heal_extra(param1) && conditions_difficulty(param1)
  end
  #--------------------------------------------------------------------------
  # ● 経験値の取得　※エイリアス
  #--------------------------------------------------------------------------
  alias enemy_lv_exp exp
  def exp
    (@base_param_change ? change_point(9) : enemy_lv_exp) + lv_plus_point(exp_plus)
  end
  #--------------------------------------------------------------------------
  # ● お金の取得　※エイリアス
  #--------------------------------------------------------------------------
  alias enemy_lv_gold gold
  def gold
    (@base_param_change ? change_point(10) : enemy_lv_gold) + lv_plus_point(gold_plus)
  end
  #--------------------------------------------------------------------------
  # ● APの取得　※エイリアス
  #--------------------------------------------------------------------------
  alias enemy_lv_ap ap
  def ap
    (@base_param_change ? change_point(11) : enemy_lv_ap) + lv_plus_point(ap_plus)
  end
  #--------------------------------------------------------------------------
  # ● TP の最大値を取得　※エイリアス
  #--------------------------------------------------------------------------
  alias enemy_max_tp max_tp
  def max_tp
    (enemy_max_tp + param_plus(8)).to_i
  end
  #--------------------------------------------------------------------------
  # ● 特徴を保持する全オブジェクトの配列取得
  #--------------------------------------------------------------------------
  alias level_feature_objects feature_objects
  def feature_objects
    level_feature_objects + @plus_feature_objects
  end
  #--------------------------------------------------------------------------
  # ○ 追加特徴のセット
  #--------------------------------------------------------------------------
  def pfo_set
    enemy.note.each_line do |line|
      case line
      when /\<エネミー特徴:LV(\d+)\s(\d+)(E|N|H)?\>/
        @plus_feature_objects.push($data_classes[$2.to_i]) if @level >= $1.to_i && difficulty_pfo($3)
      when /\<エネミー限定特徴:LV(\d+)\s(\d+)(E|N|H)?\>/
        @plus_feature_objects.push($data_classes[$2.to_i]) if @level == $1.to_i && difficulty_pfo($3)
      end
    end
  end
  #--------------------------------------------------------------------------
  # 〇 　
  #--------------------------------------------------------------------------
  def difficulty_pfo(dif)
    case dif
    when "E" ; difficulty_score == 0 # easy用追加特徴はイージーのみ追加で弱体化用
    when "N" ; difficulty_score >= 1 # normal用はノーマル以上で追加
    when "H" ; difficulty_score >= 2 # hard用はハード以上で追加
    else     ; return true # 指定が無い場合（nil）は全てtrue
    end
  end
  #--------------------------------------------------------------------------
  # ○ 難易度を数値に変換
  #--------------------------------------------------------------------------
  def difficulty_score
    case $game_system.difficulty
    when :easy   ; 0
    when :normal ; 1
    when :hard   ; 2
    else         ; 3
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘開始処理　
  #--------------------------------------------------------------------------
  def on_battle_start
    super
    start_state_set
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘開始時ステートのセット
  #--------------------------------------------------------------------------
  def start_state_set
    enemy.note.each_line do |line|
      case line
      when /\<開始ステート:LV(\d+)\s(\d+)\>/
        add_state($2.to_i) if @level >= $1.to_i
      end
    end
  end
end

#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　マップを扱うクラスです。スクロールや通行可能判定などの機能を持っています。
# このクラスのインスタンスは $game_map で参照されます。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias region_enemy_setup setup
  def setup(map_id)
    region_enemy_setup(map_id)
    region_level_set
    @no_encount_level = {}
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def region_level_set
    @region_level = {}
    @region_plus = {}
    note.each_line do |line|
      case line
      when  /\<リージョン(\d*?)\:(\W*?)(\-?\+?\d+)\>/
        if !$1.empty? && !$2.empty?
          @region_plus["#{$1},#{$2}"] = $3.to_i
        elsif !$2.empty?
          @region_plus[$2] = $3.to_i
        else
          @region_level[$1.to_i] = $3.to_i
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def region_level(r_id)
    @region_level[r_id] ? @region_level[r_id] : (@region_level[0] ? @region_level[0] : nil)
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def region_plus(text)
    @region_plus[text] ? @region_plus[text] : 0
  end
  #--------------------------------------------------------------------------
  # ○ トゥルールートにおけるレベルの増加値
  #--------------------------------------------------------------------------
  def true_route_plus
    return 0 unless $game_switches[FAKEREAL::LEVELUP_SWITCHES]
    r_id = $game_player.region_id
    if note =~ /\<トゥルールート:#{r_id}\s(\-?\+?\d+)\>/
      return $1.to_i
    else
      return note =~ /\<トゥルールート:(\-?\+?\d+)\>/ ? $1.to_i : 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ マップ上の目標レベル リージョンID対応
  #--------------------------------------------------------------------------
  def no_encount_level(r_id = 0)
    return @no_encount_level[r_id] if @no_encount_level[r_id]
    plus = true_route_plus #($game_switches[FAKEREAL::LEVELUP_SWITCHES] && $game_map.note =~ /\<トゥルールート:(\-?\+?\d+)\>/) ? $1.to_i : 0
    if note =~ /\<目標Lv:(\d+):全体\>/
      plus += $1.to_i
    else
      r_l = region_level(r_id)
      plus += note =~ /\<目標Lv:(\d+):#{r_id}\>/ ? $1.to_i : (r_l ? r_l + 5 : 0)
    end
    @no_encount_level[r_id] = plus
    return @no_encount_level[r_id]
  end
end

#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 特定の装備品やスキルを装備しているか？
  #--------------------------------------------------------------------------
  def lv_disclose?
    extra_equip_include?("<#{FAKEREAL::DISCLOSE}:レベル>")
  end
end

#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　敵グループおよび戦闘に関するデータを扱うクラスです。バトルイベントの処理も
# 行います。このクラスのインスタンスは $game_troop で参照されます。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● ドロップアイテムの配列作成
  #--------------------------------------------------------------------------
  alias event_item_make_drop_items make_drop_items
  def make_drop_items
    if $game_system.enemy_item?
      event_item_set
    else
      event_item_make_drop_items
    end
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def event_item_set
    $game_system.enemy_item.inject([]) {|r, di| r.push(item_object(di[0], di[1]))}
  end
  #--------------------------------------------------------------------------
  # ○ アイテムオブジェクトの取得
  #--------------------------------------------------------------------------
  def item_object(kind, data_id)
    return $data_items  [data_id] if kind == 1
    return $data_weapons[data_id] if kind == 2
    return $data_armors [data_id] if kind == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 経験値の合計計算　※エイリアス
  #--------------------------------------------------------------------------
  alias exp_event_total exp_total
  def exp_total
    exp_event_total + $game_system.next_exp
  end
  #--------------------------------------------------------------------------
  # ● お金の合計計算　※再定義　gold_rateの関係上
  #--------------------------------------------------------------------------
  def gold_total
    (dead_members.inject(0) {|r, enemy| r += enemy.gold } + $game_system.next_gold) * gold_rate
  end
  #--------------------------------------------------------------------------
  # ● APの合計計算　※エイリアス
  #--------------------------------------------------------------------------
  alias ap_event_total ap_total
  def ap_total
    ap_event_total + $game_system.next_ap
  end
end

#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは $game_system で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :enemy_hpp     # 
  attr_reader   :enemy_level   # 
  attr_reader   :difficulty    # ゲーム難易度の設定
  attr_reader   :enemy_item    # 
  attr_reader   :next_exp      # 
  attr_reader   :next_gold     # 
  attr_reader   :next_ap       # 
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias difficulty_initialize initialize
  def initialize
    difficulty_initialize
    @difficulty = :normal
    @enemy_level = []
    @enemy_item = []
    @enemy_hpp = []
    @next_exp  = 0
    @next_gold = 0
    @next_ap   = 0
  end
  #--------------------------------------------------------------------------
  # ○ 敵レベル配列の存在判定
  #--------------------------------------------------------------------------
  def enemy_level?
    !@enemy_level.empty?
  end
  #--------------------------------------------------------------------------
  # ○ 敵レベルのセット
  #--------------------------------------------------------------------------
  def enemy_level_set(level)
    @enemy_level.unshift(level)
  end
  #--------------------------------------------------------------------------
  # ○ 敵レベルの設定
  #--------------------------------------------------------------------------
  def enemy_level_pop
    @enemy_level.pop
  end
  #--------------------------------------------------------------------------
  # ○ 敵レベルのリセット　※戦闘終了後 自動でリセット
  #--------------------------------------------------------------------------
  def enemy_level_reset
    @enemy_level = []
  end
  #--------------------------------------------------------------------------
  # ○ 敵HPプラス配列の存在判定
  #--------------------------------------------------------------------------
  def enemy_hpp?
    !@enemy_hpp.empty?
  end
  #--------------------------------------------------------------------------
  # ○ 敵HPプラスのセット
  #--------------------------------------------------------------------------
  def enemy_hpp_set(plus)
    @enemy_hpp.unshift(plus)
  end
  #--------------------------------------------------------------------------
  # ○ 敵HPプラスの設定
  #--------------------------------------------------------------------------
  def enemy_hpp_pop
    @enemy_hpp.pop
  end
  #--------------------------------------------------------------------------
  # ○ 敵HPプラスのリセット　※戦闘終了後 自動でリセット
  #--------------------------------------------------------------------------
  def enemy_hpp_reset
    @enemy_hpp = []
  end
  #--------------------------------------------------------------------------
  # ○ イベントバトルアイテムの判定
  #--------------------------------------------------------------------------
  def enemy_item?
    !@enemy_item.empty?
  end
  #--------------------------------------------------------------------------
  # ○ イベントバトルアイテムのセット　※kind　1→アイテム　2→武器　3→防具
  #--------------------------------------------------------------------------
  def enemy_item_set(kind, id)
    @enemy_item.push([kind, id])
  end
  #--------------------------------------------------------------------------
  # ○ イベントバトルアイテムのリセット　※設定したイベント戦闘終了後は必ず指定するように enemy_resetに統一
  #--------------------------------------------------------------------------
  def enemy_item_reset
    @enemy_item = []
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def next_set(exp, gold, ap)
    @next_exp  = exp
    @next_gold = gold
    @next_ap   = ap
  end
  #--------------------------------------------------------------------------
  # ○ のリセット　※設定したイベント戦闘終了後は必ず指定するように enemy_resetに統一
  #--------------------------------------------------------------------------
  def next_reset
    @next_exp  = 0
    @next_gold = 0
    @next_ap   = 0
  end
  #--------------------------------------------------------------------------
  # ○ 難易度設定
  #--------------------------------------------------------------------------
  def difficulty_set(symbol)
    @difficulty = symbol
  end
  #--------------------------------------------------------------------------
  # ○ 難易度設定 ハード
  #--------------------------------------------------------------------------
  def hard_set
    difficulty_set(:hard)
  end
  #--------------------------------------------------------------------------
  # ○ 難易度設定 EXハード
  #--------------------------------------------------------------------------
  def ex_hard_set
    difficulty_set(:ex_hard)
  end
  #--------------------------------------------------------------------------
  # ○ 難易度設定 イージー
  #--------------------------------------------------------------------------
  def easy_set
    difficulty_set(:easy)
  end
  #--------------------------------------------------------------------------
  # ○ 難易度設定 ノーマル(初期設定)
  #--------------------------------------------------------------------------
  def normal_set
    difficulty_set(:normal)
  end
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ○ 戦闘直前の敵レベルの設定
  #--------------------------------------------------------------------------
  def enemy_lv_set(lv)
    $game_system.enemy_level_set(lv)
  end
  #--------------------------------------------------------------------------
  # ○ 戦闘直前の敵HPの設定
  #--------------------------------------------------------------------------
  def enemy_hpp_set(plus)
    $game_system.enemy_hpp_set(plus)
  end
=begin
  #--------------------------------------------------------------------------
  # ○ 敵レベル設定のリセット
  #--------------------------------------------------------------------------
  def enemy_lv_reset
    $game_system.enemy_level_reset
  end
  #--------------------------------------------------------------------------
  # ○ 敵HP設定のリセット
  #--------------------------------------------------------------------------
  def enemy_hpp_reset
    $game_system.enemy_hpp_reset
  end
=end
  #--------------------------------------------------------------------------
  # ○ 戦闘直前のドロップアイテムの設定
  #--------------------------------------------------------------------------
  def enemy_item_set(kind, id)
    $game_system.enemy_item_set(kind, id)
  end
  #--------------------------------------------------------------------------
  # ○ ドロップアイテムのリセット
  #--------------------------------------------------------------------------
  def enemy_item_reset
    $game_system.enemy_item_reset
  end
  #--------------------------------------------------------------------------
  # ○ 経験値系の設定
  #--------------------------------------------------------------------------
  def next_set(exp, gold = 0, ap = 0)
    $game_system.next_set(exp, gold, ap)
  end
  #--------------------------------------------------------------------------
  # ○ 経験値系のリセット
  #--------------------------------------------------------------------------
  def next_reset
    $game_system.next_reset
  end
  #--------------------------------------------------------------------------
  # ○ 敵関係設定のリセット
  #--------------------------------------------------------------------------
  def enemy_reset
    #enemy_lv_reset
    #enemy_hpp_reset
    enemy_item_reset
    next_reset
  end
  #--------------------------------------------------------------------------
  # ○ 難易度設定 ノーマル
  #--------------------------------------------------------------------------
  def normal_mode
    $game_system.normal_set
  end
  #--------------------------------------------------------------------------
  # ○ 難易度設定 ハード
  #--------------------------------------------------------------------------
  def hard_mode
    $game_system.hard_set
  end
  #--------------------------------------------------------------------------
  # ○ 難易度設定 EXハード
  #--------------------------------------------------------------------------
  def ex_hard_mode
    $game_system.ex_hard_set
  end
  #--------------------------------------------------------------------------
  # ○ 難易度設定 イージー
  #--------------------------------------------------------------------------
  def easy_mode
    $game_system.easy_set
  end
end