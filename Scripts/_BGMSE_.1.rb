#==============================================================================
# ■ RGSS3 イベントテキストチェック Ver1.01　by 星潟
#------------------------------------------------------------------------------
# ゲーム中のイベントの文章の表示、選択肢の表示、文章のスクロール表示、注釈、
# 各種名称やメモ欄を参照し、指定文字列が含まれている場所を
# プロジェクトファイル内にテキストファイルで書き出します。
# 
# 誤用や変換ミスに気付いた際に、同様の間違いを洗い出す事が出来るかもしれません。
#==============================================================================
# ★使用方法
#------------------------------------------------------------------------------
# 導入後、下記の設定項目の中から不要な物をfalseに切り替えてテストプレイ実行。
# 実行後にテキストファイルが書き出されると自動的にテストプレイは終了する。
#------------------------------------------------------------------------------
# Ver1.01 マップ名も表示されるように改修しました。
#==============================================================================
=begin
module CheckText
  
  #調べるテキストを指定して下さい。
  #（""で両端を括るのを忘れないように）
  
  CHECK_TEXT  = ""
  
  #調べたいマップ配列　空っぽで全マップ調査
  CHECK_MAP   = [] #[56,239,424,432]
  
  #マップイベントを対象にするか？
  #(trueで対象にする/falseで対象にしない。以下全て同じ)
  
  EV  = true
  
  #コモンイベントを対象にするか？
  
  CEV = true
  
  #「BGMの演奏」コマンドを対象にするか？
  
  EV1 = true
  
  #「BGS」コマンドを対象にするか？
  
  EV2 = false
  
  #「ME」のスクロール表示コマンドを対象にするか？
  
  EV3 = false
  
  #「SE」コマンドを対象にするか？
  
  EV4 = false
  
  #名前を対象にするか？
  
  EV5 = false # 常にfalse
  
  def self.checktext
    f = File.open("EventCheck.txt", "w")
    param = CheckText::CHECK_TEXT
    return unless $TEST or $BTEST
    text = "調査文章【" + param + "】" + "\n" + "\n"
    text += "調査日時 " + Time.now.to_s + "\n" + "\n"
    orders_array = {}
    if EV1
      orders_array[241] = "BGMの演奏"
      orders_array[132] = "戦闘BGM"
    end
    orders_array[245] = "BGSの演奏" if EV2
    if EV3
      orders_array[249] = "MEの演奏"
      orders_array[133] = "戦闘ME"
    end
    if EV4
      orders_array[250] = "SEの演奏"
      orders_array[205] = "移動ルート"
    end
    keys = orders_array.keys
    name_list = []
    if EV
      text += "★マップイベント★" + "\n" + "\n"
      
      $data_system = load_data("Data/System.rvdata2")
      name_list.push($data_system.title_bgm.name) if !name_list.include?($data_system.title_bgm.name) && EV1
      name_list.push($data_system.battle_bgm.name) if !name_list.include?($data_system.battle_bgm.name) && EV1
      name_list.push($data_system.battle_end_me.name) if !name_list.include?($data_system.battle_end_me.name) && EV3
      name_list.push($data_system.gameover_me.name) if !name_list.include?($data_system.gameover_me.name) && EV3
      
      $data_mapinfos = load_data("Data/MapInfos.rvdata2")
      999.times {|i|
      map_id = i + 1
      next if !CHECK_MAP.empty? && !CHECK_MAP.include?(map_id) # 追加
      if $data_mapinfos[map_id] != nil
        map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
        
        if EV1
          if map.autoplay_bgm
            name_list.push(map.bgm.name) if !name_list.include?(map.bgm.name)
          end
          if map.sbgm
            name_list.push(map.sbgm.name) if !name_list.include?(map.sbgm.name)
          end
        end
        if EV2
          if map.autoplay_bgs
            name_list.push(map.bgs.name) if !name_list.include?(map.bgs.name)
          end
          if map.sbgs
            name_list.push(map.sbgs.name) if !name_list.include?(map.sbgs.name)
            text += "MAPID " + map_id.to_s + " MAP名 " + $data_mapinfos[map_id].name
          end
        end
        
        map.events.keys.each {|i|
        next unless i
        event = map.events[i]
        page_number = 0
        event.pages.each {|page|
        page_number += 1
        page.list.each_with_index {|pld, ec|
        next unless pld
        if keys.include?(pld.code)
          if param_check(pld,param)
            name_list.push(pld.parameters[0].name) if !name_list.include?(pld.parameters[0].name)
          elsif pld.code == 205
            pld.parameters[1].list.each do |ld|
              if ld.code == 44
                name_list.push(ld.parameters[0].name) if !name_list.include?(ld.parameters[0].name)
              end
            end
          end
        end
        }}}
      end
      }
    end
    if CEV
      text += "★コモンイベント★" + "\n" + "\n"
      $data_common_events = load_data("Data/CommonEvents.rvdata2")
      $data_common_events.each {|cm|
      next unless cm
      cm.list.each_with_index {|pld, ec|
      next unless pld
      if keys.include?(pld.code)
        if param_check(pld,param)
          name_list.push(pld.parameters[0].name) if !name_list.include?(pld.parameters[0].name)
        elsif pld.code == 205
          pld.parameters[1].list.each do |ld|
            if ld.code == 44
              name_list.push(ld.parameters[0].name) if !name_list.include?(ld.parameters[0].name)
            end
          end
        end
      end
      }}
    end
    
    $data_troops        = load_data("Data/Troops.rvdata2")
    999.times do |i|
      troop_id = i + 1
      if $data_troops[troop_id] != nil
        troop = $data_troops[troop_id]
        
        troop.pages.each do |page|
          page.list.each_with_index do |pld, ec|
            next unless pld
            if keys.include?(pld.code)
              if param_check(pld,param)
                name_list.push(pld.parameters[0].name) if !name_list.include?(pld.parameters[0].name)
              elsif pld.code == 205
                pld.parameters[1].list.each do |ld|
                  if ld.code == 44
                    name_list.push(ld.parameters[0].name) if !name_list.include?(ld.parameters[0].name)
                  end
                end
              end
            end
          end
        end
      end
    end
    
    
    if EV4
      $data_animations    = load_data("Data/Animations.rvdata2")
      999.times {|i|
      anime_id = i + 1
      if $data_animations[anime_id] != nil
        animation = $data_animations[anime_id]
        animation.timings.each do |timing|
          if !timing.se.name.empty?
            name_list.push(timing.se.name) if !name_list.include?(timing.se.name)
          end
        end
      end
      }
    end
    
    name_list.delete("")
    name_list = name_list.sort_by.with_index {|s, i| [s.downcase, i]}#sort{|x, y| x.casecmp(y).nonzero? || x <=> y}
    name_list.each_with_index do |name, i|
      text += "No #{i + 1}" "  #{name}" + "\n" + "\n"
    end
    f.write(text)
    f.close
  end
  def self.param_check(pld,param)
    if pld.code == 102
      pld.parameters[0].any? {|i| i.include?(param)}
    elsif pld.code == 241
      true
      #pld.parameters[0].name.include?(param)
    elsif pld.code == 132
      true
    elsif pld.code == 245
      true
    elsif pld.code == 249
      true
    elsif pld.code == 250
      true
    elsif pld.code == 117
      #pld.parameters[0].name.include?(param)
    else
      false
      #pld.parameters[0].include?(param)
    end
  end
end
if $TEST
  CheckText.checktext
  exit
end
=end