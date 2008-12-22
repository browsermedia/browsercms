class Shape
  attr_accessor :x, :y

  def initialize(x, y)
   @x = x
   @y = y
  end

  def moveTo(x, y)
    @x = x
    @y = y
  end
  
  def rMoveTo(x, y)
    moveTo(x + @x, y + @y)
  end
end

class Rectangle < Shape
  attr_accessor :width, :height

  def initialize(initx, inity, initwidth, initheight)
    super(initx, inity)
    @width = initwidth
    @height = initheight
  end

  def draw
    puts "Drawing a Rectangle at:(#{x}, #{y}), width #{width}, height #{height}"
  end
end

class Circle < Shape
  attr_accessor :radius

  def initialize(initx, inity, initradius)
    super(initx, inity)
    @radius = initradius
  end

  def draw
    puts "Draw a Circle at:(#{x}, #{y}), radius #{radius}"
  end
end

# create a collection containing various shape instances
scribble = [Rectangle.new(10, 20, 5, 6), Circle.new(15, 25, 8)]

# iterate through the collection and handle shapes polymorphically
scribble.each do |ashape|
  ashape.draw
  ashape.rMoveTo(100, 100)
  ashape.draw
end

# access a rectangle specific function
arectangle = Rectangle.new(0, 0, 15, 15)
arectangle.width=30
arectangle.draw

