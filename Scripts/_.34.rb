#==============================================================================
# ■ RGSS3 盗む＆敵をアイテムに変化させるスキル Ver1.03　by 星潟
#------------------------------------------------------------------------------
# 敵からアイテムを盗むスキルを作成する事が出来るようになります。
# 盗めるアイテムは敵にそれぞれ設定します。（設定数無制限）
# また、敵をアイテムに変えた上で
# 消滅（HP0 or 隠れる状態）させるスキルも作成可能になります。
#------------------------------------------------------------------------------
# ★アイテムを盗む場合
#------------------------------------------------------------------------------
# 　☆敵に盗めるアイテムと盗める確率を設定する。
# 　　
# 　　複数設定できます。
# 　　（設定しない場合は盗めません）
# 　　
# 　　敵のメモ欄に下記の様に記入。
# 　　
# 　　<アイテムスティール:0,1,50>
# 
# 　　この場合、この敵からはアイテムID1番を優先度50で盗みます。
# 　　
# 　　<アイテムスティール:1,3,25>
# 
# 　　この場合、この敵からは武器ID3番を優先度25で盗みます。
# 　　
# 　　<アイテムスティール:2,5,15>
# 
# 　　この場合、この敵からは防具ID5番を優先度15で盗みます。
# 　　
# 　　<アイテムスティール:3,500,10>
# 　　
# 　　この場合、この敵からは500G（お金）を優先度10で盗みます。
#
#　　 その敵に設定された盗めるアイテムの優先度の高さに応じて
#     盗めるアイテムが決定されます。
#　　 （高いほど盗んだアイテムに設定されやすい）
#------------------------------------------------------------------------------
# 　☆敵からアイテムを盗むスキルを作成する。
# 　　
# 　　アイテム/スキルのメモ欄に下記の様に記入。
# 　　
# 　　<アイテムスティール:50>
# 　　
# 　　この場合、50％の確率で盗むを成功させます。
# 　　
# 　　<アイテムスティール:a.agi-b.agi>
# 　　
# 　　この場合、こちらの敏捷性から相手の敏捷性を引いた値で盗めます。
# 　　
# 　　<アイテムスティール:a.element_rate(16)*100-50>
# 　　
# 　　この場合、自分の属性ID16の有効度から50を引いた値で盗めます。
#------------------------------------------------------------------------------
# ★敵をアイテムに変化させる場合
#------------------------------------------------------------------------------
# 　☆敵に変化スキル使用時に変化するアイテムを設定する。
# 　　
# 　　複数設定できます。
# 　　（設定しない場合は変化が起きません）
# 　　
# 　　敵のメモ欄に下記の様に記入。
# 　　
# 　　<アイテム変化:0,1,50>
# 
# 　　この場合、この敵は優先度50でアイテムID1番に変化します。
# 　　
# 　　<アイテム変化:1,3,25>
# 
# 　　この場合、この敵は優先度25で武器ID3番に変化します。
# 　　
# 　　<アイテム変化:2,5,15>
# 　　
# 　　この場合、この敵は優先度15で防具ID5番に変化します。
# 　　
# 　　<アイテム変化:3,500,10>
# 　　
# 　　この場合、この敵は優先度10で500G（お金）に変化します。
#
#　　 その敵に設定されたアイテム変化の優先度の高さに応じて
#     アイテム変化時のアイテムが決定されます。
#　　 （高いほどアイテム変化時のアイテムに設定されやすい）
#------------------------------------------------------------------------------
# 　☆敵をアイテムに変化させるスキルを作成する。
# 　　
# 　　アイテム/スキルのメモ欄に下記の様に記入。
# 　　
# 　　<アイテム変化:50>
# 　　
# 　　この場合、50％の確率で変化を成功させます。
# 　　
# 　　<アイテム変化:a.agi-b.agi>
# 　　
# 　　この場合、こちらの敏捷性から相手の敏捷性を引いた値で変化を成功させます。
# 　　
# 　　<アイテム変化:a.element_rate(16)*100-50>
# 　　
# 　　この場合、自分の属性ID16の有効度から50を引いた値で変化を成功させます。
#------------------------------------------------------------------------------
# Ver1.01 スキル使用時の判定ミスを修正。
# Ver1.02 スキル使用時の判定ミスを再修正。
#==============================================================================
module ENEMY_IC
  
  #敵側に盗むアイテムを指定する為のキーワードを設定します。
  
  WORD1 = "アイテムスティール"
  
  #スキルに盗む効果を設定する為のキーワードを設定します。
  
  WORD2 = "アイテムスティール"
  
  #敵側にアイテム変化を指定する為のキーワードを設定します。
  
  WORD3 = "アイテム変化"
  
  #スキルにアイテム変化効果を設定する為のキーワードを設定します。
  
  WORD4 = "アイテム変化"
  
  #敵が盗めるアイテムを持っており、なおかつ
  #スキルの盗む確率を満たせなかった場合の
  #バトルログへ表示するメッセージを指定。
  
  FMT_1 = "%sから盗めなかった！"
  
  #既にアイテムを盗んでいるか、敵が元々盗めるアイテムを所持していない場合の
  #バトルログへ表示するメッセージを指定。
  
  FMT_2 = "%sは盗めるような物を持っていない！"
  
  #敵からアイテムを盗めた場合のメッセージを指定。
  
  FMT_3 = "%sから%sを盗んだ！"
  
  #敵にアイテム変化が有効であり、なおかつ
  #スキルのアイテム変化率を満たせなかった場合の
  #バトルログへ表示するメッセージを指定。
  
  FMT_4 = "%sの変化に失敗した！"
  
  #元々変化アイテムが設定されていない場合の
  #バトルログへ表示するメッセージを指定。
  
  FMT_5 = "%sは変化させる事が出来ない！"
  
  #敵をアイテム変化できた場合のメッセージを指定。
  
  FMT_6 = "%sを%sに変化させた！"
  
  #アイテム変化に成功した際に敵を隠れさせて戦闘から除外するか？
  #（隠れさせる場合は、戦闘勝利時に
  #　その敵からは経験値やドロップアイテムが発生しない）
  
  ICHDN = true
  
  #盗むが成功した際にSEを鳴らすかどうかを設定します。
  
  STSE1 = true
  
  #盗むが成功した際のSEを指定します。
  
  STSE2 = ['Item3', 80, 100]
  
  #アイテム変化が成功した際にSEを鳴らすかどうかを設定します。
  
  ICSE1 = true
  
  #アイテム変化が成功した際のSEを指定します。
  
  ICSE2 = ['Saint9', 60, 100]
  
