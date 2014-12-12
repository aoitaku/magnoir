class Scene

  Exit = :exit

  attr_accessor :next_scene

  def initialize
    @next_scene = nil
    init
  end

  def init
  end

  def quit
  end

  def update
  end

  def render
  end

end
