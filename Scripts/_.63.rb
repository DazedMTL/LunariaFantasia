module FAKEREAL
  SEX_POINT = 4 #淫性値の変数
end

module FRGP
  ICON_DEBUFF_START     = 80              # 弱体（16 個）
  #--------------------------------------------------------------------------
  # ○ 適正や耐性の描画ベース
  #--------------------------------------------------------------------------
  def draw_percent(x, y, str, rate, icon = false, plus = 0)
    change_color(system_color)
    i = 0
    draw_text(x, y + line_height * i, 85, line_height, str)
    change_color(normal_color)
    return unless rate
    h = line_height
    h += 2 if icon && line_height == 22
    rate.each do |name, num|
      i += 1
      if icon
        draw_icon(name, x, y + h * i)
      else
        draw_text(x - 30, y + h * i, 82, h, "#{name}")
      end
      draw_text(x + plus, y + h * i, 82, h, "#{num}％", 2)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 術適正の描画
  #--------------------------------------------------------------------------
  def draw_magic_elements(x, y)
    ary = ["Fire", "Ice", "Thunder", "Light", "Darkness", "None", "Heal"]
    str = "Aptitude"
    rate = {}
    ary.each{|name| rate[name] = el_rate(name)}
    draw_percent(x, y, str, rate, false, 13)
  end
  #--------------------------------------------------------------------------
  # ○ 属性耐性の描画
  #--------------------------------------------------------------------------
  def draw_guard_elements(x, y)
    ary = ["Fire", "Ice", "Thunder", "Light", "Darkness", "Charm"]
    str = "Elemental RES"
    rate = {}
    ary.each{|name| rate[ELEMENT_ICON[elements_comvert(name)]] = elg_rate(name)}
    draw_percent(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ 状態耐性の描画
  #--------------------------------------------------------------------------
  def draw_guard_state(x, y, ext = "Seal")
    ary = ["Instant Death", "Poison", "Blind", "Silence", "Confusion", "Sleep", "Paralysis", "Stun", ext]
    str = "Status RES"
    rate = {}
    ary.compact.each{|name| rate[$data_states[state_comvert(name)].icon_index] = stg_rate(name)}
    draw_percent(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ 弱体耐性の描画
  #--------------------------------------------------------------------------
  def draw_guard_debuff(x, y)
    ary = [2, 3, 4, 5, 6, 7]
    str = "Weakness"
    rate = {}
    ary.each{|id| rate[ICON_DEBUFF_START + id] = debuff_rate(id)}
    draw_percent(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ IDを術適正に変換
  #--------------------------------------------------------------------------
  def el_rate(element_name)
    (@actor.atk_elements_rate(elements_comvert(element_name)) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ IDを属性耐性に変換
  #--------------------------------------------------------------------------
  def elg_rate(element_name)
    100 - (@actor.element_rate(elements_comvert(element_name)) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ IDを状態耐性に変換
  #--------------------------------------------------------------------------
  def stg_rate(state_name)
    id = state_comvert(state_name)
    return 100 if @actor.state_resist?(id)
    100 - (@actor.state_rate(id) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ IDを弱体耐性に変換
  #--------------------------------------------------------------------------
  def debuff_rate(id)
    100 - (@actor.debuff_rate(id) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ 属性名をIDに変換
  #--------------------------------------------------------------------------
  def elements_comvert(element_name)
    case element_name
    when "None" ; 0
    when "Fire" ; 3
    when "Ice" ; 4
    when "Thunder" ; 5
    when "Charm" ; 7
    when "Light" ; 9
    when "Darkness" ; 10
    when "Heal" ; 50
    when "Exorcism" ; 6
    when "Physical" ; 1
    when "Absorb" ; 2
    when "Steal" ; 11
    else ; 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ 状態名をIDに変換
  #--------------------------------------------------------------------------
  def state_comvert(state_name)
    case state_name
    when "Instant Death" ; 1
    when "Poison"   ; 2
    when "Blind" ; 3
    when "Silence" ; 4
    when "Confusion" ; 5
    when "Sleep" ; 6
    when "Paralysis" ; 7
    when "Stun"  ; 8
    when "Seal" ; 31
    when "Charm" ; 26
    else ; 31
    end
  end
end

#==============================================================================
# ■ Window_Status
#------------------------------------------------------------------------------
# 　ステータス画面で表示する、フル仕様のステータスウィンドウです。
#==============================================================================

class Window_Status < Window_Selectable
  include FRGP
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, Graphics.width, Graphics.height)
    @actor = actor
    @page_index = 0
    self.opacity = 0
    refresh
    activate
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 文字の大きさを設定
  #--------------------------------------------------------------------------
  def font_size
    return 22
  end
  #--------------------------------------------------------------------------
  # ● 行の高さを取得
  #--------------------------------------------------------------------------
  def line_height
    return font_size
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    contents.font.size = font_size
    @actor.summon_level_set($game_actors[1].level) if @actor.summon_type? && @actor.level != $game_actors[1].level
    draw_page     (line_height * 0)
    draw_block1   (line_height * 1)
    draw_block2   (line_height * 2)
    draw_horz_line(line_height * 6, 0.6) if !(@page_index == 2)
    draw_block3   (line_height * 7)
    draw_horz_line(line_height * 17, 0.52) if @page_index == 0
    draw_block4   (line_height * 18)
  end
  #--------------------------------------------------------------------------
  # ● ページ数の描画
  #--------------------------------------------------------------------------
  def draw_page(y)
    change_color(normal_color)
    draw_text(0, y, contents_width, line_height, "page#{@page_index + 1}/#{page_max}", 2)
    draw_text(-2, y + line_height, contents_width, line_height, "←　→", 2)
  end
  #--------------------------------------------------------------------------
  # ● ブロック 1 の描画
  #--------------------------------------------------------------------------
  def draw_block1(y)
    draw_actor_nickname(@actor, 4, y * 0, 300)
    draw_actor_class(@actor, 4, y * 1)
  end
  #--------------------------------------------------------------------------
  # ● ブロック 2 の描画
  #--------------------------------------------------------------------------
  def draw_block2(y)
    if @page_index == 0 || @page_index == 1
      draw_basic_info(8, y)
      draw_exp_info(164, y + line_height * 2) if !@actor.summon_type?
    else
      draw_equipments(8, y)
      draw_skill_equipments(228, y)
      draw_horz_line(y + 24 * 6, 0.52)
    end
  end
  #--------------------------------------------------------------------------
  # ● ブロック 3 の描画
  #--------------------------------------------------------------------------
  def draw_block3(y)
    if @page_index == 0
      draw_parameters(8, y + line_height * 0)
      draw_extra_parameters(8, y + line_height * 6)
      draw_magic_elements(188, y + line_height * 0)
    elsif @page_index == 1
      draw_guard_state(8, y + line_height * 0)
      draw_guard_debuff(128, y + line_height * 0)
      draw_guard_elements(248, y + line_height * 0)
      #draw_guard_elements(128, y + line_height * 0)
      #draw_equipments(248, y + line_height * 0)
    else
      draw_profile(@actor, 8, y + line_height * 0)
    end
  end
  #--------------------------------------------------------------------------
  # ● ブロック 4 の描画
  #--------------------------------------------------------------------------
  def draw_block4(y)
    draw_description(4, y)
  end
  #--------------------------------------------------------------------------
  # ● 水平線の描画
  #--------------------------------------------------------------------------
  def draw_horz_line(y, rate)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width * rate, 2, line_color)#contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # ● 水平線の色を取得
  #--------------------------------------------------------------------------
  def line_color
    color =  normal_color #system_color
    color.alpha = 180
    color
  end
  #--------------------------------------------------------------------------
  # ● 基本情報の描画
  #--------------------------------------------------------------------------
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + line_height * 0)
    #draw_actor_icons(@actor, x, y + line_height * 1)
    draw_actor_hp(@actor, x, y + line_height * 1)
    draw_actor_mp(@actor, x, y + line_height * 2)
    draw_actor_tp(@actor, x, y + line_height * 3)
  end
  #--------------------------------------------------------------------------
  # ● 能力値の描画
  #--------------------------------------------------------------------------
  def draw_parameters(x, y)
    6.times {|i| draw_actor_param(@actor, x, y + line_height * i, i + 2) }
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値の描画
  #--------------------------------------------------------------------------
  def draw_extra_parameters(x, y)
    3.times {|i| draw_actor_extra_param(@actor, x, y + line_height * i, i) }
  end
  #--------------------------------------------------------------------------
  # ● 経験値情報の描画　※再定義 汎用ゲージ描画
  #--------------------------------------------------------------------------
  def draw_exp_info(x, y)
    #s1 = @actor.max_level? ? "-------" : @actor.exp
    #s2 = @actor.max_level? ? "-------" : @actor.next_level_exp - @actor.exp
    #s_next = sprintf(Vocab::ExpNext, Vocab::level)
    #change_color(system_color)
    #draw_text(x, y + line_height * 0, 110, line_height, Vocab::ExpTotal)
    #draw_text(x, y + line_height * 1, 110, line_height, s_next)
    #change_color(normal_color)
    #draw_text(x, y + line_height * 0, 110, line_height, s1, 2)
    #draw_text(x, y + line_height * 1, 110, line_height, s2, 2)
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    change_color(normal_color)
    draw_actor_exp(     @actor, x, y + line_height * 0)
    draw_actor_next_exp(@actor, x, y + line_height * 1)
    change_color(system_color)
    draw_text(x, y + line_height * 0, 110, line_height, Vocab::ExpTotal)
    draw_text(x, y + line_height * 1, 110, line_height, s_next)
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ● 装備品の描画
  #--------------------------------------------------------------------------
  def draw_equipments(x, y)
    contents.font.size = 24
    h = 24
    change_color(system_color)
    draw_text(x, y, width, h, "Equipment")
    change_color(normal_color)
    @actor.equips.each_with_index do |item, i|
      draw_item_name(item, x, y + h * (i + 1), i)
    end
    contents.font.size = font_size
  end
  #--------------------------------------------------------------------------
  # ● 装備スキルの描画
  #--------------------------------------------------------------------------
  def draw_skill_equipments(x, y)
    contents.font.size = 24
    h = 24
    change_color(system_color)
    draw_text(x, y, width, h, "Skill")
    change_color(normal_color)
    @actor.change_skill.each_with_index do |item, i|
      draw_item_name(item, x, y + h * (i + 1), i)
    end
    contents.font.size = font_size
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
=begin
  def draw_item_name(item, x, y, i = 0, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
=end
  #--------------------------------------------------------------------------
  # ● 説明の描画
  #--------------------------------------------------------------------------
  def draw_description(x, y)
    if @page_index == 0
      contents.font.size = 15
      draw_text_ex(x, y-15, @actor.description)
    end
    contents.font.size = font_size
  end
  #--------------------------------------------------------------------------
  # ● 能力値の描画　※オーバーライド
  #--------------------------------------------------------------------------
  def draw_actor_param(actor, x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x, y, 120, line_height, actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値の描画
  #--------------------------------------------------------------------------
  def ex_param(param_id, actor)
    case param_id
    when 0;    return actor.hit * 100
    when 1;    return actor.eva * 100
    when 2;    return actor.cri * 100
    else  ;    return 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ 特殊能力値の描画
  #--------------------------------------------------------------------------
  def draw_actor_extra_param(actor, x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, FAKEREAL::xparam(param_id))
    change_color(normal_color)
    draw_text(x + 40, y, 80, line_height, "#{format("%.2f",ex_param(param_id, actor))}", 2)
  end
=begin
  #--------------------------------------------------------------------------
  # ○ 適正や耐性の描画ベース
  #--------------------------------------------------------------------------
  def draw_percent(x, y, str, rate, icon = false, plus = 0)
    change_color(system_color)
    i = 0
    draw_text(x, y + line_height * i, 85, line_height, str)
    change_color(normal_color)
    return unless rate
    h = line_height
    h += 2 if icon
    rate.each do |name, num|
      i += 1
      if icon
        draw_icon(name, x, y + h * i)
      else
        draw_text(x + 4, y + h * i, 82, h, "#{name}")
      end
      draw_text(x + plus, y + h * i, 82, h, "#{num}％", 2)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 術適正の描画
  #--------------------------------------------------------------------------
  def draw_magic_elements(x, y)
    ary = ["炎","氷","雷","光","闇","無","回復"]
    str = "術適正"
    rate = {}
    ary.each{|name| rate[name] = el_rate(name)}
    draw_percent(x, y, str, rate, false, 13)
  end
  #--------------------------------------------------------------------------
  # ○ 属性耐性の描画
  #--------------------------------------------------------------------------
  def draw_guard_elements(x, y)
    ary = ["炎","氷","雷","光","闇"]
    str = "属性耐性"
    rate = {}
    #ary.each{|name| rate[FRGP::ELEMENT_ICON[elements_comvert(name)]] = elg_rate(name)}
    ary.each{|name| rate[ELEMENT_ICON[elements_comvert(name)]] = elg_rate(name)}
    draw_percent(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ 状態耐性の描画
  #--------------------------------------------------------------------------
  def draw_guard_state(x, y)
    ary = ["即死","毒","暗闇","沈黙","混乱","睡眠","麻痺","ｽﾀﾝ","閉門"]
    str = "状態耐性"
    rate = {}
    ary.each{|name| rate[$data_states[state_comvert(name)].icon_index] = stg_rate(name)}
    draw_percent(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ 弱体耐性の描画
  #--------------------------------------------------------------------------
  def draw_guard_debuff(x, y)
    ary = [2, 3, 4, 5, 6, 7]
    str = "弱体耐性"
    rate = {}
    #ary.each{|id| rate[Vocab.param(id)] = debuff_rate(id)}
    #ary.each{|id| rate[FRGP::ICON_DEBUFF_START + id] = debuff_rate(id)}
    ary.each{|id| rate[ICON_DEBUFF_START + id] = debuff_rate(id)}
    draw_percent(x, y, str, rate, true)
  end
  #--------------------------------------------------------------------------
  # ○ IDを術適正に変換
  #--------------------------------------------------------------------------
  def el_rate(element_name)
    (@actor.atk_elements_rate(elements_comvert(element_name)) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ IDを属性耐性に変換
  #--------------------------------------------------------------------------
  def elg_rate(element_name)
    100 - (@actor.element_rate(elements_comvert(element_name)) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ IDを状態耐性に変換
  #--------------------------------------------------------------------------
  def stg_rate(state_name)
    id = state_comvert(state_name)
    return 100 if @actor.state_resist?(id)
    100 - (@actor.state_rate(id) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ IDを弱体耐性に変換
  #--------------------------------------------------------------------------
  def debuff_rate(id)
    100 - (@actor.debuff_rate(id) * 100).round
  end
  #--------------------------------------------------------------------------
  # ○ 属性名をIDに変換
  #--------------------------------------------------------------------------
  def elements_comvert(element_name)
    case element_name
    when "無" ; 0
    when "炎" ; 3
    when "氷" ; 4
    when "雷" ; 5
    when "光" ; 9
    when "闇" ; 10
    when "回復" ; 50
    else ; 0
    end
  end
  #--------------------------------------------------------------------------
  # ○ 状態名をIDに変換
  #--------------------------------------------------------------------------
  def state_comvert(state_name)
    case state_name
    when "即死" ; 1
    when "毒"   ; 2
    when "暗闇" ; 3
    when "沈黙" ; 4
    when "混乱" ; 5
    when "睡眠" ; 6
    when "麻痺" ; 7
    when "ｽﾀﾝ"  ; 8
    else ; 31
    end
  end
=end
  #--------------------------------------------------------------------------
  # ○ プロフィールの描画
  #--------------------------------------------------------------------------
  def draw_profile(actor, x, y)
    contents.font.size = 24
    h = 24
    xp = 148
    yp = 10
    change_color(system_color)
    draw_text(x, y + h * 2 + yp, 100, h, "Height")
    draw_text(x + xp, y + h * 2 + yp, 100, h, "3 Sizes")
    draw_text(x, y + h * 7, 100, h, "Sex EXP")
    draw_text(x + xp, y + h * 7, 100, h, FAKEREAL::SEX_POINT_NAME) if actor.main?
    change_color(normal_color)
    draw_text(x + 4, y + h * 3 + yp, 80, h, "#{actor.profile["t"]}cm", 2)
    draw_text(x + 10 + xp, y + h * 3 + yp, 70, h, "B:")
    draw_text(x + 14 + xp, y + h * 3 + yp, 70, h, "#{actor.profile["b"]}cm", 2)
    draw_text(x + 84 + xp, y + h * 3 + yp, 70, h, "(#{actor.profile["c"]})")
    draw_text(x + 10 + xp, y + h * 4 + yp, 70, h, "W:")
    draw_text(x + 14 + xp, y + h * 4 + yp, 70, h, "#{actor.profile["w"]}cm", 2)
    draw_text(x + 10 + xp, y + h * 5 + yp, 70, h, "H:")
    draw_text(x + 14 + xp, y + h * 5 + yp, 70, h, "#{actor.profile["h"]}cm", 2)
    #draw_horz_line(y + h * 7, 0.52)
    if actor.id != 2 #main?
      sex = (!actor.virgin || actor.sex_all_count > 0 ) ? "Yes" : "None"
      if actor.main?
        sp = $game_variables[FAKEREAL::SEX_POINT]
        draw_text(x + 224, y + h * 7, 80, h, sp)
      end
    else
      sex = actor.virgin ? "Husband" : "Other"
    end
    draw_text(x + 74, y + h * 7, 120, h, sex)
    contents.font.size = 18
    h = 22
    xa = -24
    xb = 168
    ya = 0
    draw_text(x + xa, y + ya + h * 9, 100, h, "Kiss:", 2)
    draw_text(x + xa, y + ya + h * 10, 100, h, "Handjob:", 2)
    draw_text(x + xa, y + ya + h * 11, 100, h, "Fellatio:", 2)
    draw_text(x + xa, y + ya + h * 12, 100, h, "Swallow:", 2)
    draw_text(x + xa + xb, y + ya + h * 9, 100, h, "Harassment:", 2)
    draw_text(x + xa + xb, y + ya + h * 10, 100, h, "Paizuri:", 2)
    draw_text(x + xa + xb, y + ya + h * 11, 100, h, "Sex:", 2)
    draw_text(x + xa + xb, y + ya + h * 12, 100, h, "Anal:", 2)
    #draw_text(x + xa + xb * 2, y + ya + h * 9, 100, h, "Masturbation:", 2)
    draw_text(x + xa + xb * 2, y + ya + h * 10, 100, h, "Climaxes:", 2)
    draw_text(x + xa + xb * 2, y + ya + h * 11, 100, h, "Creampies:", 2)
    draw_text(x + xa + xb * 2, y + ya + h * 12, 100, h, "Bukkake:", 2)
    sh = actor.harassment
    k = actor.kiss
    t = actor.tekoki
    f = actor.fellatio
    p = actor.paizuri
    a = actor.anal
    s = actor.sex
    c = actor.creampie
    b = actor.bukkake
    d = actor.drink
    e = actor.ecstasy
    o = actor.onanie
    xc = 100
    if actor.id != 2 #main?
    draw_text(x + xa + xc, y + ya + h * 9, 100, h, sex_count(k, "None", "x"))
    draw_text(x + xa + xc, y + ya + h * 10, 100, h, sex_count(t))
    draw_text(x + xa + xc, y + ya + h * 11, 100, h, sex_count(f))
    draw_text(x + xa + xc, y + ya + h * 12, 100, h, sex_count(d))
    draw_text(x + xa + xb + xc, y + ya + h * 9, 100, h, sex_count(sh))
    draw_text(x + xa + xb + xc, y + ya + h * 10, 100, h, sex_count(p))
    draw_text(x + xa + xb + xc, y + ya + h * 11, 100, h, sex_count(s, "Virgin", "x"))
    draw_text(x + xa + xb + xc, y + ya + h * 12, 100, h, sex_count(a, "Virgin", "x"))
    #draw_text(x + xa + xb * 2 + xc, y + ya + h * 9, 100, h, sex_count(o))
    draw_text(x + xa + xb * 2 + xc, y + ya + h * 10, 100, h, sex_count(e, "0x"))
    draw_text(x + xa + xb * 2 + xc, y + ya + h * 11, 100, h, sex_count(c))
    draw_text(x + xa + xb * 2 + xc, y + ya + h * 12, 100, h, sex_count(b))
    else
    draw_text(x + xa + xc, y + ya + h * 9, 100, h, wife_count(k, "Virgin", "x"))
    draw_text(x + xa + xc, y + ya + h * 10, 100, h, wife_count(t))
    draw_text(x + xa + xc, y + ya + h * 11, 100, h, wife_count(f))
    draw_text(x + xa + xc, y + ya + h * 12, 100, h, wife_count(d))
    draw_text(x + xa + xb + xc, y + ya + h * 9, 100, h, wife_count(sh, "None"))
    draw_text(x + xa + xb + xc, y + ya + h * 10, 100, h, wife_count(p))
    draw_text(x + xa + xb + xc, y + ya + h * 11, 100, h, wife_count(s, "Virgin", "x"))
    draw_text(x + xa + xb + xc, y + ya + h * 12, 100, h, wife_count(a, "Virgin", "x"))
    #draw_text(x + xa + xb * 2 + xc, y + ya + h * 9, 100, h, wife_count(o))
    draw_text(x + xa + xb * 2 + xc, y + ya + h * 10, 100, h, wife_count(e))
    draw_text(x + xa + xb * 2 + xc, y + ya + h * 11, 100, h, wife_count(c))
    draw_text(x + xa + xb * 2 + xc, y + ya + h * 12, 100, h, wife_count(b))
    end
    contents.font.size = font_size
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def sex_count(sex, virgin = "None", unit = "x")
    return sex == 0 ? virgin : "#{sex}#{unit}"
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def wife_count(sex, virgin = "None", unit = "x")
    return sex == 0 ? virgin : "#{sex}#{unit}"
  end
  #--------------------------------------------------------------------------
  # ● 各種文字色の取得　※オーバーライド
  #--------------------------------------------------------------------------
  def system_color;      text_color(14);  end;    # システム
  #--------------------------------------------------------------------------
  # ● 制御文字つきテキストの描画　※オーバーライド
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # ● 最大ページ数の取得
  #--------------------------------------------------------------------------
  def page_max
    3
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_page
  end
  #--------------------------------------------------------------------------
  # ● ページの更新
  #--------------------------------------------------------------------------
  def update_page
    if visible && (Input.trigger?(:Z) || Input.trigger?(:RIGHT)) && page_max > 1
      Sound.play_cursor
      @page_index = (@page_index + 1) % page_max
      refresh
    elsif visible && Input.trigger?(:LEFT) && page_max > 1
      Sound.play_cursor
      @page_index = (@page_index - 1) % page_max
      refresh
    end
  end
end

#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
# 　用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#==============================================================================

module Vocab
  # ステータス画面
  ExpTotal        = "EXP"
  ExpNext         = "NEXT"
end

#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 　ステータス画面の処理を行うクラスです。
#==============================================================================

class Scene_Status < Scene_MenuBase
  include FRCS
  #--------------------------------------------------------------------------
  # ● 背景の作成
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = Cache.system("Status_bg")
  end
  #--------------------------------------------------------------------------
  # ○ アクターグラフィックの作成
  #--------------------------------------------------------------------------
  def create_actor_graphic
    return unless @actor
    @actor_sprite = Sprite.new
    @actor_sprite.bitmap = Cache.stand("#{@actor.graphic_name}_cos#{@actor.costume}")
    @actor_sprite.ox = @actor_sprite.bitmap.width + @actor.graphic_status_ox
    @actor_sprite.oy = @actor.graphic_status_oy
    @actor_sprite.x = Graphics.width
    #@actor_sprite.z = 200
  end
  #--------------------------------------------------------------------------
  # ● 開始処理　※エイリアス
  #--------------------------------------------------------------------------
  alias new_status_start start
  def start
    new_status_start
    create_actor_graphic
  end
  #--------------------------------------------------------------------------
  # ○ 終了処理　※オーバーライド
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_actor_graphic
  end
  #--------------------------------------------------------------------------
  # ○ アクターグラフィックの解放
  #--------------------------------------------------------------------------
  def dispose_actor_graphic
    @actor_sprite.bitmap.dispose
    @actor_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え　※エイリアス
  #--------------------------------------------------------------------------
  alias new_status_on_actor_change on_actor_change
  def on_actor_change
    dispose_actor_graphic
    new_status_on_actor_change
    create_actor_graphic
  end
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor   :virgin                    # 処女かどうか
  attr_accessor   :sex                       # セックス人数
  attr_accessor   :creampie                  # 中出し回数
  attr_accessor   :fellatio                  # フェラ回数
  attr_accessor   :paizuri                   # パイズリ回数
  attr_accessor   :anal                      # アナルセックス人数
  attr_accessor   :harassment                # セクハラの回数
  attr_accessor   :kiss                      # キスの人数
  attr_accessor   :tekoki                    # 手コキの回数
  attr_accessor   :bukkake                   # ぶっかけ回数
  attr_accessor   :ecstasy                   # 絶頂回数
  attr_accessor   :drink                     # 精飲回数
  attr_accessor   :onanie                    # 自慰回数（予定には無いが念の為）
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias profile_initialize initialize
  def initialize(actor_id)
    profile_initialize(actor_id)
    #@profile = profile_set
    sex_init
  end
  #--------------------------------------------------------------------------
  # ○ グラフィックのベース名の取得
  #--------------------------------------------------------------------------
  def graphic_name
    return $1 if actor.note =~ /\<グラフィック名:(\w+?)\>/
    return ""
  end
  #--------------------------------------------------------------------------
  # ○ グラフィックのステータス画面でのoxの取得
  #　　マイナス数値で右に移動
  #--------------------------------------------------------------------------
  def graphic_status_ox
    return $1.to_i if actor.note =~ /\<ステータスox:(\-?\d+?)\>/
    return 0
  end
  #--------------------------------------------------------------------------
  # ○ グラフィックのステータス画面でのoyの取得　
  #　　マイナス数値で下に下がる
  #--------------------------------------------------------------------------
  def graphic_status_oy
    return $1.to_i if actor.note =~ /\<ステータスoy:(\-?\d+?)\>/
    return 0
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def profile
    prof = {}
    prof["t"] = Person::BWH["n#{actor.id}_t"]
    prof["b"] = Person::BWH["n#{actor.id}_b"]
    prof["w"] = Person::BWH["n#{actor.id}_w"]
    prof["h"] = Person::BWH["n#{actor.id}_h"]
    prof["c"] = Person::BWH["n#{actor.id}_c"]
    return prof
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def virgin_set
    actor.note.include?("<処女>") || actor.note.include?("<夫のみ>")
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def sex_init
    @virgin     = virgin_set
    @sex        = 0
    @creampie   = 0
    @fellatio   = 0
    @paizuri    = 0
    @anal       = 0
    @harassment = 0
    @kiss       = 0
    @tekoki     = 0
    @bukkake    = 0
    @ecstasy    = 0
    @drink      = 0
    @onanie     = 0
  end
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def sex_all_count
    return @sex + @creampie + @fellatio + @paizuri + @anal + @harassment + @kiss + @tekoki + @bukkake + @ecstasy + @drink + @onanie
  end
end

#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ○ 
  #--------------------------------------------------------------------------
  def sex(play, count = 1, id = 1)
    case play
    when "f" ; $game_actors[id].fellatio += count
    when "p" ; $game_actors[id].paizuri += count
    when "s" ; $game_actors[id].sex += count
    when "c" ; $game_actors[id].creampie += count
    when "a" ; $game_actors[id].anal += count
    when "h" ; $game_actors[id].harassment += count
    when "k" ; $game_actors[id].kiss += count
    when "t" ; $game_actors[id].tekoki += count
    when "b" ; $game_actors[id].bukkake += count
    when "e" ; $game_actors[id].ecstasy += count
    when "d" ; $game_actors[id].drink += count
    when "o" ; $game_actors[id].onanie += count
    end
  end
end