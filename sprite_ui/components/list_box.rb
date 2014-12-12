class UI::ListBox < SpriteUI::Base

  attr_accessor :font

  def initialize(id='', x=0, y=0, *argv)
    super(id, x, y)
    @items = []
    @font = Font.default
  end

  def draw
    @items.each_with_index do |item, i|
      TextRenderer.draw(x, y + i * item_height, item, context)
    end
  end

  def font=(font)
    case font
    when Font
      @font = font
    when String
      @font = Font.new(Font.default.size, font)
    else
      @font = Font.new(Font.default.size, font.to_s)
    end
  end

  def item_height
    line_height
  end

  def line_height
    font.size
  end

  def context
    Context[target, font]
  end

  def content_width
    if @items.empty?
      super
    else
      
    end
  end

  def content_height
    if @items.empty?
      super
    else
      
    end
  end

end
