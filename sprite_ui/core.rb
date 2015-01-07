require 'dxruby'
require_relative 'core/ui'

module SpriteUI

  def self.build(&proc)
    UI.build(Container, &proc)
  end

  def self.equip(mod)
    Base.__send__ :include, mod
  end

  class Base < Sprite

    include UI::Control

    attr_accessor :id
    attr_accessor :position, :top, :left
    attr_writer :width, :height, :visible

    def initialize(id='', *args)
      super(0, 0)
      self.id = id
      self.position = :relative
      self.visible = true
      self.top = 0
      self.left = 0
      init_control
    end

    def visible?
      @visible
    end

    def width
      if @width
        @width
      else
        content_width
      end
    end

    def content_width
      if image
        image.width
      else
        0
      end
    end

    def height
      if @height
        @height
      else
        content_height
      end
    end

    def content_height
      if image
        image.height
      else
        0
      end
    end

    def layout_width
      case position
      when :absolute
        0
      else
        width
      end
    end

    def layout_height
      case position
      when :absolute
        0
      else
        height
      end
    end

    def draw
      draw_image(x, y, image) if visible?
    end

    def draw_image(x, y, image)
      (target or Window).draw(x, y, image) if image
    end

    def update
    end

    def layout(ox=0, oy=0, &block)
      self.x = ox + left
      self.y = oy + top
      yield if block_given?
      self.collision = [0, 0, width, height]
    end

  end

  class Container < Base

    include UI::Container

    def initialize(*args)
      super
      init_container
    end

    def draw
      super
      components.each(&:draw) if visible?
    end

    def update
      super
      components.each(&:update)
    end

    def layout(ox=0, oy=0)
      super(ox, oy) do
        height = components.inject(0) do |height, component|
          component.layout(self.x, self.y + height)
          height + component.layout_height
        end
        if self.height == 0
          self.height = height
        end
        if self.width == 0
          self.width = components.inject(0) do |width, component|
            [width, component.layout_width].max
          end
        end
      end
    end

  end

end
