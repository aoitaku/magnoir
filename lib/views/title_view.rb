require_relative 'viewbase'

class TitleView < ViewBase

  def initialize(model, controller)
    super
    @ui = SpriteUI.build {
      image Image.load('./gfx/maguro.png')
      width :full
      justify_content :center
      TextLabel {
        margin [10, 0, 0]
        width :full
        text_align :center
        text "MAGURO"
        font Font120
      }
      ContainerBox {
        margin [230, 0, 0]
        TextButton(:start) {
          text "START"
          font Font32
          onclick -> target {
            controller.on_start_click
          }
        }
        TextButton(:ranking) {
          text "RANKING"
          font Font32
          onclick -> target {
            controller.on_ranking_click
          }
        }
        TextButton(:exit) {
          text "EXIT"
          font Font32
          onclick -> target {
            controller.on_exit_click
          }
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
