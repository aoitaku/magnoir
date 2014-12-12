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

  def draw
    Window.drawFont(20,15,"PAUSE",Font20) if(@model.pause)
    Window.draw(WAREHOUSE_X,20,WAREHOUSE_LINE)
    @model.fishes.each_with_index do |f,i|
      Window.drawFont(WAREHOUSE_X+10,FISH_Y+i*20,"マグロ "+f.amount.to_s,Font20)
      Window.drawFont(WAREHOUSE_X+100,FISH_Y+i*20,f.limit_gage,Font20)
    end
    Window.drawFont(WAREHOUSE_X+10,400,"資金 "+@model.money.to_s,Font20)
    Window.drawFont(WAREHOUSE_X+10,20,@model.day.to_s+"日目",Font20)
    Window.drawFont(WAREHOUSE_X+10,40,@model.hour.to_s+":00",Font20)
    fonthash = {}
    fonthash = {color: YELLOW} if(@model.inbusiness?)
    Window.drawFont(WAREHOUSE_X+10,60,"相場 "+@model.rate.to_s,Font20,fonthash)
    4.times do |i|
      Window.draw(SHIPS_X[i],SHIPS_ALT_Y,SHIPS_ALT[i])
      Window.draw(SHIPS_X[i],SHIPS_Y,SHIPS[i])
      draw_ship_alt(i)
      draw_ship(i)
    end
  end

  def draw_ship_alt(n)
    Window.drawFont(SHIPS_X[n]+4,SHIPS_ALT_Y+7,"Lv."+@model.ships[n].level.to_s,Font16)
    alt_str = @model.ships[n].level > 0 ? "改造" : "購入"
    fonthash = {}
    fonthash = {color: RED} if(@model.money < @model.ships[n].levelup_cost)
    fonthash = {color: GRAY} if(@model.infishing?)
    Window.drawFont(SHIPS_X[n]+45,SHIPS_ALT_Y+10,alt_str+@model.ships[n].levelup_cost.to_s,Font12,fonthash)
  end

  def draw_ship(n)
    if(@model.ships[n].level==0)
      ship_status = ""
    else
      ship_status = @model.infishing? ? "作業中" : "停泊中"
    end
    Window.drawFont(SHIPS_X[n]+6,SHIPS_Y+10,ship_status,Font16)
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
