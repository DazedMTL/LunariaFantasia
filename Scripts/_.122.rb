#==============================================================================
# ★ RGSS3-Extension
# LNX11c_条件バトラーグラフィック
# 　条件に合わせてバトラーグラフィックを表示するための
# 　XPスタイルバトル専用拡張機能です。　
#
# 　version   : 1.01 (19/04/30)
# 　author    : ももまる
# 　website   : https://peachround.com/
# 　license   : https://creativecommons.org/licenses/by/2.1/jp/
#
#==============================================================================
#=begin
module LNX11
  #--------------------------------------------------------------------------
  # ● 設定:条件バトラーグラフィック
  #--------------------------------------------------------------------------
  # ダメージグラフィックを表示する時間(フレーム)  規定値:40
  DAMAGE_DURATION = 40
  
end

module LNX11
  #--------------------------------------------------------------------------
  # ● 正規表現
  #--------------------------------------------------------------------------
  # アクター：バトラーグラフィック = "ファイル名"
  RE_CBG = /<(?:条件バトラーグラフィック|GraphicWhen)\s*\:\s*(.+)>/i
  
  #--------------------------------------------------------------------------
  # ● 条件バトラーグラフィックのスクリプト指定
  #--------------------------------------------------------------------------
  def self.set_conditional_battler_graphic(id, filename, kind, id_or_tag = 0, priority = nil)
    if id.is_a?(Numeric) && filename.is_a?(String) && kind
      bt = "LNX11c:条件バトラーグラフィックを変更しました:ID#{id} #{filename} "
      bt += "#{kind} #{id_or_tag} #{priority || "default Priority"}"
      p bt
      battler = $game_actors[id]
      LNX11::BattleGraphicManager.add_cbg(battler, filename, kind, id_or_tag, priority)
    else
      errormes = "LNX11c:条件バトラーグラフィック指定の引数が正しくありません。"
      p errormes,"LNX11c:条件バトラーグラフィックの指定は行われませんでした。"
      msgbox errormes
    end
  end
  
  def self.条件バトラーグラフィック指定(id, filename, kind, id_or_tag = 0, priority = nil)
    self.set_conditional_battler_graphic(id, filename, kind, id_or_tag, priority)
  end
  
  def self.remove_conditional_battler_graphic(id, kind, id_or_tag = 0)
    battler = $game_actors[id]
    if id.is_a?(Numeric) && kind
      if LNX11::BattleGraphicManager.cbg_find(battler, kind, id_or_tag)
        bt = "LNX11c:条件バトラーグラフィックを削除しました:ID#{id} #{kind} #{id_or_tag}"
        p bt
        LNX11::BattleGraphicManager.delete_cbg(battler, kind, id_or_tag)
      else
        bt = "LNX11c:指定した条件バトラーグラフィックは存在しません:ID#{id} #{kind} #{id_or_tag}"
        p bt
      end
    else
      errormes = "LNX11c:条件バトラーグラフィック削除の引数が正しくありません。"
      p errormes,"LNX11c:条件バトラーグラフィックの削除は行われませんでした。"
      msgbox errormes
    end
  end
  
  def self.条件バトラーグラフィック削除(id, kind, id_or_tag = 0)
    self.remove_conditional_battler_graphic(id, kind, id_or_tag)
  end
  
  def self.reset_conditional_battler_graphic(id = 0)
    if id.zero?
      for i in 1...($data_actors.size-1)
        $game_actors[i].init_base_battle_graphic
        $game_actors[i].init_conditional_battler_graphics
      end
    else
      $game_actors[id].init_base_battle_graphic
      $game_actors[id].init_conditional_battler_graphics
    end
    p "LNX11c:条件バトラーグラフィックをリセットしました"
  end
  
  def self.条件バトラーグラフィックリセット(id = 0)
    self.reset_conditional_battler_graphic(id)
  end
  
  DEFAULT_CBGKIND_PRIORITY = {
    :state   => 0x80,
    :crisis  => 0x100,
    :command => 0x200,
    :ready   => 0x201,
    :skill   => 0x400,
    :item    => 0x401, 
    :damage  => 0x800,
    :victory => 0x801,
    :dead    => 0x1000
  }
  MULTI_CBGKIND = [
    :state,
    :ready,
    :skill,
    :item
  ]
