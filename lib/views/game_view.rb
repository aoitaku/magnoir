require_relative 'viewbase'
require_relative '../observer_callback'

class GameView < ViewBase

  def initialize(model, controller)
    super
    ship_caption = -> *args {
      image Image.new(100, 30).box(0, 0, 100, 30, [255,255,255])
      TextLabel(:lv) {
        left 4
        top 7
        text "Lv.0"
        font Font16
        position :absolute
      }
      TextButton(:gradeup) {
        left 45
        top 10
        width 48
        height 12
        font Font12
      }
    }
    ship_state = -> *args {
      top 5
      image Image.new(100, 100).box(0, 0, 100, 100, [255,255,255])
      TextLabel(:stat) {
        left 6
        top 10
        font Font16
      }
    }
    @ui = SpriteUI.build {
      TextLabel(:pause) {
        font Font20
        text "PAUSE"
        left 20
        top 15
        position :absolute
      }
      ContainerBox(:warehouse) {
        left 480
        top 20
        image Image.new(1,420).line(0,0,0,420,[255,255,255])
        position :absolute
        ContainerBox(:fishes) {
          left 10
          top 70
          position :absolute
          add_event_handler :mouse_left_push, -> target {
            controller.on_fish_click(components.map {|component|
              component.find(:amount)
            }.find_index {|component|
              target == component
            })
          }
        }
        TextLabel(:money) {
          left 10
          top 380
          text "資金 600"
          font Font20
          position :absolute
        }
        TextLabel(:day) {
          left 10
          text "1日目"
          font Font20
          position :absolute
        }
        TextLabel(:time) {
          left 10
          top 20
          text "0:00"
          font Font20
          position :absolute
        }
        TextLabel(:rate) {
          left 10
          top 40
          text "相場 10"
          font Font20
          position :absolute
        }
      }
      ContainerBox(:ships) {
        width 430
        height 140
        ContainerBox {
          left 20
          top 40
          position :absolute
          ContainerBox(&ship_caption)
          ContainerBox(&ship_state)
        }
        ContainerBox {
          left 130
          top 40
          position :absolute
          ContainerBox(&ship_caption)
          ContainerBox(&ship_state)
        }
        ContainerBox {
          left 240
          top 40
          position :absolute
          ContainerBox(&ship_caption)
          ContainerBox(&ship_state)
        }
        ContainerBox {
          left 350
          top 40
          position :absolute
          ContainerBox(&ship_caption)
          ContainerBox(&ship_state)
        }
        add_event_handler :mouse_left_push, -> target {
          controller.on_ship_click(components.map {|component|
            component.find(:gradeup)
          }.find_index {|component|
            target == component and not component.disable?
          })
        }
      }
    }
    @ui.layout
    @ui.find(:ships).components.each_with_index do |ship, n|
      model.ships[n].add_observer(ObserverCallback.new {|event|
        event_type, value = *event.to_a.first
        case event_type
        when :levelup
          ship.find(:lv).text = "Lv.#{value.level.to_s}"
          if value.level > 0
            ship.find(:gradeup).text = "改造#{value.levelup_cost.to_s}"
            ship.find(:stat).text = "停泊中" if value.level == 1
          else
            ship.find(:gradeup).text = "購入#{value.levelup_cost.to_s}"
          end
        end
      })
      model.ships[n].notify_standby
    end
    time = @ui.find(:time)
    day = @ui.find(:day)
    rate = @ui.find(:rate)
    money = @ui.find(:money)
    ships = @ui.find(:ships).components
    fishes = @ui.find(:fishes).components
    model.add_observer(ObserverCallback.new {|event|
      event_type, value = *event.to_a.first
      case event_type
      when :new_day
        day.text = "#{@model.day.to_s}日目"
      when :new_hour
        time.text = "#{value.to_s}:00"
      when :new_rate
        rate.text = "相場 #{value.to_s}"
      when :new_money
        money.text = "資金 #{value.to_s}"
        ships.each_with_index {|ship, n|
          enable_ship_upgrade(ship, n)
        } unless model.infishing?
      when :start_fishing
        ships.each_with_index do |ship, n|
          disable_ship_upgrade(ship)
          if model.ships[n].level > 0
            ship.find(:stat).text = "作業中"
          end
        end
      when :start_business
        fishes.each {|fish| fish.find(:amount).enable }
      when :finish_business
        fishes.each {|fish| fish.find(:amount).disable }
      when :finish_fishing
        ships.each_with_index do |ship, n|
          enable_ship_upgrade(ship, n)
          if model.ships[n].level > 0
            ship.find(:stat).text = "停泊中"
          end
        end
      when :sell_all
        fishes.clear
      when :sell, :dispose
        fishes.delete_at(value)
      end
    })
    ships.each_with_index {|ship, n|
      enable_ship_upgrade(ship, n)
    }
    @mouse_event_dispatcher = SpriteUI::MouseEventDispatcher.new(@ui)
  end

  def enable_ship_upgrade(ship, n)
    if enough_for_upgrade?(n)
      ship.find(:gradeup).color = nil
      ship.find(:gradeup).enable
    else
      ship.find(:gradeup).color = [255,255,63,0]
      ship.find(:gradeup).disable
    end
  end

  def disable_ship_upgrade(ship)
    ship.find(:gradeup).color = nil
    ship.find(:gradeup).disable
  end

  def enough_for_upgrade?(n)
    @model.money >= @model.ships[n].levelup_cost
  end

  def new_fish(fish_model)
    fish = SpriteUI.build {
      width 200
      height 20
      TextButton(:amount) {
        text "マグロ #{fish_model.amount.to_s}"
        width 100
        height 20
        font Font20
        position :absolute
      }
      TextLabel(:gauge) {
        text fish_model.limit_gauge
        left 90
        font Font20
        position :absolute
      }
    }.tap do |fish|
      fish_model.add_observer(ObserverCallback.new {|event|
        event_type, value = *event.to_a.first
        case event_type
        when :limit
          fish.find(:gauge).text = value
        end
      })
      fish.find(:amount).disable
    end
  end

  def update
    @mouse_event_dispatcher.update
    @ui.find(:pause).visible = @model.pause?
    fishes = @ui.find(:fishes)
    if @model.fishes.size > fishes.components.size
      @model.fishes.drop(fishes.components.size).each do |fish_model|
        fishes.add(new_fish(fish_model))
      end
    end
    @ui.layout
    @mouse_event_dispatcher.dispatch
  end

  def draw
    @ui.draw
  end

end
