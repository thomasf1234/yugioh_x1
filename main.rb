#<Encoding:UTF-8>
require 'gosu'
#require 'opengl'
require 'gl'
require 'glu'
require 'glut'
require_relative "obj_model.rb"

begin; Gosu::enable_undocumented_retrofication; rescue; end
include Gl,Glu,Glut

#https://github.com/tjbladez/gosu-opengl-tutorials/blob/master/lessons/lesson01.rb
#https://www.libgosu.org/

#Window

class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Minecraft Style"
    @floor = Gosu::Image.new(self, "floor.png", true)
    @texture = Gosu::Image.new(self, "character_skin.png", true)
    @character = {
      :x => 0.0,
      :y => 0.0,
      :z => 0.0,
      :head => ObjModel2.new(self, "character_head.obj", @texture),
      :body => ObjModel2.new(self, "character_body.obj", @texture),
      :left_arm => ObjModel2.new(self, "character_left_arm.obj", @texture),
      :right_arm => ObjModel2.new(self, "character_right_arm.obj", @texture),
      :left_leg => ObjModel2.new(self, "character_left_leg.obj", @texture),
      :right_leg => ObjModel2.new(self, "character_right_leg.obj", @texture),
      :rotation => 0.0,
      :inc => 4.0,
      :angle => 0.0,
      :speed => 1.2
    }

    @camera = {
      :ratio => self.width.to_f / self.height.to_f,
      :fovy => 45.0,
      :near => 0.01,
      :far => 1000.0,
      :x => 0.0,
      :y => 0.0,
      :z => 0.0,
      :t_x => 0.0,
      :t_y => 0.0,
      :t_z => 0.0,
      :horizontal_angle => 90.0,
      :vertical_angle => 0.0,
      :distance => 120.0
    }

    self.mouse_x, self.mouse_y = self.width / 2, self.height / 2
    @last_mouse_x, @last_mouse_y = self.mouse_x, self.mouse_y
    @font = Gosu::Font.new(self, Gosu::default_font_name, 32)
  end
  
  def button_down(id)
    exit if id == Gosu::KbEscape
    if id == Gosu::MsWheelDown
      @camera[:distance] += 10.0
      @camera[:distance] = 180.0 if @camera[:distance] > 180.0
    elsif id == Gosu::MsWheelUp
      @camera[:distance] -= 10.0
      @camera[:distance] = 60.0 if @camera[:distance] < 60.0
    elsif id == Gosu::MsMiddle
      @camera[:distance] = 120.0
    end
  end

  def draw_plane
    size = 400.0
    glBindTexture(GL_TEXTURE_2D, @floor.gl_tex_info.tex_name)
    glBegin(GL_QUADS)
      glTexCoord2d(0.0, 0.0); glVertex3f(0.0, 0.0, 0.0)
      glTexCoord2d(1.0, 0.0); glVertex3f(size, 0.0, 0.0)
      glTexCoord2d(1.0, 1.0); glVertex3f(size, 0.0, size)
      glTexCoord2d(0.0, 1.0); glVertex3f(0.0, 0.0, size)
    glEnd
  end

  def draw_character
    glPushMatrix
    glTranslate(@character[:x], @character[:y], @character[:z])

    if button_down?(Gosu::KbUp)
      if button_down?(Gosu::KbRight)
        @character[:angle] = -@camera[:horizontal_angle] + 45.0
      elsif button_down?(Gosu::KbLeft)
        @character[:angle] = -@camera[:horizontal_angle] + 135.0
      else
        @character[:angle] = -@camera[:horizontal_angle] + 90.0
      end
    elsif button_down?(Gosu::KbDown)
      if button_down?(Gosu::KbRight)
        @character[:angle] = -@camera[:horizontal_angle] - 45.0
      elsif button_down?(Gosu::KbLeft)
        @character[:angle] = -@camera[:horizontal_angle] - 135.0
      else
        @character[:angle] = -@camera[:horizontal_angle] - 90.0
      end
    elsif button_down?(Gosu::KbLeft)
      @character[:angle] = -@camera[:horizontal_angle] - 180.0
    elsif button_down?(Gosu::KbRight)
      @character[:angle] = -@camera[:horizontal_angle]
    end
    
    glRotate(@character[:angle], 0, 1, 0)

    if @character[:rotation] != 0.0
      angle = @character[:rotation]
    else
      angle = 0.0
    end

    glRotate(-angle / 40.0, 1, 0, 0) # general bouncing
    @character[:head].draw(0.0, 24.0 + 4.0 + angle/70, 0.0)
    @character[:body].draw(0.0, 12.0 + angle/70, 0.0)
    @character[:right_arm].draw(-6.0, 23.5, 0.0, angle)
    @character[:left_arm].draw(6.0, 23.5, 0.0, -angle)
    @character[:left_leg].draw(2.0, 12.0, 0.0, angle)
    @character[:right_leg].draw(-2.0, 12.0, 0.0, -angle)
    glPopMatrix
  end

  def draw
    gl do
      glEnable(GL_TEXTURE_2D)
      glEnable(GL_DEPTH_TEST)