end

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● [追加]:条件バトラーグラフィックファイル名を取得
  #--------------------------------------------------------------------------
  def conditional_battler_graphics
    # キャッシュがある場合、それを返す
    return @conditional_battler_graphics if @conditional_battler_graphics
    # メモ取得
    @conditional_battler_graphics = []
    note.each_line{|line|
      if LNX11::RE_CBG =~ line
        arr = $1.scan(/[^\,\s]+/)
        arr[1] = arr[1].downcase.to_sym
        @conditional_battler_graphics << arr
      end
    }
    @conditional_battler_graphics
  end
  #--------------------------------------------------------------------------
  # ● [追加]:タグの有無を取得
  #--------------------------------------------------------------------------
  def conditional_battler_graphic_tag?(tag)
    note =~ /<#{tag}>/
  end
end

#==============================================================================
# ■ [追加]:BattleGraphic
#==============================================================================

class LNX11::BattleGraphic
  attr_reader   :filename
  attr_accessor :face_index
  def initialize(filename)
    self.filename = filename
  end
  def filename=(new_filename)
    if new_filename =~ /(.+)\[(\d+)\]/
      @filename = $1
      @face_index = $2.to_i
    else
      @filename = new_filename
      @face_index = nil
    end
  end
end

#==============================================================================
# ■ [追加]:ConditionalBattleGraphic
#==============================================================================

class LNX11::ConditionalBattleGraphic
  attr_reader :battler_graphic
  attr_reader :condition
  def initialize(filename, kind, id_or_tag = 0, priority = nil)
    @battler_graphic = LNX11::BattleGraphic.new(filename)
    @condition = LNX11::ConditionalBattleGraphicCondition.new(kind, id_or_tag, priority)
  end
end

#==============================================================================
# ■ [追加]:ConditionalBattleGraphicCondition
#==============================================================================

class LNX11::ConditionalBattleGraphicCondition
  attr_accessor :kind
  attr_accessor :id_or_tag
  attr_accessor :priority
  
  def initialize(kind, id_or_tag = 0, priority = nil)
    if !(id_or_tag =~ /\D+/)
      id_or_tag = id_or_tag.to_i
    end
    if priority.is_a?(String)
      priority = priority.to_i
    end
    @kind = kind
    @id_or_tag = LNX11::MULTI_CBGKIND.include?(kind) ? id_or_tag : 0
    @priority = priority || LNX11::DEFAULT_CBGKIND_PRIORITY[kind]
  end
  
  def match?(object)
    return true if @id_or_tag == 0
    if @id_or_tag.is_a?(Numeric) # id
      object.id == @id_or_tag
    else # tag
      object.conditional_battler_graphic_tag?(@id_or_tag)
    end
  end
  
end

#==============================================================================
# ■ [追加]:BattleGraphicManager
#==============================================================================

