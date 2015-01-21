require_relative './observable_model'

class Fish < ObservableModel

  attr_reader :amount,:limit

  def initialize(amount)
    super()
    @amount = amount
    @limit = 72
  end

  def rot
    @limit -= 1
    enqueue_event(limit: limit_gauge)
    self
  end

  def dispose_cost
    amount * 10
  end

  def limit_gauge
    "|" * (@limit / 6)
  end
  alias limit_gage limit_gauge

end