end
class RPG::Enemy < RPG::BaseItem
  #--------------------------------------------------------------------------
  # 盗めるアイテムの一覧
  #--------------------------------------------------------------------------
  def item_steal_list(base_level, list = false)
    
    #キャッシュがあればキャッシュを返す。
    
    @item_steal_list ||= create_item_steal_list
    return @item_steal_list if list
    list_select(@item_steal_list, base_level)
    
  end
  #--------------------------------------------------------------------------
  # 盗めるアイテムの一覧を生成
  #--------------------------------------------------------------------------
  def create_item_steal_list
    
    #空の配列を作成。
    
    #r = []
    r = {}
    
    #メモ欄から一覧にデータを追加。
    self.note.each_line {|l|
      next unless /<#{ENEMY_IC::WORD1}[:：](\d+),(\d+),(\d+),?l?v?(\d*?)>/ =~ l
      lv = $4.empty? ? @base_level : $4.to_i
      r[lv] ||= []
      a = [$1.to_i,$2.to_i,$3.to_i]
      r[lv].push(a) if a.any? {|i| i > 0}
    }
    
    #改造 
    r.keys.each {|k| r[k].sort!{|a,b| a[2] <=> b[2] }}
    
    #データを返す。
    r
    
  end
  #--------------------------------------------------------------------------
  # 変化するアイテムの一覧
  #--------------------------------------------------------------------------
  def item_change_list
    
    #キャッシュがあればキャッシュを返す。
    
    @item_change_list ||= create_item_change_list
    
  end
  #--------------------------------------------------------------------------
  # 変化するアイテムの一覧を生成
  #--------------------------------------------------------------------------
  def create_item_change_list
    
    #空の配列を作成。
    
    r = []
    
    #メモ欄から一覧にデータを追加。
    
    self.note.each_line {|l|
    next unless /<#{ENEMY_IC::WORD3}[:：](\d+),(\d+),(\d+)>/ =~ l
    a = [$1.to_i,$2.to_i,$3.to_i]
    r.push(a) if a.any? {|i| i > 0}}
    
    #データを返す。
    
    r
    
  end
