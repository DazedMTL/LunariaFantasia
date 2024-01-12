#module FAKEREAL
  
  #EX_DROP = "ドロップ変更"
  
#end

class RPG::Enemy < RPG::BaseItem
=begin
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def ex_drop_items(base_level)
    @ex_drop_items ||= ex_drop_items_set
  end
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def ex_drop_items_set
    r = {}
    self.note.each_line {|l|
      next unless /<#{FAKEREAL::EX_DROP}[:：](\d+),(\d+),(\d+),?l?v?(\d*?)>/ =~ l
      lv = $4.empty? ? @base_level : $4.to_i
      r[lv] ||= []
      a = [$1.to_i,$2.to_i,$3.to_i]
      r[lv].push(a) if a.any? {|i| i > 0}
    }
    r.keys.each {|k| r[k].sort!{|a,b| a[2] <=> b[2] }}
    r
  end
=end
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def item_steal_total(base_level)
    @item_steal_total ||= item_steal_total_set
    lv = level_select(@item_steal_total.keys, base_level)
    @item_steal_total[lv] ? @item_steal_total[lv] : 0
  end
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def item_steal_total_set
    t = {}
    keys = self.item_steal_list(@base_level, true).keys
    keys.each {|k| t[k] = 0 }
    keys.each {|k| self.item_steal_list(@base_level, true)[k].each{|l| t[k] += l[2] } }
    return t
  end
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def list_select(list, level)
    list[level_select(list.keys, level)] ? list[level_select(list.keys, level)] : []
    #if list[level]
      #list[level]
    #else
      #key = list.keys.delete_if {|k| k > level }
      #list[key[-1]]
    #end
  end
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def level_select(keys, level)
    if keys.include?(level)
      level
    else
      key = keys.delete_if {|k| k > level }
      key[-1]
    end
  end
end
