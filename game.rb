require_relative './data_models/game_data'
require_relative './data_models/score_data'
require_relative './data_models/ranking_data'

class Game

  attr_reader :state, :game_data, :score_data, :ranking_data

  def initialize
    @state = :title
    @ranking_data = RankingData.new
    @game_data = GameData.new
  end

  def start
    @state = :game
  end

  def rank_start
    @state = :ranking
  end

  def go_title
    @state = :title
  end

  def next
    @state = :next
  end

  def clock
    @game_data.publish
    return if @game_data.pause?
    hour = @game_data.hour
    @game_data.time += 1
    if hour != @game_data.hour
      ending if @game_data.day == END_DAY
      @game_data.timecount
    end
  end

  def ending
    @state = :end
    high_score_registered = @ranking_data.register_score(@game_data.money)
    @score_data = ScoreData.new(@game_data.money, high_score_registered)
  end

  def self.d6(n)
    n.times.inject(0){|sum|sum+rand(6)+1}
  end

end
