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
  
  CHECK_TEXT  = "場所移動"
  CHECK_MAP  = [1,2,3]#*(415..420), 172] # イベントの移動先を調べたいマップIDをいれる
  SEARCH_MAP  = [] # 移動先を指定して調べたい時。こちらは全マップから探索される。こちらに数字がある場合はこちらが優先される
  
  #マップイベントを対象にするか？
  #(trueで対象にする/falseで対象にしない。以下全て同じ)
  
  EV  = true
  
  #コモンイベントを対象にするか？
  
  CEV = false
  
  #「BGMの演奏」コマンドを対象にするか？
  
  EV1 = true
  
  #「コモンイベント」コマンドを対象にするか？
  
  EV2 = false
  
  #「文章」のスクロール表示コマンドを対象にするか？
  
  EV3 = false
  
  #「注釈」コマンドを対象にするか？
  
  EV4 = false
  
  #名前を対象にするか？
  
  EV5 = false
  
  def self.checktext
    f = File.open("MoveCheck.txt", "w")
    param = CheckText::CHECK_TEXT
    return unless $TEST or $BTEST
    text = "調査文章【" + param + "】" + "\n" + "\n"
    text += "調査日時 " + Time.now.to_s + "\n" + "\n"
    orders_array = {}
    if EV1
      orders_array[201] = "場所移動"
    end
    keys = orders_array.keys
    if EV
      text += "★マップイベント★" + "\n" + "\n"
      $data_mapinfos = load_data("Data/MapInfos.rvdata2")
      999.times {|i|
      map_id = i + 1
      if $data_mapinfos[map_id] != nil && !SEARCH_MAP.empty?
        map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
        map.events.keys.each {|i|
        next unless i
        event = map.events[i]
      
        page_number = 0
        event.pages.each {|page|
        page_number += 1
        page.list.each_with_index {|pld, ec|
        next unless pld
        SEARCH_MAP.each do |sm_id|
          if keys.include?(pld.code) && pld.parameters[1] == sm_id
            text += "MAPID " + map_id.to_s + " MAP名 " + $data_mapinfos[map_id].name
            text += " 座標 [" + event.x.to_s + ", " + event.y.to_s + "]"
            text += " イベントID " + event.id.to_s + " ページ番号 " + page_number.to_s
            text += " コマンド位置 " + (ec + 1).to_s + " " + orders_array[pld.code] + " " + $data_mapinfos[pld.parameters[1]].name + "\n" + "\n"
          end
        end
        }}}
      elsif $data_mapinfos[map_id] != nil && CHECK_MAP.include?(map_id)
        map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
        map.events.keys.each {|i|
        next unless i
        event = map.events[i]
        
        page_number = 0
        event.pages.each {|page|
        page_number += 1
        page.list.each_with_index {|pld, ec|
        next unless pld
        if keys.include?(pld.code)
          text += "MAPID " + map_id.to_s + " MAP名 " + $data_mapinfos[map_id].name
          text += " 座標 [" + event.x.to_s + ", " + event.y.to_s + "]"
          text += " イベントID " + event.id.to_s + " ページ番号 " + page_number.to_s
          text += " コマンド位置 " + (ec + 1).to_s + " " + orders_array[pld.code] + " " + $data_mapinfos[pld.parameters[1]].name + "\n" + "\n"
        end
        }}}
      end
      }
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