#      glClearColor(0.0, 1.0, 0.0, 0.0)
      #clear screen?
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

      #MODEL_VIEW_PROJECTION https://www.youtube.com/watch?v=-tonZsbHty8
      glMatrixMode(GL_PROJECTION)
      #set current matrix to identity matrix
      glLoadIdentity
      gluPerspective(@camera[:fovy], @camera[:ratio], @camera[:near], @camera[:far])

      #set current matrix to MODELVIEW which takes into account world and object transformations around camera
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity

      gluLookAt(@camera[:x], @camera[:y], @camera[:z], @camera[:t_x], @camera[:t_y], @camera[:t_z], 0, 1, 0)
      draw_plane

      draw_character
    end

    @font.draw("hor. ° : #{@camera[:horizontal_angle].round(2)} | vert. ° : #{@camera[:vertical_angle].round(2)} | distance : #{@camera[:distance]}", 0, 0, 0)
  end

  def update
    is_moving = false
    chara_speed = 0.0

    if button_down?(Gosu::KbEscape)
      exit
    end

    if button_down?(Gosu::KbUp)
      if button_down?(Gosu::KbRight)
        chara_speed = @character[:speed] * 0.8
      elsif button_down?(Gosu::KbLeft)
        chara_speed = @character[:speed] * 0.8
      else
        chara_speed = @character[:speed]
      end
    elsif button_down?(Gosu::KbDown)
      if button_down?(Gosu::KbRight)
        chara_speed = @character[:speed] * 0.8
      elsif button_down?(Gosu::KbLeft)
        chara_speed = @character[:speed] * 0.8
      else
        chara_speed = @character[:speed]
      end
    elsif button_down?(Gosu::KbRight)
      chara_speed = @character[:speed]
    elsif button_down?(Gosu::KbLeft)
      chara_speed = @character[:speed]
    end

    if button_down?(Gosu::KbUp)
      @character[:x] += chara_speed * Math::cos(@camera[:horizontal_angle] * Math::PI / 180.0)
      @character[:z] += chara_speed * Math::sin(@camera[:horizontal_angle] * Math::PI / 180.0)
      is_moving = true
    elsif button_down?(Gosu::KbDown)
      @character[:x] -= chara_speed * Math::cos(@camera[:horizontal_angle] * Math::PI / 180.0)
      @character[:z] -= chara_speed * Math::sin(@camera[:horizontal_angle] * Math::PI / 180.0)
      is_moving = true
    end

    if button_down?(Gosu::KbLeft)
      @character[:x] += chara_speed * Math::cos((@camera[:horizontal_angle] - 90.0) * Math::PI / 180.0)
      @character[:z] += chara_speed * Math::sin((@camera[:horizontal_angle] - 90.0) * Math::PI / 180.0)
      is_moving = true
    elsif button_down?(Gosu::KbRight)
      @character[:x] -= chara_speed * Math::cos((@camera[:horizontal_angle] - 90.0) * Math::PI / 180.0)
      @character[:z] -= chara_speed * Math::sin((@camera[:horizontal_angle] - 90.0) * Math::PI / 180.0)
      is_moving = true
    end

    if is_moving
      @character[:rotation] += @character[:inc]
      if @character[:rotation] > 40.0
        @character[:inc] = -5.0
      end

      if @character[:rotation] < -40.0
        @character[:inc] = 5.0
      end
    else
      @character[:rotation] = 0
    end

    mouse_sensitivity = 0.3
    if self.mouse_x != @last_mouse_x
      @camera[:horizontal_angle] += (self.mouse_x - @last_mouse_x) * mouse_sensitivity
      self.mouse_x = self.width / 2
      @last_mouse_x = self.mouse_x
      @camera[:horizontal_angle] = 359.0 if @camera[:horizontal_angle] < 0.0
      @camera[:horizontal_angle] = 0.0 if @camera[:horizontal_angle] > 359.0
    end

    if self.mouse_y != @last_mouse_y
      @camera[:vertical_angle] -= (self.mouse_y - @last_mouse_y) * mouse_sensitivity
      self.mouse_y = self.height / 2
      @last_mouse_y = self.mouse_y

      @camera[:vertical_angle] = 20.0 if @camera[:vertical_angle] > 20.0
      @camera[:vertical_angle] = -20.0 if @camera[:vertical_angle] < -20.0
    end

    update_camera
  end

  def update_camera
    @camera[:t_x] = @character[:x]
    @camera[:t_y] = 20.0 + @character[:y]
    @camera[:t_z] = @character[:z]

    @camera[:x] = @camera[:t_x] - @camera[:distance] * Math::cos(@camera[:horizontal_angle] * Math::PI / 180.0)
    @camera[:y] = 40.0 + @camera[:t_y] - @camera[:distance] * Math::sin(@camera[:vertical_angle] * Math::PI / 180.0)
    @camera[:z] = @camera[:t_z] - @camera[:distance] * Math::sin(@camera[:horizontal_angle] * Math::PI / 180.0)
  end
end
require 'pry'; binding.pry

Window.new.show
