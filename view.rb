class ViewBase

  def initialize(model, controller)
    @model = model
    @controller = controller
  end

  def update
  end

end

class TitleView < ViewBase

  def initialize(model, controller)
    super
    @ui = SpriteUI.build {
      image Image.load("maguro.png")
      TextLabel {
        x 80
        y 10
        text "MAGURO"
        font Font120
      }
      ContainerBox {
        position :absolute
        x 240
        y 240
        TextButton(:start) {
          text "START"
          font Font32
        }
        TextButton(:ranking) {
          text "RANKING"
          font Font32
        }
        TextButton(:exit) {
          text "EXIT"
          font Font32
        }
      }
    }
    @ui.layout
    @mouse_event_dispatcher = SpriteUI::MouseEventDispatcher.new(@ui)
  end

  def update
    @mouse_event_dispatcher.update
    @mouse_event_dispatcher.dispatch
  end

  def draw
    @ui.draw
  end

end

class GameView < ViewBase

  def initialize(model, controller)
    super
    @pause = SpriteUI.build {
      TextLabel {
        font Font20
        text "PAUSE"
        x 20
        y 15
      }
    }
    ship_caption = proc {
      image Image.new(100, 30).box(0, 0, 100, 30, [255,255,255])
      TextLabel(:lv) {
        x 4
        y 7
        text "Lv.0"
        font Font16
        position :absolute
      }
      TextButton(:gradeup) {
        x 45
        y 10
        width 48
        height 12
        font Font12
      }
    }
    ship_state = proc {
      y 5
      image Image.new(100, 100).box(0, 0, 100, 100, [255,255,255])
      TextLabel(:stat) {
        x 6
        y 10
        font Font16
      }
    }
    @ui = SpriteUI.build {
      ContainerBox(:warehouse) {
        x 480
        y 20
        image Image.new(1,420).line(0,0,0,420,[255,255,255])
        position :absolute
        ContainerBox(:fishes) {
          x 10
          y 70
          position :absolute
        }
        TextLabel(:money) {
          x 10
          y 380
          text "資金 600"
          font Font20
          position :absolute
        }
        TextLabel(:day) {
          x 10
          text "1日目"
          font Font20
          position :absolute
        }
        TextLabel(:time) {
          x 10
          y 20
          text "0:00"
          font Font20
          position :absolute
        }
        TextLabel(:rate) {
          x 10
          y 40
          text "相場 10"
          font Font20
          position :absolute
        }
      }
      ContainerBox(:ships) {
        ContainerBox {
          x 20
          y 40
          ContainerBox(&ship_caption)
          ContainerBox(&ship_state)
        }
        ContainerBox {
          x 130
          y 40
          ContainerBox(&ship_caption)
          ContainerBox(&ship_state)
        }
        ContainerBox {
          x 240
          y 40
          ContainerBox(&ship_caption)
          ContainerBox(&ship_state)
        }
        ContainerBox {
          x 350
          y 40
          ContainerBox(&ship_caption)
          ContainerBox(&ship_state)
        }
      }
    }
    @ui.layout
    @mouse_event_dispatcher = SpriteUI::MouseEventDispatcher.new(@ui)
  end

  def fish_container
    SpriteUI.build {
      height 20
      TextButton(:amount) {
        width 100
        height 20
        font Font20
        position :absolute
      }
      TextLabel(:gauge) {
        x 90
        font Font20
        position :absolute
      }
    }
  end

  def update
    @mouse_event_dispatcher.update
    fishes = @ui.find(:fishes)
    if @model.fishes.size > fishes.components.size
      (@model.fishes.size - fishes.components.size).times do |i|
        fishes.add(fish_container)
      end
      fishes.layout
    elsif @model.fishes.size < fishes.components.size
      fishes.components.pop(fishes.components.size - @model.fishes.size)
      fishes.layout
    end
    fishes.components.each_with_index do |fish, n|
      fish.find(:amount).text = fish_text(@model.fishes[n])
      if @model.inbusiness?
        fish.find(:amount).enable
      else
        fish.find(:amount).disable
      end
      fish.find(:gauge).text = fish_gauge(@model.fishes[n])
    end
    @ui.find(:ships).components.each_with_index do |ship, n|
      ship.find(:lv).text = lv_text(n)
      ship.find(:gradeup).text = ship_caption_text(n)
      if @model.infishing?
        ship.find(:gradeup).color = nil
        ship.find(:gradeup).disable
      elsif @model.money < @model.ships[n].levelup_cost
        ship.find(:gradeup).color = [255,255,63,0]
        ship.find(:gradeup).disable
      else
        ship.find(:gradeup).color = nil
        ship.find(:gradeup).enable
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
    @pause.draw if @model.pause
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

class RankingView < ViewBase

  def initialize(model, controller)
    super
    @ui = SpriteUI.build {
      TextLabel {
        x 200
        y 40
        text "RANKING"
        font Font60
        position :absolute
      }
      TextButton {
        x 250
        y 400
        text "戻る"
        font Font20
        position :absolute
      }
      ContainerBox(:ranking)
    }
    ranking = @ui.find(:ranking)
    @model.ranking.each_with_index do |r,i|
      ranking.add SpriteUI.build {
        TextLabel {
          x 250
          y 120 + 40 * i
          text "#{(i+1).to_s}. #{r.to_s}"
          font Font32
          position :absolute
        }
      }
    end
    @ui.layout
    @mouse_event_dispatcher = SpriteUI::MouseEventDispatcher.new(@ui)
  end

  def update
    @mouse_event_dispatcher.update
    @mouse_event_dispatcher.dispatch
  end

  def draw
    @ui.draw
  end

end

class EndingView < ViewBase

  def initialize(model, controller)
    super
    score = @model.score.to_s
    @highscore = SpriteUI.build {
      TextLabel {
        x 170
        y 180
        text "ハイスコアを更新しました！"
        font Font20
        color [255,0,255,0]
        position :absolute
      }
    }
    @ui = SpriteUI.build {
      TextLabel {
        x 140
        y 40
        text "GAME OVER"
        font Font60
        position :absolute
      }
      TextLabel {
        x 200
        y 120
        text "score: #{score}"
        font Font32
        position :absolute
      }
      TextButton {
        x 250
        y 400
        text "戻る"
        font Font20
        position :absolute
      }
    }
    @ui.layout
    @mouse_event_dispatcher = SpriteUI::MouseEventDispatcher.new(@ui)
  end

  def update
    @mouse_event_dispatcher.update
    @mouse_event_dispatcher.dispatch
  end

  def draw
    @highscore.draw if @model.new_rank
    @ui.draw
  end

end
