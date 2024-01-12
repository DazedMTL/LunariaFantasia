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
  
  EV4 = false
  
  #名前を対象にするか？
  
  EV5 = false
  
  def self.checktext
    f = File.open("AnimeCheck.txt", "w")
    param = CheckText::CHECK_TEXT
    return unless $TEST or $BTEST
    text = "調査文章【" + param + "】" + "\n" + "\n"
    text += "調査日時 " + Time.now.to_s + "\n" + "\n"
    if EV
      text += "★アニメーションSE★" + "\n" + "\n"
      $data_animations    = load_data("Data/Animations.rvdata2")
      999.times {|i|
      anime_id = i + 1
      if $data_animations[anime_id] != nil
        animation = $data_animations[anime_id]
        animation.timings.each do |timing|
          if !timing.se.name.empty?
            text += "アニメID #{animation.id}" + " " + animation.name
            text += " フレーム #{timing.frame + 1} " + " SE名 " + timing.se.name + "\n" + "\n"
          end
        end
      end
      }
    end
    f.write(text)
    f.close
  end
end
if $TEST
  CheckText.checktext
  exit
end
=end