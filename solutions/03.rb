module Graphics
  module Renderers
    class Html
      def self.header
        "<!DOCTYPE html>
                <html>
                <head>
                  <title>Rendered Canvas</title>
                  <style type=\"text/css\">
                    .canvas {
                      font-size: 1px;
                      line-height: 1px;
                    }
                    .canvas * {
                      display: inline-block;
                      width: 10px;
                      height: 10px;
                      border-radius: 5px;
                    }
                    .canvas i {
                      background-color: #eee;
                    }
                    .canvas b {
                      background-color: #333;
                    }
                  </style>
                </head>
                <body>
                  <div class=\"canvas\">\n"
      end

      def self.footer
        "         </div>
                </body>
                </html>"
      end
    end

    class Ascii
    end
  end

  class Canvas
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
      @world = Array.new(height).map { |height| height = Array.new(width) }
      @rendered = ""
    end

    def set_pixel(x, y)
      @world[y][x] = true
    end

    def pixel_at?(x, y)
      @world[y][x]
    end

    def draw(object)
      object.set_points
      object.coordinates.each { |point| @world[point.last][point.first] = true }
    end

    def render_as(render)
      if render == Graphics::Renderers::Ascii
        render_as_ascii(render, "\n", "@", "-")
      elsif render == Graphics::Renderers::Html
        render_as_html(render, "<br>\n", "<b></b>", "<i></i>")
      end
    end

    def render_as_ascii(render, new_line, point, empty)
      @rendered = ""
      render_line_as(new_line, point, empty)
      @rendered.strip
    end

    def render_as_html(render, new_line, point, empty)
      @rendered = ""
      render_line_as(new_line, point, empty)
      render.header + @rendered.chomp("<br>\n") + render.footer
    end

    def render_line_as(new_line, point, empty)
      @world.each do |line|
        render_line_item_as(line, point, empty)
        @rendered += new_line
      end
    end

    def render_line_item_as(line, point, empty)
      line.each { |item| replace(item, point, empty) }
    end

    def replace(item, point, empty)
      item ? @rendered += point : @rendered += empty
    end

  end

  class Point
    attr_reader :x, :y, :coordinates

    def initialize(x, y)
      @x = x
      @y = y
      @coordinates = []
    end

    def set_points
      @coordinates << [x, y]
    end

    def hash
      [x, y].hash
    end

    def eql?(other)
      hash == other.hash
    end

    alias :== :eql?

  end

  class Line
    attr_reader :from, :to, :coordinates

    def initialize(first, second)
      @coordinates = []
      @from = vertical?(first, second) ? upper(first, second) : left(first, second)
      @to = @from == first ? second : first
    end

    def upper(first, second)
      first.y <= second.y ? first : second
    end

    def left(first, second)
      first.x <= second.x ? first : second
    end

    def vertical?(first, second)
      first.x - second.x == 0
    end

    def set_points
      if vertical?(from, to)
        from.y.upto(to.y).each { |point| @coordinates << [from.x, point] }
      elsif ((to.y.to_f - from.y) / (to.x - from.x)).abs < 1
        bresenham_by_column
      else
        bresenham_by_row
      end
    end

    def bresenham_by_row
      error = (to.x.to_f - from.x) / (to.y - from.y)

      range = from.y > to.y ? to.y.upto(from.y) : from.y.upto(to.y)

      range.each do |row|
        @coordinates << [(error * (row - from.y) + from.x).round, row]
      end
    end

    def bresenham_by_column
      error = (to.y.to_f - from.y) / (to.x - from.x)

      from.x.upto(to.x).each do |column|
        @coordinates << [column, (error * (column - from.x) + from.y).round]
      end
    end

    def hash
      [from, to].hash
    end

    def eql?(other)
      hash == other.hash
    end

    alias :== :eql?

  end

  class Rectangle
    attr_reader :left, :right, :coordinates

    def initialize(first, second)
      @left = vertical?(first, second) ? upper(first, second) : left_point(first, second)
      @right = @left == first ? second : first
      @height = (right.y - left.y).abs
      @width = (right.x - left.x).abs
      @coordinates = []
    end

    def vertical?(first, second)
      first.x - second.x == 0
    end

    def upper(first, second)
      first.y <= second.y ? first : second
    end

    def left_point(first, second)
      first.x <= second.x ? first : second
    end

    def top_left
      right.y - left.y < 0 ? Point.new(left.x, left.y - @height) : left
    end

    def top_right
      @width == 0 ? top_left : Point.new(top_left.x + @width, top_left.y)
    end

    def bottom_left
      right.y - left.y < 0 ? left : Point.new(left.x, left.y + @height)
    end

    def bottom_right
      @width == 0 ? bottom_left : Point.new(bottom_left.x + @width, bottom_left.y)
    end

    def set_points
      top_left.y.upto(bottom_left.y).each do |point|
        @coordinates << [top_left.x, point]
        @coordinates << [top_right.x, point]
      end

      top_left.x.upto(top_right.x).each do |point|
        @coordinates << [point, top_left.y]
        @coordinates << [point, bottom_left.y]
      end
    end

    def hash
      [top_left, top_right, bottom_left, bottom_right].hash
    end

    def eql?(other)
      hash == other.hash
    end

    alias :== :eql?

  end
