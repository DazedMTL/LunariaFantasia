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
  
  CHECK_TEXT  = "sb41"
  
  #マップイベントを対象にするか？
  #(trueで対象にする/falseで対象にしない。以下全て同じ)
  
  EV  = true
  
  #コモンイベントを対象にするか？
  
  CEV = false
  
  #「文章の表示」コマンドを対象にするか？
  
  EV1 = false
  
  #「選択肢の表示」コマンドを対象にするか？
  
  EV2 = false
  
  #「文章」のスクロール表示コマンドを対象にするか？
  
  EV3 = false
  
  #「注釈」コマンドを対象にするか？
  
  EV4 = true
  
  #名前を対象にするか？
  
  EV5 = false
  
  def self.checktext
    f = File.open("TextCheck.txt", "w")
    param = CheckText::CHECK_TEXT
    return unless $TEST or $BTEST
    text = "調査文章【" + param + "】" + "\n" + "\n"
    text += "調査日時 " + Time.now.to_s + "\n" + "\n"
    orders_array = {}
    orders_array[401] = "文章の表示" if EV1
    orders_array[102] = "選択肢の表示" if EV2
    orders_array[405] = "文章のスクロール表示" if EV3
    if EV4
      orders_array[108] = "注釈"
      orders_array[408] = "注釈"
      orders_array[355] = "スクリプト"
      orders_array[655] = "スクリプト"
    end
    keys = orders_array.keys
    if EV
      text += "★マップイベント★" + "\n" + "\n"
      $data_mapinfos = load_data("Data/MapInfos.rvdata2")
      999.times {|i|
      map_id = i + 1
      if $data_mapinfos[map_id] != nil
        map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
        map.events.keys.each {|i|
        next unless i
        event = map.events[i]
        if EV5 && event.name.include?(param)
          text += "MAPID " + map_id.to_s + " MAP名 " + $data_mapinfos[map_id].name
          text += " 座標 [" + event.x.to_s + ", " + event.y.to_s + "]"
          text += " イベントID " + event.id.to_s + " イベント名" + "\n" + "\n"
        end
        page_number = 0
        event.pages.each {|page|
        page_number += 1
        page.list.each_with_index {|pld, ec|
        next unless pld
        if keys.include?(pld.code)
          if param_check(pld,param)
            text += "MAPID " + map_id.to_s + " MAP名 " + $data_mapinfos[map_id].name
            text += " 座標 [" + event.x.to_s + ", " + event.y.to_s + "]"
            text += " イベントID " + event.id.to_s + " ページ番号 " + page_number.to_s
            text += " コマンド位置 " + (ec + 1).to_s + " " + orders_array[pld.code] + "\n" + "\n"
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
      if EV5 && cm.name.include?(param)
        text += "コモンイベントID " + cm.id.to_s + " イベント名" + "\n" + "\n"
      end
      cm.list.each_with_index {|pld, ec|
      next unless pld
      if keys.include?(pld.code)
        if param_check(pld,param)
          text += "コモンイベントID " + cm.id.to_s + " コマンド位置 " + (ec + 1).to_s + " " + orders_array[pld.code] + "\n" + "\n"
        end
      end
      }}
    end
    f.write(text)
    f.close
  end
  def self.param_check(pld,param)
    if pld.code == 102
      pld.parameters[0].any? {|i| i.include?(param)}
    else
      pld.parameters[0].include?(param)
    end
  end
end
if $TEST
  CheckText.checktext
  exit
end
=end