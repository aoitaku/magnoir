require_relative './data_models/game_data'
require_relative './data_models/score_data'
require_relative './data_models/ranking_data'

class Game

  attr_reader :state, :next_state, :game_data, :score_data, :ranking_data

  def initialize
    @state = :title
    @ranking_data = RankingData.new
    setup_game
  end

  def setup_game
    @game_data = GameData.new
    @game_data.add_observer(ObserverCallback.new {|event|
      event_type, value = *event.to_a.first
      go_to_ending if event_type == :game_end
    })
  end

  def transit_state
    @state, @next_state = @next_state, nil
  end

  def update
    @game_data.update
  end

  def go_to_game
    @next_state = :game
  end

  def go_to_ranking
    @next_state = :ranking
  end

  def go_to_title
    @next_state = :title
  end

  def go_next
    @next_state = :next_game
  end

  def go_to_ending
    @next_state = :ending
    new_record = @ranking_data.register_score(@game_data.money)
    @score_data = ScoreData.new(@game_data.money, new_record)
  end

  def self.d6(n)
    n.times.lazy.map { rand(6) + 1 }.inject(:+)
  end

end