end
class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def change_formula_s(formula)
    
    #formula.gsub!("st_r")   { "a.element_rate(11)+(a.agi-b.agi)/4+(a.luk-b.luk)/8" }
    formula.gsub!("st_r")   { "a.element_rate(11)+a.agi/20+a.luk/40" }
    return formula
  end
  #--------------------------------------------------------------------------
  # 敵から盗む確率を設定
  #--------------------------------------------------------------------------
  def enemy_issp
    
    #キャッシュがあればキャッシュを返す。
    
    @enemy_issp ||= /<#{ENEMY_IC::WORD2}[:：](\S+)>/ =~ note ? $1.to_s : "0"
    
  end
  #--------------------------------------------------------------------------
  # 盗む確率の計算を実行 a.element_rate(11)+(a.agi-b.agi)/4+(a.luk-b.luk)/8
  #--------------------------------------------------------------------------
  def item_steal_eval(a, b, v)
    
    #ダメージ計算の処理を元にして計算。
    
    #[Kernel.eval(enemy_issp), 0].max rescue 0
    
    form_result = change_formula_s(enemy_issp)
    [Kernel.eval(form_result), 0].max rescue 0
  end
  #--------------------------------------------------------------------------
  # 敵をアイテム変化させる確率を設定
  #--------------------------------------------------------------------------
  def enemy_icsp
    
    #キャッシュがあればキャッシュを返す。
    
    @enemy_icsp ||= /<#{ENEMY_IC::WORD4}[:：](\S+)>/ =~ note ? $1.to_s : "0"
  end
  #--------------------------------------------------------------------------
  # 敵のアイテム変化確率の計算を実行
  #--------------------------------------------------------------------------
  def item_change_eval(a, b, v)
    
    #ダメージ計算の処理を元にして計算。
    
    [Kernel.eval(enemy_icsp), 0].max rescue 0
    
  end
end
class Game_Temp
    
  #盗んだ物/変化させたアイテムの一時データを保持しておく。
    
  attr_accessor :enemy_steal_item
  attr_accessor :enemy_change_item
  
end
class Game_ActionResult
  
  #盗むの結果/アイテム変化の結果を一時データを取得できるようにしておく。
  
  attr_accessor :item_steal_successed
  attr_accessor :item_change_successed
  
  #--------------------------------------------------------------------------
  # ステータス効果のクリア
  #--------------------------------------------------------------------------
  alias clear_status_effects_enemy_ic clear_status_effects
  def clear_status_effects
    
    #本来の処理を実行。
    
    clear_status_effects_enemy_ic
    
    #盗むの結果/アイテム変化の結果をクリア。
    
    @item_steal_successed = -1
    @item_change_successed = -1
  end
end
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # 盗めるアイテムの一覧（アクター用ダミー）
  #--------------------------------------------------------------------------
  def item_steal_list
    []
  end
  #--------------------------------------------------------------------------
  # 変化アイテムの一覧（アクター用ダミー）
  #--------------------------------------------------------------------------
  def item_change_list
    []
  end
end
class Game_Enemy < Game_Battler
  attr_accessor :stealed
  #--------------------------------------------------------------------------
  # 盗めるアイテムの一覧
  #--------------------------------------------------------------------------
  def item_steal_list
    
    #既に盗んでいる場合は空の配列、まだの場合は本来の配列を返す。
    
    @stealed != nil ? [] : enemy.item_steal_list(@base_level)
  end
  #--------------------------------------------------------------------------
  # 変化アイテムの一覧
  #--------------------------------------------------------------------------
  def item_change_list
    
    #変化アイテムの配列を返す。
    
    enemy.item_change_list
  end
  #--------------------------------------------------------------------------
  # 変身
  #--------------------------------------------------------------------------
  alias transform_enemy_ic_is transform
  def transform(enemy_id)
    
    #本来の処理を実行
    
    transform_enemy_ic_is(enemy_id)
    
    #盗むフラグとアイテム変化フラグを消去する。
    
    @stealed = nil
    
  end
