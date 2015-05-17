require 'scanf.rb'
require 'wavefront'

class ObjModel
  def initialize(parent_window, filename, texture_filename)
    if texture_filename.is_a?(Gosu::Image)
      @texture = texture_filename
    else
      @texture = Gosu::Image.new(parent_window, texture_filename, true)
    end

    @triangles = Wavefront::File.new(filename).object.groups.first.smoothing_groups.first.triangles
  end

  def draw(x = 0.0, y = 0.0, z = 0.0, angle = 0.0)
    glPushMatrix
    glTranslate(x, y, z)
    glRotate(angle, 1, 0, 0)
    # "1.0 -" is used to reverse Y on texture
    glBindTexture(GL_TEXTURE_2D, @texture.gl_tex_info.tex_name)
    glBegin(GL_TRIANGLES)
      @triangles.each do |triangle|
        triangle.vertices.each do |vertex|
          glTexCoord2f(vertex.tex.x, 1.0 - vertex.tex.y)
          glNormal(*vertex.normal)
          glVertex3f(*vertex.position)
        end
      end
    glEnd
    glPopMatrix
  end
end