module LNX11::BattleGraphicManager
  #--------------------------------------------------------------------------
  # ● kindおよびid_or_tagを持つCBGの取得(1つ)
  #--------------------------------------------------------------------------
  def self.cbg_find(battler, kind, id_or_tag = 0)
    if kind.is_a?(String)
      kind = kind.downcase.to_sym
    end
    if LNX11::MULTI_CBGKIND.include?(kind)
      battler.conditional_battler_graphics.find{|cbg|
        cbg.condition.kind == kind && cbg.condition.id_or_tag == id_or_tag
      }
    else
      battler.conditional_battler_graphics.find{|cbg| cbg.condition.kind == kind }
    end
  end
  #--------------------------------------------------------------------------
  # ● CBGの追加
  #    同一条件のものが存在していた場合、削除→追加
  #--------------------------------------------------------------------------
  def self.add_cbg(battler, filename, kind, id_or_tag = 0, priority = nil)
    if kind.is_a?(String)
      kind = kind.downcase.to_sym
    end
    delete_cbg(battler, kind, id_or_tag)
    new_cbg = LNX11::ConditionalBattleGraphic.new(filename, kind, id_or_tag, priority)
    battler.conditional_battler_graphics << new_cbg
  end
  #--------------------------------------------------------------------------
  # ● CBGの削除
  #--------------------------------------------------------------------------
  def self.delete_cbg(battler, kind, id_or_tag = 0)
    if kind.is_a?(String)
      kind = kind.downcase.to_sym
    end
    old_cbg = cbg_find(battler, kind, id_or_tag)
    if old_cbg
      battler.conditional_battler_graphics.delete(old_cbg)
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定kindをCBGの取得(複数)
  #--------------------------------------------------------------------------
  def self.cbgs_selected(battler, kind)
    battler.conditional_battler_graphics.select{|cbg| cbg.condition.kind == kind }
  end
  #--------------------------------------------------------------------------
  # ● 指定kindおよび条件(id_or_tag)に合致するCBGの取得(複数)
  #--------------------------------------------------------------------------
  def self.match_cbgs(battler, kind, object)
    arr = cbgs_selected(battler, kind).select{|cbg| cbg.condition.match?(object)}
    max_priority = arr.map{|cbg| cbg.condition.priority}.max
    arr.select{|cbg| cbg.condition.priority == max_priority}
  end
  #--------------------------------------------------------------------------
  # ● ファイル名のワイルドカードの変換
  #--------------------------------------------------------------------------
  def self.convert_wildcard_filename(battler, filename)
    filename.gsub(/\*/){ battler.base_battle_graphic.filename }
  end
  #--------------------------------------------------------------------------
  # ● 条件を満たしたCBGの取得(複数)
  #--------------------------------------------------------------------------
  def self.current_cbgs(battler, current_kind, current_condition)
    result = []
    if !battler.states.empty?
      battler.states.each{|state| result += match_cbgs(battler, :state, state)}
      result.uniq!
    end
    if current_condition
      result += match_cbgs(battler, current_condition[0], current_condition[1])
    end
    current_kind.each{|kind| result += cbgs_selected(battler, kind)}
    result.sort_by{|cbg| battler.conditional_battler_graphics.index(cbg)}
  end
  #--------------------------------------------------------------------------
  # ● 条件を満たしたCBGの取得(1つ、最もpriorityが大きいもの)
  #--------------------------------------------------------------------------
  def self.current_cbg(battler)
    current_kind = []
    if battler.cbg_crisis?
      current_kind << :crisis
    end
    if battler.cbg_damaging
      current_kind << :damage
    end
    if battler.dead?
      current_kind << :dead
    end
    arr = current_cbgs(battler, current_kind, battler.current_condition)
    max_priority = arr.map{|cbg| cbg.condition.priority}.max
    arr.select{|cbg| cbg.condition.priority == max_priority}.last
  end
  #--------------------------------------------------------------------------
  # ● コラプスエフェクト条件
  #--------------------------------------------------------------------------
  def self.need_collapse?(battler)
    if battler.alive?
      return false
    end
    if cbg_find(battler, :dead)
      return false
    end
    if battler.sprite_effect_type != nil
      return false
    end
    return true
  end
end