end
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # アイテム使用テストを実行
  #--------------------------------------------------------------------------
  alias item_test_enemy_ic_is item_test
  def item_test(user, item)
    
    #盗む効果がついているか、アイテム変化の効果がついている場合はtrueを返し
    #そうでない場合は、本来の処理結果を返す。
    
    (item.enemy_issp != "0" or item.enemy_icsp != "0") && !dead? ? true : item_test_enemy_ic_is(user, item)
    
  end
  #--------------------------------------------------------------------------
  # アイテム効果の適用
  #--------------------------------------------------------------------------
  alias item_apply_enemy_ic item_apply
  def item_apply(user, item)
    
    #本来の処理を実行する。
    
    item_apply_enemy_ic(user, item)
    
    #命中していない場合は処理を中断する。
    
    return if !@result.hit?
    
    #盗む効果とアイテム変化の効果が発生しうる場合は判定を行う。
    
    enemy_item_steal_execute(user, item) if item.enemy_issp != "0"
    enemy_item_change_execute(user, item) if item.enemy_icsp != "0"
  end
  #--------------------------------------------------------------------------
  # 盗むの実行
  #--------------------------------------------------------------------------
  def enemy_item_steal_execute(user, item)
    
    #スキルの使用成功フラグを立てておく。
    
    @result.success = true
    
    #成功確率を計算する。
    
    rate_data = item.item_steal_eval(user, self, $game_variables)
    
    #盗めるアイテムの一覧が空の場合は1、
    #盗むが失敗した場合は0を結果とし、処理を中断する。
    
    return @result.item_steal_successed = 1 if item_steal_list.empty?
    return @result.item_steal_successed = 0 if rand(100) >= rate_data
    
    #盗むに成功した場合は2を結果とする。
    
    @result.item_steal_successed = 2
    
    #アイテムデータを用意する。
    #初期状態はnil。
    
    data = nil
    
    #優先度取得用のデータを作成。
    
    item_rate = 0
    
    #各項目の優先度を足す。
    
    item_steal_list.each {|is_data|
    item_rate += is_data[2]
    }
    
    #各項目の優先度の合計値から乱数でデータを決定。
    
    item_rate = rand(item_rate)
    
    #各項目を順番に判定し、入手アイテムを決定。
    
    item_steal_list.each {|is_data|
    
    #該当項目の優先度を乱数から引く。
    
    item_rate -= is_data[2]
    
    #優先度を引いた時、0以下となっている場合は
    #そのアイテムを入手アイテムとして決定する。
    
    if item_rate < 0
      data = is_data
      break
    end
    }
    
    #アイテムの種類からアイテムオブジェクトを取得する。
    
    case data[0]
    when 0;item = $data_items[data[1]]
    when 1;item = $data_weapons[data[1]]
    when 2;item = $data_armors[data[1]]
    when 3;item = data[1].to_s
    end
    
    #盗んだアイテムとしてアイテムオブジェクトを指定。
    
    $game_temp.enemy_steal_item = item
    
    #アイテムオブジェクトが文字列(お金)の場合はお金、そうでない場合はアイテムを入手。
    
    item.is_a?(String) ? $game_party.gain_gold(item.to_i) : $game_party.gain_item(item, 1)
    self.stealed = true
  end
  #--------------------------------------------------------------------------
  # アイテム変化の実行
  #--------------------------------------------------------------------------
  def enemy_item_change_execute(user, item)
    
    #スキルの使用成功フラグを立てておく。
    
    @result.success = true
    
    #成功確率を計算する。
    
    rate_data = item.item_change_eval(user, self, $game_variables)
    
    #アイテム変化の一覧が空の場合は1、
    #アイテム変化が失敗した場合は0を結果とし、処理を中断する。
    
    return @result.item_change_successed = 1 if item_change_list.empty?
    return @result.item_change_successed = 0 if rand(100) >= rate_data
    
    #アイテム変化に成功した場合は結果を2とする。
    
    @result.item_change_successed = 2
    
    #アイテムデータを用意する。
    #初期状態はnil。
    
    data = nil
    
    #優先度取得用のデータを作成。
    
    item_rate = 0
    item_change_list.each {|ic_data|
    item_rate += ic_data[2]
    }
    
    #各項目の優先度の合計値から乱数でデータを決定。
    
    item_rate = rand(item_rate)
    
    #各項目を順番に判定し、入手アイテムを決定。
    
    item_change_list.each {|ic_data|
    
    #該当項目の優先度を乱数から引く。
    
    item_rate -= ic_data[2]
    
    #優先度を引いた時、0以下となっている場合は
    #そのアイテムを入手アイテムとして決定する。
    
    if item_rate < 0
      data = ic_data
      break
    end
    }
    
    #アイテムの種類からアイテムオブジェクトを取得する。
    
    case data[0]
    when 0;item = $data_items[data[1]]
    when 1;item = $data_weapons[data[1]]
    when 2;item = $data_armors[data[1]]
    when 3;item = data[1].to_s
    end
    
    #変化アイテムとしてアイテムオブジェクトを指定。
    
    $game_temp.enemy_change_item = item
    
    #アイテムオブジェクトが文字列(お金)の場合はお金、そうでない場合はアイテムを入手。
    
    item.is_a?(String) ? $game_party.gain_gold(item.to_i) : $game_party.gain_item(item, 1)
    
    #敵のHPを0にする。
    
    @hp = 0
  end
