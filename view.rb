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
    @maguro = Sprite.new(0, 0, Image.load("maguro.png"))
    @ui = SpriteUI.build {
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
    @maguro.draw
    @ui.draw
  end

end

class GameView < ViewBase

  def initialize(model, controller)
    super
    @pause = UI::TextLabel.new
    @pause.font = Font20
    @pause.text = "PAUSE"
    @pause.x = 20
    @pause.y = 15
    @line = Sprite.new(480, 20, Image.new(1,420).line(0,0,0,420,[255,255,255]))
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
        x 490
        position :absolute
        ContainerBox(:fishes) {
          y 90
          position :absolute
        }
        TextLabel(:money) {
          y 400
          text "資金 600"
          font Font20
          position :absolute
        }
        TextLabel(:day) {
          y 20
          text "1日目"
          font Font20
          position :absolute
        }
        TextLabel(:time) {
          y 40
          text "0:00"
          font Font20
          position :absolute
        }
        TextLabel(:rate) {
          y 60
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
    @line.draw
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

  def draw
    Window.drawFont(200,40,"RANKING",Font60)
    @model.ranking.each_with_index do |r,i|
      Window.drawFont(250,120+40*i,(i+1).to_s+". "+r.to_s,Font32)
    end
    fonthash = {}
    fonthash = {color: YELLOW} if(@controller.pos_return)
    Window.drawFont(250,400,"戻る",Font20,fonthash)
  end

end

class EndingView < ViewBase

  def initialize(model, controller)
    super
  end

  def draw
    Window.drawFont(140,40,"GAME OVER",Font60)
    Window.drawFont(200,120,"score: "+@model.score.to_s,Font32)
    Window.drawFont(170,180,"ハイスコアを更新しました！",Font20,{color: [0,255,0]}) if(@model.new_rank)
    fonthash = {}
    fonthash = {color: YELLOW} if(@controller.pos_return)
    Window.drawFont(250,400,"戻る",Font20,fonthash)
  end

end
