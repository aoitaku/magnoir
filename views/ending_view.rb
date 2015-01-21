require_relative 'viewbase'

class EndingView < ViewBase

  def initialize(model, controller)
    super
    score = @model.score.to_s
    @highscore = SpriteUI.build {
      TextLabel {
        left 170
        top 180
        text "ハイスコアを更新しました！"
        font Font20
        color [255,0,255,0]
        position :absolute
      }
    }
    @highscore.layout
    @ui = SpriteUI.build {
      TextLabel {
        left 140
        top 40
        text "GAME OVER"
        font Font60
        position :absolute
      }
      TextLabel {
        left 200
        top 120
        text "score: #{score}"
        font Font32
        position :absolute
      }
      TextButton {
        left 250
        top 400
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
    @highscore.draw if @model.highscore?
    @ui.draw
  end

end
