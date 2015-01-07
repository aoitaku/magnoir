require_relative 'viewbase'

class RankingView < ViewBase

  def initialize(model, controller)
    super
    @ui = SpriteUI.build {
      TextLabel {
        left 200
        top 40
        text "RANKING"
        font Font60
        position :absolute
      }
      TextButton {
        left 250
        top 400
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
          left 250
          top 120 + 40 * i
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
