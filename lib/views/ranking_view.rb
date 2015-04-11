require_relative 'viewbase'

class RankingView < ViewBase

  def initialize(model, controller)
    super
    @ui = SpriteUI.build {
      width :full
      justify_content :center
      TextLabel {
        margin [40, 0]
        text "RANKING"
        font Font60
      }
      ContainerBox {
        width 150
        ContainerBox(:ranking) {
          height 250
        }
        TextButton {
          text "戻る"
          font Font20
          onclick -> target {
            controller.on_go_title_click
          }
        }
      }
    }
    ranking = @ui.find(:ranking)
    @model.scores.each_with_index do |score, i|
      ranking.add SpriteUI.build {
        TextLabel {
          text "#{(i + 1).to_s}. #{score.to_s}"
          font Font32
          padding [4, 0]
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
