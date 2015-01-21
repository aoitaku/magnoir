require_relative 'viewbase'

class TitleView < ViewBase

  def initialize(model, controller)
    super
    @ui = SpriteUI.build {
      image Image.load("maguro.png")
      TextLabel {
        left 80
        top 10
        text "MAGURO"
        font Font120
      }
      ContainerBox {
        position :absolute
        left 240
        top 240
        TextButton(:start) {
          text "START"
          font Font32
          add_event_handler :mouse_left_push, -> target {
            controller.on_start_click
          }
        }
        TextButton(:ranking) {
          text "RANKING"
          font Font32
          add_event_handler :mouse_left_push, -> target {
            controller.on_ranking_click
          }
        }
        TextButton(:exit) {
          text "EXIT"
          font Font32
          add_event_handler :mouse_left_push, -> target {
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