#==============================================================================
# ■ BattleManager
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # ● [エイリアス]:勝利の処理
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_process_victory :process_victory
  def process_victory
    $game_party.members.each{|actor| actor.set_victory}
    # 元のメソッドを呼ぶ
    return lnx11c_ex_process_victory
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:戦闘終了
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_battle_end :battle_end
  def battle_end(result)
    $game_party.members.each{|actor| actor.set_normal}
    # 元のメソッドを呼ぶ
    lnx11c_ex_battle_end(result)
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● [追加]:公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :base_battle_graphic
  attr_reader   :conditional_battler_graphics
  attr_writer   :battler_name
  attr_accessor :current_condition
  attr_accessor :cbg_damaging
  
  alias :lnx11c_ex_initialize :initialize
  def initialize(actor_id)
    lnx11c_ex_initialize(actor_id)
    init_base_battle_graphic
    init_conditional_battler_graphics
    @current_condition = nil
    @cbg_damaging = nil
  end
  
  def init_base_battle_graphic
    if !battler_graphic_name.empty?
      @base_battle_graphic = LNX11::BattleGraphic.new(battler_graphic_name)
    elsif !actor.default_battler_graphic.empty?
      @base_battle_graphic = LNX11::BattleGraphic.new(actor.default_battler_graphic)
    elsif LNX11::DEFAULT_BATTLER_GRAPHIC == 0
      @base_battle_graphic = LNX11::BattleGraphic.new(@face_name + "[#{@face_index}]")
    end
  end
  
  def init_conditional_battler_graphics
    @conditional_battler_graphics = []
    return if !@base_battle_graphic
    actor.conditional_battler_graphics.each{|arr|
      LNX11::BattleGraphicManager.add_cbg(self, arr[0], arr[1], arr[2] || 0, arr[3])
    }
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ダメージ条件バトラーグラフィック(及び時間)の設定
  #--------------------------------------------------------------------------
  def set_damaging
    @cbg_damaging = LNX11::DAMAGE_DURATION
    @refresh_battler_graphic = true
  end
  #--------------------------------------------------------------------------
  # ● [追加]:その他条件ごとのバトラーグラフィックの設定
  #--------------------------------------------------------------------------
  def set_condition(kind, object = nil)
    @current_condition = [kind, object]
    @refresh_battler_graphic = true
  end
  
  def set_normal
    @current_condition = nil
    @refresh_battler_graphic = true
  end
  
  def set_command
    set_condition(:command)
  end
  
  def set_ready
    set_condition(:ready, @actions.last.item)
  end
  
  def set_action
    if current_action.item.is_a?(RPG::Skill)
      set_condition(:skill, current_action.item)
    elsif current_action.item.is_a?(RPG::Item)
      set_condition(:item, current_action.item)
    end
  end
  
  def set_victory
    set_condition(:victory)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:コラプス効果の実行
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_perform_collapse_effect :perform_collapse_effect
  def perform_collapse_effect
    # CBGにdeadが指定されている場合
    if LNX11::BattleGraphicManager.cbg_find(self, :dead)
      # バトラーグラフィック更新フラグを立て、コラプスエフェクトを無効化
      @refresh_battler_graphic = true
      return
    end
    # 元のメソッドを呼ぶ
    lnx11c_ex_perform_collapse_effect
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ダメージ効果の実行
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_perform_damage_effect :perform_damage_effect
  def perform_damage_effect
    # 元のメソッドを呼ぶ
    lnx11c_ex_perform_damage_effect
    set_damaging
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:後指定のバトラーグラフィックファイル名の指定
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_battler_graphic_name= :battler_graphic_name=
  def battler_graphic_name=(filename)
    # 元のメソッドを呼ぶ
    self.lnx11c_ex_battler_graphic_name = filename
    init_base_battle_graphic
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:バトラーグラフィックの更新
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_update_battler_graphic :update_battler_graphic
  def update_battler_graphic
    # 元のメソッドを呼ぶ
    lnx11c_ex_update_battler_graphic
    update_cbg
  end
  #--------------------------------------------------------------------------
  # ● CBGおよびバトラーグラフィックの更新
  #--------------------------------------------------------------------------
  def update_cbg
    unless @conditional_battler_graphics
      return
    end
    if LNX11::BattleGraphicManager.current_cbg(self)
      battler_graphic = LNX11::BattleGraphicManager.current_cbg(self).battler_graphic
    else
      battler_graphic = self.base_battle_graphic
    end
    filename = LNX11::BattleGraphicManager.convert_wildcard_filename(self, battler_graphic.filename)
    if battler_graphic.face_index
      @battler_name = ""
      self.facebattler = draw_face(filename, battler_graphic.face_index)
    else
      @battler_name = filename
      dispose_facebattler
    end
  end
  #--------------------------------------------------------------------------
  # ● ピンチ状態？
  #--------------------------------------------------------------------------
  def cbg_crisis?
    return self.hp < self.mhp / 4
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ステートの付加
  #--------------------------------------------------------------------------
  alias :lnx11c_add_state :add_state
  def add_state(state_id)
    lnx11c_add_state(state_id)
    @refresh_battler_graphic = true
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ステートの解除
  #--------------------------------------------------------------------------
  alias :lnx11c_remove_state :remove_state
  def remove_state(state_id)
    lnx11c_remove_state(state_id)
    @refresh_battler_graphic = true
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:グラフィック設定の配列を返す
  #--------------------------------------------------------------------------
  def graphic_name_index
    # 顔グラフィック強制 (歩行グラフィック非対応)
    [@face_name, @face_index]
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:デフォルトバトラーグラフィックの取得
  #--------------------------------------------------------------------------
  def facebattler
    if $game_temp.actor_battler_graphic[id]
      return $game_temp.actor_battler_graphic[id]
    end
    return nil
  end
  def facebattler=(bitmap)
    $game_temp.actor_battler_graphic[id] = bitmap
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:顔グラフィックを描画して返す
  #--------------------------------------------------------------------------
  alias :lnx11c_draw_face :draw_face
  def draw_face(face_name, face_index, enabled = true)
    if facebattler &&
       facebattler[:name] == face_name &&
       facebattler[:index] == face_index &&
       facebattler[:bitmap] && !facebattler[:bitmap].disposed?
      return facebattler
    end
    face = lnx11c_draw_face(face_name, face_index, enabled)
    {:name => face_name, :index => face_index, :bitmap => face}
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:デフォルトバトラーグラフィック設定
  #--------------------------------------------------------------------------
  def default_battler_graphic
    # 顔グラフィック強制 (歩行グラフィック非対応)
    self.facebattler = draw_face(@face_name, @face_index)
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:バトラー用顔グラフィックの解放
  #--------------------------------------------------------------------------
  def dispose_facebattler
    self.facebattler = nil
  end
