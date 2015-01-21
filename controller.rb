class Controller

  def initialize(game)
    @game = game
  end

  def input
    if Input.key_push?(K_Z)
      case @game.state
      when :game
        @game.game_data.sell_all_fish
      end
    end
    if Input.key_push?(K_SPACE)
      case @game.state
      when :game
        @game.game_data.toggle_pause
      end
    end
    if Input.key_push?(K_ESCAPE)
      exit
    end
  end

  def on_start_click
    @game.start
  end

  def on_ranking_click
    @game.rank_start
  end

  def on_exit_click
    exit
  end

  def on_go_title_click
    @game.go_title
  end

  def on_go_next_click
    @game.next
  end

  def on_fish_click(index)
    @game.game_data.sell_fish(index) if index
  end

  def on_ship_click(index)
    @game.game_data.alt_ship(index) if index
  end

end