end
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # 影響を受けたステータスの表示
  #--------------------------------------------------------------------------
  alias display_affected_status_item_steal_change display_affected_status
  def display_affected_status(target, item)
    
    #盗むの成功フラグが0以上の場合は表示を行う。
    
    if target.result.item_steal_successed >= 0
      add_text("") if line_number < max_line_number
      display_item_steal(target)
      back_one if last_text.empty?
    end
    
    #アイテム変化の成功フラグが0以上の場合は表示を行う。
    
    if target.result.item_change_successed >= 0
      add_text("") if line_number < max_line_number
      display_item_change(target)
      back_one if last_text.empty?
    end
    
    #本来の処理を実行。
    
    display_affected_status_item_steal_change(target, item)
  end
  #--------------------------------------------------------------------------
  # 盗むの表示
  #--------------------------------------------------------------------------
  def display_item_steal(target)
    
    #成功フラグに応じて分岐。
    
    case target.result.item_steal_successed
    when 0#盗めなかった場合
      fmt = ENEMY_IC::FMT_1
      replace_text(sprintf(fmt, target.name))
    when 1#盗めるアイテムが存在しない場合
      fmt = ENEMY_IC::FMT_2
      replace_text(sprintf(fmt, target.name))
    when 2#盗むに成功した場合
      RPG::SE.new(ENEMY_IC::STSE2[0],ENEMY_IC::STSE2[1],ENEMY_IC::STSE2[2]).play if ENEMY_IC::STSE1
      fmt = ENEMY_IC::FMT_3
      replace_text(sprintf(fmt, target.name, $game_temp.enemy_steal_item.is_a?(String) ? $game_temp.enemy_steal_item + Vocab.currency_unit : $game_temp.enemy_steal_item.name))
      
      #盗んだアイテムの一時データを消去する。
      
      $game_temp.enemy_steal_item = nil
    end
    wait
  end
  #--------------------------------------------------------------------------
  # アイテム変化の表示
  #--------------------------------------------------------------------------
  def display_item_change(target)
    
    #成功フラグに応じて分岐。
    
    case target.result.item_change_successed
    when 0#変化に失敗した場合
      fmt = ENEMY_IC::FMT_4
      replace_text(sprintf(fmt, target.name))
    when 1#盗めるアイテムが存在しない場合
      fmt = ENEMY_IC::FMT_5
      replace_text(sprintf(fmt, target.name))
    when 2#盗むに成功した場合
      RPG::SE.new(ENEMY_IC::ICSE2[0],ENEMY_IC::ICSE2[1],ENEMY_IC::ICSE2[2]).play if ENEMY_IC::ICSE1
      fmt = ENEMY_IC::FMT_6
      replace_text(sprintf(fmt, target.name, $game_temp.enemy_change_item.is_a?(String) ? $game_temp.enemy_change_item + Vocab.currency_unit : $game_temp.enemy_change_item.name))
      
      #アイテム変化の一時データを消去する。
      
      $game_temp.enemy_change_item = nil
      
      #ターゲットの変化済みフラグを立てる。
      
      target.hide if ENEMY_IC::ICHDN
    end
    wait
  end
end