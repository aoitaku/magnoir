require 'observer'

class ObservableModel

  include Observable

  attr_reader :events
  private :events

  def initialize
    @events = []
  end

  def publish
    events.each {|event| publish_event(event) }.clear
  end

  def publish_event(event)
    changed
    notify_observers(event)
  end
  private :publish_event

  def enqueue_event(event)
    events << event
  end
  private :enqueue_event

end
