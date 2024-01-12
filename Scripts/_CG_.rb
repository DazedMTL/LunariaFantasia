module FAKEREAL
  #差し替えCGの存在判定。File.exist等で判定すると暗号化した際上手く機能しない為
  #あらかじめ差し替えのあるCGはハッシュの配列に入れておく
  #フタナリ断面図の場合、"DMZ"keyのファイル名の前に "FUTA/" と入れ
  #出産断面の場合 "SAN/"と入れる
  EXIST_CG = {
    "DMZ" =>  [
      "ev_01_03", "ev_01_05", "ev_01_08", "ev_15_04", "ev_15_06", "ev_15_09", 
      "ev_19_01", "ev_19_03", "ev_19_06", "ev_23_12", "ev_23_15", "ev_23_19", "ev_23_20", 
      "ev_24_07", "ev_24_09", "ev_24_12", "ev_29_04", "ev_29_06", "ev_29_09", "ev_29_10", 
      "ev_34_01", "ev_34_02", "ev_34_05", "ev_34_08", "ev_36_04", "ev_36_08", "ev_36_11", 
      "ev_40_03", "ev_40_05", "ev_40_09", "ev_40_11", "ev_42_03", "ev_42_04", "ev_42_07", "ev_42_12", 
      "evex_02_07", "evex_02_11", "evex_02_15", "evex_03_04", "evex_03_06", "evex_03_10", 
      "evex_06_03", "evex_06_05", "evex_06_09", "evex_06_10", 
      "evtr_05_03", "evtr_05_06", "evtr_05_09", "evtr_05_11", "evtr_05_12", 
      "FUTA/ev_33_06", "FUTA/ev_33_08", "FUTA/ev_33_09", 
    ],
    
    "FUTA" => ["ev_33_05", "ev_33_06", "ev_33_08", "ev_33_09"],
    "SAN" =>  ["evtr_06_08", "evtr_06_09", "evtr_06_17", "evtr_06_18", ],
  
  }
  
  #--------------------------------------------------------------------------
  # 〇 断面図CGの存在判定
  #--------------------------------------------------------------------------
  def self.cg_exists?(name, dir = "DMZ")#, ext = "png")
    #p!Dir.glob('Save/Save*.rvdata2').empty?
    #p "Graphics/Pictures/" + dir + name
    #!Dir.glob('Graphics/Pictures/' + dir + name + '*').empty?
    #FileTest.exist?('Graphics/Pictures/' + dir + name + '*')# + ".#{ext}")
    EXIST_CG[dir].include?(name)
  end
  #--------------------------------------------------------------------------
  # 〇 フタナリCGの存在判定
  #--------------------------------------------------------------------------
  def self.futa_cg_exists?(name, dir = "FUTA")#, ext = "png")
    cg_exists?(name, dir)
  end
  #--------------------------------------------------------------------------
  # 〇 出産系CGの存在判定
  #--------------------------------------------------------------------------
  def self.san_cg_exists?(name, dir = "SAN")#, ext = "png")
    cg_exists?(name, dir)
  end


  #--------------------------------------------------------------------------
  # 〇 CGの選定
  #--------------------------------------------------------------------------
  def self.cg_select(name)
    #p !($game_variables[Option::EXH_F] == 2 || $game_switches[Option::EXH_SWF])
    if futa_cg_exists?(name) && !($game_variables[Option::EXH_F] == 2 || $game_switches[Option::EXH_SWF]) #!($game_variables[Option::EXH_F] == 2 || $game_switches[313])
      name = "FUTA/" + name
    elsif san_cg_exists?(name) && !($game_variables[Option::EXH_S] == 2 || $game_switches[Option::EXH_SWS])
      name = "SAN/" + name
    end
    name = "DMZ/" + name if !$game_switches[Option::EXH_D] && cg_exists?(name)
    return name
  end
  
=begin
    name = screen.pictures[number].name
    name = name.gsub(/^DMZ\//) { "" }
    if name =~ /^\w+_\d+?_(\d+?)$/
      sn = $1.to_i + plus
      name = name.gsub(/\d+?$/) { format("%02d",sn) }
      if !$game_switches[Option::EXH_D] && FAKEREAL.cg_exists?(name)
        screen.pictures[number].change("DMZ/" + name)
      else
        screen.pictures[number].change(name)
      end
    end
    
    
    name = "#{@name}_#{format("%02d",@id)}_01"
    name = "DMZ/" + name if !$game_switches[Option::EXH_D] && FAKEREAL.cg_exists?(name)
    
    
    i = 0
    @skip.each {|sn| i += 1 if @command_window.page_index >= sn }
    num = @command_window.page_index + i
    @cg_sprite.bitmap.dispose
    name = "#{@name}_#{format("%02d",@id)}_#{format("%02d",num)}"
    name = "DMZ/" + name if !$game_switches[Option::EXH_D] && FAKEREAL.cg_exists?(name)
    @cg_sprite.bitmap = Cache.picture(name)
  end
=end
end
