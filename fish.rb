require 'observer'

class Fish

  include Observable

  attr_reader :amount,:limit

  def initialize(amount)
    @amount = amount
    @limit = 72
    @events = []
  end

  def rot
    @limit -= 1
    enqueue_event(limit: limit_gauge)
  end

  def enqueue_event(event)
    @events << event
  end

  def publish_event
    @events.each {|event|
      changed
      notify_observers(event)
    }
    @events.clear
  end

  def limit_gauge
    str = ""
    (@limit/6).times do
      str += "|"
    end
    str
  end
  alias limit_gage limit_gauge

end
