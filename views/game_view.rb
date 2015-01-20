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
          }.reject {|component|
            component.disable? 
          }.find_index {|component|
            target == component
          })
        }
      }
    }
    @ui.layout
    @ui.find(:ships).components.each_with_index {|ship, n|
      model.ships[n].add_observer(ObserverCallback.new {|value|
        ship.find(:lv).text = "Lv.#{value.to_s}"
        if value > 0
          ship.find(:gradeup).text = "改造#{model.ships[n].levelup_cost.to_s}"
        else
          ship.find(:gradeup).text = "購入#{model.ships[n].levelup_cost.to_s}"
        end
      })
      model.ships[n].changed
      model.ships[n].notify_observers(model.ships[n].level)
    }
    fishes = @ui.find(:fishes)
    model.add_observer(ObserverCallback.new {|event|
      event_type, value = *event.to_a.first
      case event_type
      when :sell_all
        fishes.components.clear
      when :sell, :dispose
        fishes.components.delete_at(value)
      end
    })
    @mouse_event_dispatcher = SpriteUI::MouseEventDispatcher.new(@ui)
  end

  def fish_container(amount, gauge)
    SpriteUI.build {
      width 200
      height 20
      TextButton(:amount) {
        text amount
        width 100
        height 20
        font Font20
        position :absolute
      }
      TextLabel(:gauge) {
        text gauge
        left 90
        font Font20
        position :absolute
      }
    }
  end

  def update
    @mouse_event_dispatcher.update
    @ui.find(:pause).visible = @model.pause
    fishes = @ui.find(:fishes)
    if @model.fishes.size > fishes.components.size
      @model.fishes[fishes.components.size..(@model.fishes.size-1)].each do |f|
        fish = fish_container(fish_text(f), fish_gauge(f))
        f.add_observer(ObserverCallback.new {|event|
          event_type, value = *event.to_a.first
          case event_type
          when :limit
            fish.find(:gauge).text = value
          end
        })
        fishes.add(fish)
      end
    end
    @ui.layout
    fishes.components.each_with_index do |fish, n|
      if @model.inbusiness?
        fish.find(:amount).enable
      else
        fish.find(:amount).disable
      end
    end
    @ui.find(:ships).components.each_with_index do |ship, n|
      if @model.infishing?
        ship.find(:gradeup).color = nil
        ship.find(:gradeup).disable
      else
        if @model.money < @model.ships[n].levelup_cost
          ship.find(:gradeup).color = [255,255,63,0]
          ship.find(:gradeup).disable
        else
          ship.find(:gradeup).color = nil
          ship.find(:gradeup).enable
        end
      end
      ship.find(:stat).text = ship_state_text(n)
    end
    @ui.find(:money).text = money_text
    @ui.find(:day).text = day_text
    @ui.find(:time).text = time_text
    @ui.find(:rate).text = rate_text
    @mouse_event_dispatcher.dispatch
  end

  def draw
    @ui.draw
  end

  def fish_text(f)
    "マグロ #{f.amount.to_s}"
  end

  def fish_gauge(f)
    f.limit_gage
  end

  def lv_text(n)
    "Lv.#{@model.ships[n].level.to_s}"
  end

  def money_text
    "資金 #{@model.money.to_s}"
  end

  def day_text
    "#{@model.day.to_s}日目"
  end

  def time_text
    "#{@model.hour.to_s}:00"
  end

  def rate_text
    "相場 #{@model.rate.to_s}"
  end

  def ship_caption_text(n)
    if @model.ships[n].level > 0
      "改造#{@model.ships[n].levelup_cost.to_s}"
    else
      "購入#{@model.ships[n].levelup_cost.to_s}"
    end
  end

  def ship_state_text(n)
    if @model.ships[n].level == 0
      ""
    elsif @model.infishing?
      "作業中"
    else
      "停泊中"
    end
  end

end