end

canvas = Graphics::Canvas.new 30, 30
Graphics::Rectangle.new(Graphics::Point.new(10, 15), Graphics::Point.new(10, 5)).hash
Graphics::Line.new(Graphics::Point.new(10, 15), Graphics::Point.new(10, 5)).hash


# canvas.set_pixel 0, 0
# canvas.set_pixel 1, 1
# canvas.set_pixel 2, 10
# canvas.draw Graphics::Line.new(Graphics::Point.new(5,9),Graphics::Point.new(9,9))
# canvas.draw Graphics::Rectangle.new(Graphics::Point.new(5, 5), Graphics::Point.new(5, 10))

# puts canvas.render_as(Graphics::Renderers::Html)
puts canvas.render_as(Graphics::Renderers::Ascii)


# line = Graphics::Line.new(Graphics::Point.new(8,10),Graphics::Point.new(9,10))
# line.from
kvad = Graphics::Rectangle.new(Graphics::Point.new(1, 10), Graphics::Point.new(10, 1))
kvad.left
kvad.right
kvad.top_left
kvad.top_right
kvad.bottom_left
kvad.bottom_right

# a = Graphics::Point.new(2,3)
# b = Graphics::Point.new(15,30)
# a.hash
# b.hash
# Graphics::Point.new(20,15).hash
# Graphics::Point.new(0,1).hash
# Graphics::Line.new(Graphics::Point.new(4, 15), Graphics::Point.new(7, 15)).hash
# Graphics::Line.new(Graphics::Point.new(4, 15), Graphics::Point.new(7, 15)).hash

Graphics::Rectangle.new(Graphics::Point.new(1, 0), Graphics::Point.new(10, 10)).eql? Graphics::Rectangle.new(Graphics::Point.new(1, 10), Graphics::Point.new(10, 0))

module Graphics
  canvas = Canvas.new 30, 40

  # Door frame and window
  canvas.draw Rectangle.new(Point.new(3, 3), Point.new(18, 12))
  canvas.draw Rectangle.new(Point.new(1, 1), Point.new(20, 28))

  # Door knob
  canvas.draw Line.new(Point.new(4, 15), Point.new(7, 15))
  canvas.draw Point.new(4, 16)

  # Big "R"
  canvas.draw Line.new(Point.new(8, 5), Point.new(8, 10))
  canvas.draw Line.new(Point.new(9, 5), Point.new(12, 5))
  canvas.draw Line.new(Point.new(9, 7), Point.new(12, 7))
  canvas.draw Point.new(13, 6)
  canvas.draw Line.new(Point.new(12, 8), Point.new(13, 10))

  puts canvas.render_as(Graphics::Renderers::Html)
  puts canvas.render_as(Graphics::Renderers::Ascii)
end
