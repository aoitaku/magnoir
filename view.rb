class ViewBase

  def initialize(model, controller)
    @model = model
    @controller = controller
  end

end

class TitleView < ViewBase

  def initialize(model, controller)
    super
    @maguro = Image.load("maguro.png")
  end

  def draw
    Window.draw(0,0,@maguro)
    Window.drawFont(70, 10, "MAGURO", Font120)
    MENU_TEXT.each_with_index do |menu,i|
      fonthash = {}
      fonthash = {color: YELLOW} if(@controller.pos_menu == i)
      Window.drawFont(MENU_X,MENU_Y[i],menu,Font32,fonthash)
    end
  end

end

class GameView < ViewBase

  def draw
    Window.drawFont(20,15,"PAUSE",Font20) if(@game.pause)
    Window.draw(WAREHOUSE_X,20,WAREHOUSE_LINE)
    @game.fishes.each_with_index do |f,i|
      Window.drawFont(WAREHOUSE_X+10,FISH_Y+i*20,"マグロ "+f.amount.to_s,Font20)
      Window.drawFont(WAREHOUSE_X+100,FISH_Y+i*20,f.limit_gage,Font20)
    end
    Window.drawFont(WAREHOUSE_X+10,400,"資金 "+@game.money.to_s,Font20)
    Window.drawFont(WAREHOUSE_X+10,20,@game.day.to_s+"日目",Font20)
    Window.drawFont(WAREHOUSE_X+10,40,@game.hour.to_s+":00",Font20)
    fonthash = {}
    fonthash = {color: YELLOW} if(@game.inbusiness?)
    Window.drawFont(WAREHOUSE_X+10,60,"相場 "+@game.rate.to_s,Font20,fonthash)
    4.times do |i|
      Window.draw(SHIPS_X[i],SHIPS_ALT_Y,SHIPS_ALT[i])
      Window.draw(SHIPS_X[i],SHIPS_Y,SHIPS[i])
      draw_ship_alt(i)
      draw_ship(i)
    end
  end

  def draw_ship_alt(n)
    Window.drawFont(SHIPS_X[n]+4,SHIPS_ALT_Y+7,"Lv."+@game.ships[n].level.to_s,Font16)
    alt_str = @game.ships[n].level > 0 ? "改造" : "購入"
    fonthash = {}
    fonthash = {color: RED} if(@game.money < @game.ships[n].levelup_cost)
    fonthash = {color: GRAY} if(@game.infishing?)
    Window.drawFont(SHIPS_X[n]+45,SHIPS_ALT_Y+10,alt_str+@game.ships[n].levelup_cost.to_s,Font12,fonthash)
  end

  def draw_ship(n)
    if(@game.ships[n].level==0)
      ship_status = ""
    else
      ship_status = @game.infishing? ? "作業中" : "停泊中"
    end
    Window.drawFont(SHIPS_X[n]+6,SHIPS_Y+10,ship_status,Font16)
  end

end

class RankingView < ViewBase

  def draw
    Window.drawFont(200,40,"RANKING",Font60)
    @game.ranking.each_with_index do |r,i|
      Window.drawFont(250,120+40*i,(i+1).to_s+". "+r.to_s,Font32)
    end
    fonthash = {}
    fonthash = {color: YELLOW} if(@controller.pos_return)
    Window.drawFont(250,400,"戻る",Font20,fonthash)
  end

end

class EndingView < ViewBase

  def draw
    Window.drawFont(140,40,"GAME OVER",Font60)
    Window.drawFont(200,120,"score: "+@game.score.to_s,Font32)
    Window.drawFont(170,180,"ハイスコアを更新しました！",Font20,{color: [0,255,0]}) if(@game.new_rank)
    fonthash = {}
    fonthash = {color: YELLOW} if(@controller.pos_return)
    Window.drawFont(250,400,"戻る",Font20,fonthash)
  end

end
