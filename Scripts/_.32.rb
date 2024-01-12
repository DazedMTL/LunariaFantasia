class Window_BattlePicture < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(-16, -16, 640+32, 480+32)
    self.z -= 100
  end
  #--------------------------------------------------------------------------
  # ● 立ち絵のセット
  #--------------------------------------------------------------------------
  def set(actor)
    self.contents.clear
    return if actor.graphic_name == ""
    #stand_name = "Stands/" + actor.graphic_name + "_cos#{actor.costume}" + "_face#{format("%02d",face_id)}"
    bitmap1 = Cache.stand("#{actor.graphic_name}_cos#{actor.costume}")
    #bitmap1 = Cache.picture(face_name)
    y = FAKEREAL::X_ADJUST_ACTOR[actor.id][2] + FAKEREAL::STAND_Y
    x = FAKEREAL::RIGHT_X + FAKEREAL::X_ADJUST_ACTOR[actor.id][0]
    rect1 = Rect.new(0, 0, bitmap1.width, bitmap1.height)
    #x = 416-bitmap1.width/2 + WD_battlepicture_ini::Picture_x
    #y = 432-bitmap1.height + WD_battlepicture_ini::Picture_y
    self.contents.blt(x, y, bitmap1, rect1, WD_battlepicture_ini::Picture_opacity)
  end
end

