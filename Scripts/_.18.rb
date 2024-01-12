#==============================================================================
# ■ RGSS3 キャラクター常時回転 Ver1.00 by 星潟
#------------------------------------------------------------------------------
# キャラクターがマップ上で回転します。移動中も回転し続けます。
# この状態では向き固定の状態に関わらず、通常の方法では向きが固定されません。
# なお、プレイヤー（先頭アクター）に設定した場合は
# 四方に向きを変え続ける為、決定キーでの「調べる」が
# 非常に使いづらくなりますが、これは仕様とします。
# 基本的にゲーム内イベント中の演出や、特定のイベントへの付与を想定しています。
#------------------------------------------------------------------------------
# ★イベントに設定する場合
# 
# イベントの名前で下記の様に記述します。
# 
# <回転移動:15>
# 
# これで15カウントごとに向きが変わる設定となります。
#------------------------------------------------------------------------------
# ★アクターにデータベース上で設定する場合（プレイヤーキャラや隊列歩行の仲間キャラに影響します）
#
# アクターのメモ欄で下記の様に記述します。
# 
# <回転移動:10>
# 
# これで10カウントごとに向きが変わる設定となります。
#------------------------------------------------------------------------------
# ★イベントコマンドでアクターの回転設定を変更する場合
#
# イベントコマンドのスクリプトで下記の様に記述します。
# 
# actor_rolling_move(1, 8)
# 
# これでID1番のアクターは8カウントごとに向きが変わる設定となります。
#------------------------------------------------------------------------------
# ★イベントコマンドでパーティ全体の回転設定を一括変更する場合
#
# イベントコマンドのスクリプトで下記の様に記述します。
# 
# party_rolling_move(5)
# 
# これでパーティ全体は8カウントごとに向きが変わる設定となります。
#------------------------------------------------------------------------------
# ★イベントコマンドでプレイヤーやイベントの回転設定を変更する場合
#
# 移動ルートの設定で、スクリプトで下記の様に記述します。
# 
# rolling_speed_set(10)
#------------------------------------------------------------------------------
# ★全ての場合に共通する事として
#   回転移動の設定を0にする事で、回転移動をOFFにする事が出来ます。
#==============================================================================
module ROLLING_MOVE
  
  WORD = "回転移動"
  
end
class Game_CharacterBase
  alias init_private_members_rolling init_private_members
  def init_private_members
    
    #回転移動を初期化。
    
    rolling_speed_set(0)
    
    #回転移動カウントを初期化。
    
    @rolling_count = 0
    
    #本来の処理を実行。
    init_private_members_rolling
  end
  def rolling_speed_set(speed)
    
    #プレイヤーの場合、先頭アクターの回転データを変更する。
    
    if self.is_a?(Game_Player) && self.actor != nil
      
      $game_actors[$game_player.actor.id].rolling_move_change(speed)
      
    end
    
    #回転移動変数を取得。
    
    @rolling_move = speed
    
    #回転移動カウントを初期化。
    
    @rolling_count = 0
    
  end
  alias update_rolling update
  def update
    
    #回転移動のチェック。

    roliing_check
    
    #本来の処理を実行。
    
    update_rolling
    
  end
  alias update_anime_count_rolling update_anime_count
  def update_anime_count
    
    #回転移動変数が設定されている場合は回転移動カウントを加算。
    
    if @rolling_move > 0
      
      @rolling_count += 1
    
      #回転移動カウントが回転移動変数以上になった時、向きを強制変更する。
      
      if @rolling_count >= @rolling_move
        case @direction
        when 2
          @direction = 4
        when 4
          @direction = 8
        when 6
          @direction = 2
        when 8
          @direction = 6
        end
        @rolling_count = 0
      end
    end
    
    #本来の処理を実行。
    
    update_anime_count_rolling
  end
  def roliing_check
    
    #回転移動データがnilの場合、初期化する。
    
    if @rolling_move == nil
      
      @rolling_move = 0
      
      @rolling_count = 0
      
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 指定方向に向き変更
  #     d : 方向（2,4,6,8）
  #--------------------------------------------------------------------------
  alias set_direction_rolling set_direction
  def set_direction(d)
    
    #回転変数が設定されている場合は通常の向き変更は行わない。
    
    set_direction_rolling(d) if @rolling_move == 0
    
  end
end
class Game_Event < Game_Character
  alias initialize_rolling initialize
  def initialize(map_id, event)
    
    #本来の処理を実行。
    
    initialize_rolling(map_id, event)
    
    #回転移動データ取得。
    
    first_rolling_speed_set
    
  end
  def first_rolling_speed_set
    
    #回転移動データ取得。
    
    memo = @event.name.scan(/<#{ROLLING_MOVE::WORD}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @rolling_move = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
  end
end
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  alias refresh_rolling refresh
  def refresh
    
    #本来の処理を実行する。
    
    refresh_rolling
    
    #アクターの回転変数を反映する。
    
    @rolling_move = actor ? actor.rolling_move : 0
  end
end
class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  alias refresh_rolling refresh
  def refresh
    
    #本来の処理を実行する。
    
    refresh_rolling
    
    #可視状態とアクターの回転変数を反映する。
    
    @rolling_move = visible? ? actor.rolling_move : 0
  end
end
class Game_Actor < Game_Battler
  def rolling_move
    
    #回転変数がnilではない場合はキャッシュデータを返す。
    
    return @rolling_move if @rolling_move != nil
    
    memo = $data_actors[@actor_id].note.scan(/<#{ROLLING_MOVE::WORD}[：:](\S+)>/).flatten
    
    #データを取得出来無かった場合は0に設定する。
    
    @rolling_move = (memo != nil && !memo.empty?) ? memo[0].to_i : 0
    
    #回転変数を返す。
    
    return @rolling_move
    
  end
  def rolling_move_change(data)
    
    #回転変数を設定する。
    
    @rolling_move = data
    
    #プレイヤーを更新する。
    
    $game_player.refresh if $game_party.members.include?($game_actors[@actor_id])
    
  end
end
class Game_Interpreter
  def actor_rolling_move(actor_id, data)
    
    #アクターへの命令に書き換える。
    
    $game_actors[actor_id].rolling_move_change(data)
    
  end
  def party_rolling_move(data)
    
    return if $game_party.members.size == 0
    
    #アクターへの命令に書き換える。
    
    $game_party.members.each do |actor|
      $game_actors[actor.id].rolling_move_change(data)
    end
    
  end
end