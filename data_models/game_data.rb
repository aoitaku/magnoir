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

  def timecount
    fluctuate_rate
    rot_fishes
    return_ships if hour == 6
    leave_ships if hour == 18
  end

  def fluctuate_rate
    @rate += d6(2) - 7 if inbusiness?
    @rate = 1 if @rate < 1
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
    enqueue_event(sell: n)
    fish = @fishes.delete_at(n)
    @money += fish.amount * @rate
  end

  def sell_all_fish
    return unless inbusiness?
    enqueue_event(sell_all: nil)
    fish = @fishes.lazy.map(&:amount).inject(0, &:+)
    @money += fish * @rate
    @fishes.clear
  end

  def publish
    @fishes.each(&:publish)
    @ships.each(&:publish)
    super
  end

  def alt_ship(n)
    return if @money < @ships[n].levelup_cost
    return if infishing?
    @money -= @ships[n].levelup_cost
    @ships[n].levelup
  end

  def d6(n)
    Game::d6(n)
  end

end
