#==============================================================================
# ■ Game_SelfSwitches
#------------------------------------------------------------------------------
# 　セルフスイッチを扱うクラスです。組み込みクラス Hash のラッパーです。このク
# ラスのインスタンスは $game_self_switches で参照されます。
#==============================================================================

class Game_SelfSwitches
  #--------------------------------------------------------------------------
  # ● セルフスイッチの取得
  #--------------------------------------------------------------------------
  def delete(check)
    if check.instance_of?(Array)
      p check
      check.each {|id|
        @data.keys.each {|key|
          if key.include?(id)
            p key
            p @data[key]
            #@data.delete(key)
            #p @data[key]
          end
        }
      }
    else
      @data.keys.each {|key|
        if key.include?(check)
          p @data[key]
          @data.delete(key)
          p @data[key]
        end
      }
    end
  end
end
