class ObserverCallback

  def initialize(callback=Proc.new)
    @callback = callback
  end

  def update(value)
    @callback.(value)
  end

end
