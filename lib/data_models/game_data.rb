require_relative './fish'
require_relative './ship'
require_relative './observable_model'

class GameData < ObservableModel

  attr_accessor :time
  attr_reader :money, :rate, :ships, :fishes

  def initialize
    super
    @pause = true
    @time = 0
    @money = 600
    @rate = 10
    @ships = [Ship.new(1), Ship.new(0), Ship.new(0), Ship.new(0)]
    @fishes = []
  end

  def pause?
    @pause
  end

  def toggle_pause
    @pause = !@pause
  end

  def hour
    (@time / FRAME) % 24
  end

  def day
    @time / (FRAME * 24) + 1
  end

  def update
    publish
    return if pause?
    hour = self.hour
    day = self.day
    @time += 1
    if hour != self.hour
      publish_event(game_end: self) if day == END_DAY
      enqueue_event(new_hour: hour)
      enqueue_event(new_day: day) if day != self.day
      timecount
    end
  end

  def timecount
    fluctuate_rate if inbusiness?
    rot_fishes
    case hour
    when 6
      enqueue_event(start_fishing: true)
      leave_ships
    when 11
      enqueue_event(start_business: true)
    when 15
      enqueue_event(finish_business: true)
    when 18
      enqueue_event(finish_fishing: true)
      return_ships
    end
  end

  def fluctuate_rate
    @rate += d6(2) - 7
    @rate = 1 if @rate < 1
    enqueue_event(new_rate: @rate)
  end

  def rot_fishes
    @fishes.delete_if.with_index do |fish, index|
      fish.rot.limit.zero? and tap do
        pay_dispose_cost(fish.dispose_cost)
        enqueue_event(dispose: index)
      end
    end
  end

  def pay_dispose_cost(cost)
    @money -= cost
    enqueue_event(new_money: @money)
  end

  def leave_ships
    @ships.each(&:start_fishing)
  end

  def return_ships
    @fishes.push(*@ships.lazy.map(&:finish_fishing).reject(&:!))
  end

  def inbusiness?
    (11..15) === hour
  end

  def infishing?
    (6..18) === hour
  end

  def sell_fish(n)
    return unless inbusiness?
    fish = @fishes.delete_at(n)
    @money += fish.amount * @rate
    enqueue_event(sell: n)
    enqueue_event(new_money: @money)
  end

  def sell_all_fish
    return unless inbusiness?
    fish = @fishes.lazy.map(&:amount).inject(0, &:+)
    @money += fish * @rate
    @fishes.clear
    enqueue_event(sell_all: true)
    enqueue_event(new_money: @money)
  end

  def publish
    @fishes.each(&:publish)
    @ships.each(&:publish)
    super
  end

  def alt_ship(n)
    return if infishing?
    return if @money < @ships[n].levelup_cost
    @money -= @ships[n].levelup_cost
    @ships[n].levelup
    enqueue_event(new_money: @money)
  end

  def d6(n)
    Game::d6(n)
  end

end
