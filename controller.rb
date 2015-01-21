class Controller

  def initialize(game)
    @game = game
  end

  def update
    if @game.state == :game
      if Input.key_push?(K_Z)
        @game.game_data.sell_all_fish
      end
      if Input.key_push?(K_SPACE)
        @game.game_data.toggle_pause
      end
    end
    if Input.key_push?(K_ESCAPE)
      exit
    end
  end

  def on_start_click
    @game.go_to_game
  end

  def on_ranking_click
    @game.go_to_ranking
  end

  def on_exit_click
    exit
  end

  def on_go_title_click
    @game.go_to_title
  end

  def on_go_next_click
    @game.go_next
  end

  def on_fish_click(index)
    @game.game_data.sell_fish(index) if index
  end

  def on_ship_click(index)
    @game.game_data.alt_ship(index) if index
  end

end
