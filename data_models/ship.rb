require_relative './fish'
require_relative './observable_model'

class Ship < ObservableModel

  attr_reader :level

  def initialize(level)
    super()
    @level = level
    @status = false
  end

  def levelup
    @level += 1
    enqueue_event(levelup: self)
    self
  end

  def levelup_cost
    if @level == 0
      1000
    else
      @level * 200
    end
  end

  def start_fishing
    @status = true if @level > 0
  end

  def fishing?
    @status
  end

  def finish_fishing
    fishing? and Fish.new(Game::d6(@level * 2)).tap do
      @status = false
    end or nil
  end

  def notify_standby
    publish_event(levelup: self)
  end

end
