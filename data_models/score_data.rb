class ScoreData

  attr_reader :score

  def initialize(score, highscore)
    @score = score
    @highscore = highscore
  end

  def highscore?
    @highscore
  end

end
