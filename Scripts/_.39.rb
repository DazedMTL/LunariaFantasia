#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :encount_reset             # エンカウントリセットフラグ
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def count_check
    @encounter_count
  end
  #--------------------------------------------------------------------------
  # ○ 最低エンカウント歩数　※追加
  #--------------------------------------------------------------------------
  def minimum_step
    $game_map.minimum_step
  end
  #--------------------------------------------------------------------------
  # ● 場所移動情報のクリア　※エイリアス
  #--------------------------------------------------------------------------
  alias encount_continue_clear_transfer_info clear_transfer_info
  def clear_transfer_info
    encount_continue_clear_transfer_info
    @old_count = 0
    @encount_reset = false
  end
  #--------------------------------------------------------------------------
  # ● エンカウント カウント作成　　※再定義
  #--------------------------------------------------------------------------
  def make_encounter_count
    @old_count = @encounter_count if @encounter_count
    n = $game_map.encounter_step
    m = minimum_step #最低歩数を取得
    new = m + rand(n) #最低歩数＋エディタ設定歩数
    if @old_count <= 0 || @encount_reset || $game_map.encount_reset?
      @encounter_count = new
    else
      @encounter_count = @old_count #m + rand(n) #最低歩数＋エディタ設定歩数
    end
  end
  #--------------------------------------------------------------------------
  # ○ エンカウント カウント強制作成
  #--------------------------------------------------------------------------
  def forced_encounter_count
    n = $game_map.encounter_step
    m = minimum_step #最低歩数を取得
    @encounter_count = m + rand(n) #最低歩数＋エディタ設定歩数
  end
  #--------------------------------------------------------------------------
  # ● エンカウント進行値の取得　※再定義
  #--------------------------------------------------------------------------
  def encounter_progress_value
    value = $game_map.bush?(@x, @y) ? 2 : 1
    value *= 0.5 if $game_party.encounter_half?
    value *= 0.5 if in_ship?
    value *= (minimum_step / 10)  if $game_party.encounter_rate_up? #追加
    value
  end
  #--------------------------------------------------------------------------
  # ● エンカウント項目の採用可能判定
  #--------------------------------------------------------------------------
  alias aura_encounter_ok? encounter_ok?
  def encounter_ok?(encounter)
    return false if $game_party.weak_no_encount?
    aura_encounter_ok?(encounter)
    #return true if encounter.region_set.empty?
    #return true if encounter.region_set.include?(region_id)
    #return false
  end
  #--------------------------------------------------------------------------
  # ● エンカウントする敵グループの ID を作成　※エイリアス
  #--------------------------------------------------------------------------
  alias make_encounter_troop_id_select make_encounter_troop_id
  def make_encounter_troop_id
    if FAKEREAL::ENCOUNT_TYPE == 0
      make_encounter_troop_id_select
    else
      encounter_list = []
      weight_sum = 0
      true_route = $game_map.note =~ /\<TRモンスター:(\d+)以降\>/ ? ($1.to_i - 1) : 99
      if $game_switches[FAKEREAL::LEVELUP_SWITCHES] && $game_map.encounter_list[true_route]
        $game_map.encounter_list.each_with_index do |encounter, i|
          next if i < true_route
          next unless encounter_ok?(encounter)
          encounter_list.push(encounter)
          weight_sum += encounter.weight
        end
        #p encounter_list
        if weight_sum > 0
          value = rand(weight_sum)
          encounter_list.each do |encounter|
            value -= encounter.weight
            return encounter.troop_id if value < 0
          end
        end
        return 0
      else
        $game_map.encounter_list.each_with_index do |encounter, i|
          break if i == true_route
          next unless encounter_ok?(encounter)
          encounter_list.push(encounter)
          weight_sum += encounter.weight
        end
        #p encounter_list
        if weight_sum > 0
          value = rand(weight_sum)
          encounter_list.each do |encounter|
            value -= encounter.weight
            return encounter.troop_id if value < 0
          end
        end
        return 0
      end
    end
  end
=begin
  #--------------------------------------------------------------------------
  # ● エンカウント項目の採用可能判定
  #--------------------------------------------------------------------------
  alias omit_encounter_ok? encounter_ok?
  def encounter_ok?(encounter)
    if $game_map.omit_region[2].zero?
      return omit_encounter_ok?(encounter)
    else
      return true if encounter.region_set.empty?
      return true if encounter.region_set.include?(region_id)
      return true if !omit_region(encounter.region_set)
      return false
    end
  end
  #--------------------------------------------------------------------------
  # 〇 エンカウント除外項目の採用可能判定
  #--------------------------------------------------------------------------
  def omit_region(region_set)
    return true if region_id != $game_map.omit_region[2]
    flag = false
    j = false
    if $game_map.omit_region[0].include?("s")
      v = $game_map.omit_region[1] == 1
      j = $game_switches[$game_map.omit_region[0].to_i] == v
    elsif $game_map.omit_region[0].include?("v")
      v = $game_map.omit_region[1]
      j = $game_variables[$game_map.omit_region[0].to_i] >= v
    end
    flag = true if j && region_set.include?($game_map.omit_region[2])
    return flag
  end
=end
end

#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　マップ画面の処理を行うクラスです。
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● 場所移動前の処理
  #--------------------------------------------------------------------------
  alias encount_continue_pre_transfer pre_transfer
  def pre_transfer
    $game_player.encount_reset = $game_map.encount_reset? # 移動前マップのリセットフラグ確認
    encount_continue_pre_transfer
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
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  #attr_reader :omit_region             # 
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias encount_continue_setup setup
  def setup(map_id)
    encount_continue_setup(map_id)
    ec_reset_set
    #omit_region_set
  end
  #--------------------------------------------------------------------------
  # ○ マップの最低エンカウント歩数の取得
  #--------------------------------------------------------------------------
  def minimum_step
    return $1.to_i if note =~ /\<最低歩数:(\d+)\>/
    return 60
  end
  #--------------------------------------------------------------------------
  # ○ エンカウントリセットフラグのセット
  #--------------------------------------------------------------------------
  def ec_reset_set
    @encount_reset = encounter_list.empty? ? encount_continue : (note =~ /\<エンカウントリセット\>/ ? true : false)
  end
  #--------------------------------------------------------------------------
  # ○ エンカウントをリセットするか？
  #--------------------------------------------------------------------------
  def encount_reset?
    @encount_reset
  end
  #--------------------------------------------------------------------------
  # ○ エンカウントを継続
  #--------------------------------------------------------------------------
  def encount_continue
    note =~ /\<エンカウント継続\>/ ? false : true
  end
  #--------------------------------------------------------------------------
  # ○ 特定条件下でエンカウントから除外するリスト
  #--------------------------------------------------------------------------
  #def omit_region_set
    #@omit_region = note =~ /\<リスト除外(\w+):(\d+);(\d+)\>/ ? [$1, $2.to_i, $3.to_i] : ["", 0, 0]
  #end
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ○ エンカウントの強制作成　※一部のイベントバトル後に使用
  #--------------------------------------------------------------------------
  def make_encount
    $game_player.forced_encounter_count
  end
end