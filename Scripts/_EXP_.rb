#==============================================================================
# ■ RGSS3 レベル依存EXP補正 Ver1.01　by 星潟
#------------------------------------------------------------------------------
# 各職業のEXP設定をレベル依存で更に変更します。
# EXP計算方法は説明が多少厄介なので割愛します。
#------------------------------------------------------------------------------
# ★設定例（レベル依存でなく無条件で設定値を変える場合）
#------------------------------------------------------------------------------
# 職業のメモ欄に設定します。
# <EXP補正:0,10>
#
#  無条件で基本値を+10する。
#------------------------------------------------------------------------------
# <EXP補正:1,15>
#
#  無条件で補正値を+15する。
#------------------------------------------------------------------------------
# <EXP補正:2,20>
#
#  無条件で増加値Aを+20する。
#------------------------------------------------------------------------------
# <EXP補正:3,25>
#
#  無条件で増加値Bを+25する。
#------------------------------------------------------------------------------
# <EXP補正:4,1000>
#
#  無条件で要求EXP計算結果を+1000する。
#------------------------------------------------------------------------------
# ★設定例（レベル依存の条件で設定値を変える場合）
#------------------------------------------------------------------------------
# <EXP補正:0,1,4>
#
#  次のレベルが4以上の時、基本値を+1する。
#------------------------------------------------------------------------------
# <EXP補正:1,3,5>
#
#  次のレベルが5以上の時、補正値を+3する。
#------------------------------------------------------------------------------
# <EXP補正:2,20,10>
#
#  次のレベルが10以上の場合、増加値Aを+20する。
#------------------------------------------------------------------------------
# <EXP補正:3,25,50>
#
#  次のレベルが50以上の場合、増加値Bを+25する。
#------------------------------------------------------------------------------
# <EXP補正:4,10000000,75>
#
#  次のレベルが75以上の場合、要求EXP計算結果を+10000000する。
#------------------------------------------------------------------------------
# ★EXP確認方法
#------------------------------------------------------------------------------
# テストプレイ中、コンソールウィンドウがある状態であれば
# イベントコマンドのスクリプトで以下の物を実行すれば確認できます。
#------------------------------------------------------------------------------
# ex_exp_check(1)
#
#  職業ID1のレベル1～レベル99全ての必要EXPを
#  コンソールウィンドウに表示する。
#------------------------------------------------------------------------------
# ex_exp_check(5, 10)
#
#  職業ID5のレベル10への必要EXP（レベル9から10に必要なEXP）を
#  コンソールウィンドウに表示する。
#------------------------------------------------------------------------------
# Ver1.00a 説明文の致命的なミスを修正。
#------------------------------------------------------------------------------
# Ver1.01 不具合修正。
#==============================================================================
module EXP_RATE_PLUS
  
  WORD = "EXP補正"
  
end
class RPG::Class < RPG::BaseItem
  alias exp_for_level_exp_rate_plus exp_for_level unless $!
  def exp_for_level(level)
    
    #EXPデータを保存しておく。
      
    base_exp_rate = @exp_params.clone
    
    #基本値追加補正。
    
    @exp_params[0] += extra_exp_params_eval(0, level)
    
    #追加値追加補正。
    
    @exp_params[1] += extra_exp_params_eval(1, level)
    
    #増加度A追加補正。
    
    @exp_params[2] += extra_exp_params_eval(2, level)
    
    #増加度B追加補正。
    
    @exp_params[3] += extra_exp_params_eval(3, level)
    
    #基本計算。
    
    data = exp_for_level_exp_rate_plus(level)
    
    #計算結果に特殊補正を加算。
    
    data += extra_exp_params_eval(4, level)
    
    #EXPデータを保存データに差し戻す。
    
    @exp_params = base_exp_rate
    
    #計算結果を返す。
    
    return data
  end
  def extra_exp_params_eval(type, level)
    
    #データを初期化する。
    
    data = 0
    
    #タイプ別の追加補正配列を取得。
    
    eval_data = extra_exp_params[type]
    
    #追加補正配列別に条件を満たす場合は値を計算する。
    
    return data if eval_data.empty?
    
    #データを計算。
    
    eval_data.each {|ed|
    
    #タイプ4の場合はレベル毎の加算となる為
    #何回分足すかをカウントする。
    
    number = (type == 4 && level >= ed[1]) ? ((level + 1) - ed[1]) : 1
    
    #レベルが指定値以上の場合はデータを足す。
    #タイプ4の場合は回数分乗算してから足す。
    
    data += eval(ed[0]) * number if level >= ed[1]
    }
    
    #データを返す。
    
    data
  end
  #--------------------------------------------------------------------------
  # EXP指定クラス
  #--------------------------------------------------------------------------
  def extra_exp_params
    
    #キャッシュがある場合はキャッシュを返す。
    
    return @extra_exp_params if @extra_exp_params != nil
    
    @extra_exp_params = [[],[],[],[],[]]
    
    #データを取得。
    
    self.note.each_line {|l|
    
    data = l.scan(/<#{EXP_RATE_PLUS::WORD}[:：](\S+)>/).flatten
    
    #データが存在する場合は続行。
    
    if data != nil && !data.empty?
      
      data = data[0].split(/\s*,\s*/)
      
      #データの数が2もしくは3の場合のみ続行。
      
      if data.size == 2 or data.size == 3
        
        #データの数が2の場合は、追加フラグをtrueとして追加する。
        #データの数が3の場合は、追加フラグの文字列を追加する。
          
        @extra_exp_params[data[0].to_i].push([data[1], data[2] != nil ? data[2].to_i : 0])
          
      
      end
      
    end
    
    }
    
    #データを返す。
    
    @extra_exp_params
  end
end
class Game_Interpreter
  def ex_exp_check(id, level = 0)
    
    #IDから職業データを取得。
    
    c_data = $data_classes[id]
    
    #存在しない場合は何もしない。
    
    return if c_data == nil
    
    #職業IDと職業名をコンソールに表示。
    
    p "職業ID" + id.to_s + " " + c_data.name
    
    #データ表示回数を取得する。
    
    number = level == 0 ? 99 : 1
    
    level = 1 if level == 0
    
    #指定回数分のデータを表示する。
    
    number.times {|i|
    if level != 1
      data1 = c_data.exp_for_level(level)
      data2 = level == 1 ? 0 : c_data.exp_for_level(level - 1)
      p "Level " + (level - 1).to_s + "⇒" + level.to_s + " 必要EXP " + (data1 - data2).to_s + " 累計EXP " + data1.to_s
    end
    level += 1
    }
  end
end