end

#==============================================================================
# ■ Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ● [再定義]:可視状態の初期化
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_init_visibility :init_visibility
  def init_visibility
    if @battler.actor?
      last_battler_visible = @battler_visible
      @battler_visible = !LNX11::BattleGraphicManager.need_collapse?(@battler)
      self.opacity = 0 unless @battler_visible
      if @battler_visible && !last_battler_visible
        @battler_visible =  false
      end
    else
      lnx11c_ex_init_visibility
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:転送元ビットマップの更新
  #--------------------------------------------------------------------------
  def update_cbg_damage
    if @battler.actor? && @battler.cbg_damaging
      @battler.cbg_damaging -= 1
      if @battler.cbg_damaging.zero?
        @battler.cbg_damaging = nil
        @battler.refresh_battler_graphic = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:転送元ビットマップの更新
  #--------------------------------------------------------------------------
  def update_bitmap
    update_cbg_damage
    if @battler.actor? && @battler.refresh_battler_graphic
      # バトラーグラフィックが変更されていれば更新する
      @battler.update_battler_graphic
    end
    if @battler.actor? && @battler.facebattler != nil
      # バトラー用顔グラフィックが作成されていれば、
      # それを Sprite の Bitmap とする
      new_bitmap = @battler.facebattler[:bitmap]
      if bitmap != new_bitmap
        self.bitmap = new_bitmap
        init_visibility
      end
    else
      # 元のメソッドを呼ぶ
      lnx11a_update_bitmap
    end
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● [エイリアス]:戦闘行動終了時の処理
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_process_action_end :process_action_end
  def process_action_end
    if @subject.actor?
      @subject.set_normal
    end
    # 元のメソッドを呼ぶ
    lnx11c_ex_process_action_end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:戦闘行動の実行
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_execute_action :execute_action
  def execute_action
    if @subject.actor?
      @subject.set_action
    end
    # 元のメソッドを呼ぶ
    lnx11c_ex_execute_action
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:次のコマンド入力へ
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_next_command :next_command
  def next_command
    if BattleManager.actor
      BattleManager.actor.set_ready
    end
    # 元のメソッドを呼ぶ
    lnx11c_ex_next_command
    if BattleManager.actor
      BattleManager.actor.set_command
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:前のコマンド入力へ
  #--------------------------------------------------------------------------
  alias :lnx11c_ex_prior_command :prior_command
  def prior_command
    if BattleManager.actor
      BattleManager.actor.set_normal
    end
    # 元のメソッドを呼ぶ
    lnx11c_ex_prior_command
    if BattleManager.actor
      BattleManager.actor.set_command
    end
  end
end
#=end