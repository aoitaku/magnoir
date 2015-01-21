$LOAD_PATH << File.dirname(File.expand_path(__FILE__))

require 'dxruby'
require 'sprite_ui'
require 'game'
require 'view'
require 'controller'

RED = [255,0,0]
YELLOW = [255,255,0]
GRAY = [90,90,90]
END_DAY = 15
FRAME = 15
MENU_X = 240
MENU_Y = [360,392,424]
WAREHOUSE_X = 480
MENU_TEXT = ["START","RANKING","EXIT"]
WAREHOUSE_LINE = Image.new(1,420).line(0,0,0,420,[255,255,255])
FISH_Y = 90
SHIPS = [Image.new(100,100).box(0,0,100,100,[255,255,255])]*4
SHIPS_ALT = [Image.new(100,30).box(0,0,100,30,[255,255,255])]*4
SHIPS_X = [20,130,240,350]
SHIPS_Y = 75
SHIPS_ALT_Y = 40

Font12 = Font.new(12)
Font16 = Font.new(16)
Font20 = Font.new(20)
Font32 = Font.new(32)
Font60 = Font.new(60)
Font120 = Font.new(120)

Window.height = 480
Window.width = 640

game = Game.new
controller = Controller.new(game)
view = TitleView.new(game, controller)

SpriteUI.equip MouseEventHandler

Window.loop do
  controller.update
  view.update
  view.draw
  game.update if game.state == :game
  case game.next_state
  when :next_game
    game.transit_state
    game.setup_game
    game.go_to_title
  when :title
    game.transit_state
    view = TitleView.new(game, controller)
  when :game
    game.transit_state
    view = GameView.new(game.game_data, controller)
  when :ranking
    game.transit_state
    view = RankingView.new(game.ranking_data, controller)
  when :ending
    game.transit_state
    view = EndingView.new(game.score_data, controller)
  end
end
