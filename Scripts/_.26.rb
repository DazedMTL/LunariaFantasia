#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　イベントを扱うクラスです。条件判定によるイベントページ切り替えや、並列処理
# イベント実行などの機能を持っており、Game_Map クラスの内部で使用されます。
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● イベントページの条件合致判定　※エイリアス
  #--------------------------------------------------------------------------
  alias extra_conditions_met? conditions_met?
  def conditions_met?(page)
    if extra_conditions_met?(page)
      l = page.list
      if l[0].code == 108
        params = []
        index = 1
        while l[index].code == 408 || l[index].code == 108
          text = l[index].parameters[0]
          break if text == "end"
          params.push(text) if !text.empty?
          index += 1
        end
        return notes_valid(l[0].parameters[0], params)
      end
      return true
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def notes_valid(param, params)
    return true if params.empty?
    case param
    when "条件判定式"
      params.all? do |formula|
        begin
          Kernel.eval(formula)
        rescue
          true
        end
      end
    else
      return true
    end
  end
end


module FRCM
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def self.cos_check(cos, a_id = 1)
    $game_actors[a_id].costume == format("%02d",cos)
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def self.sex_check(type, id = 1)
    case type
    when "s" ; return $game_actors[id].sex
    when "c" ; return $game_actors[id].creampie
    when "f" ; return $game_actors[id].fellatio
    when "p" ; return $game_actors[id].paizuri
    when "a" ; return $game_actors[id].anal
    when "h" ; return $game_actors[id].harassment
    when "k" ; return $game_actors[id].kiss
    when "t" ; return $game_actors[id].tekoki
    when "b" ; return $game_actors[id].bukkake
    when "e" ; return $game_actors[id].ecstasy
    when "d" ; return $game_actors[id].drink
    when "o" ; return $game_actors[id].onanie
    else     ; return 0
    end
  end
  #--------------------------------------------------------------------------
  # 〇 
  #--------------------------------------------------------------------------
  def self.route_check(id)
    case id
    # 1はフォリア遺跡最深部での分岐判定 これがtrueなら守護者と対決
    when 1 ; return !$game_switches[201] && ($game_switches[211] || $game_variables[FAKEREAL::SEX_POINT] < 50)
    # 2はカマラ戦敗北後の判定　これがtrueならレノイベント有り
    when 2 ; return $game_switches[201] && $game_switches[207]
    # 3は魔法陣起動可能かの判定。これがtrueならバッドエンドルートへ
    when 3 ; return $game_switches[208] && $game_variables[FAKEREAL::SEX_POINT] >= 100 && $game_variables[FAKEREAL::LIBERATE] == 100
    else   ; return true
    end
  end
  #--------------------------------------------------------------------------
  # ○ 他所のセルフスイッチのチェック
  #--------------------------------------------------------------------------
  def self.ss_check(m_id, e_id, s_type = "A")
    m_id = $game_map.map_id if m_id == 0 # 0を指定すると現在のマップIDになる
    key = [m_id, e_id, s_type]
    return $game_self_switches[key]
  end
  #--------------------------------------------------------------------------
  # 〇 追加イベントが実装されたかチェック
  #--------------------------------------------------------------------------
  def self.add_check(ev_id)
    FAKEREAL::ADD_EVENT.include?(ev_id)
  end
end