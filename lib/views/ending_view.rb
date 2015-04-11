require_relative 'viewbase'

class EndingView < ViewBase

  def initialize(model, controller)
    super
    score = @model.score.to_s
    @highscore = SpriteUI.build {
      width :full
      justify_content :center
      TextLabel {
        margin [180, 0, 0, 0]
        text "ハイスコアを更新しました！"
        font Font20
        color [255,0,255,0]
      }
    }
    @highscore.layout
    @ui = SpriteUI.build {
      width :full
      justify_content :center
      TextLabel {
        margin [40, 0, 20, 0]
        text "GAME OVER"
        font Font60
      }
      TextLabel {
        height 270
        text "score: #{score}"
        font Font32
      }
      TextButton {
        width 150
        text "戻る"
        font Font20
        onclick -> target {
          controller.on_go_next_click
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
    @highscore.draw if @model.highscore?
    @ui.draw
  end

end
