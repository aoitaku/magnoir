require 'observer'

class Fish

  include Observable

  attr_reader :amount,:limit

  def initialize(amount)
    @amount = amount
    @limit = 72
  end

  def rot
    @limit -= 1
    changed
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
