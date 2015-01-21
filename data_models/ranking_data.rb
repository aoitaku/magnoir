class RankingData

  attr_reader :scores

  def initialize
    load_ranking
  end

  def load_ranking
    IO.write('rank.dat', '') unless File.exist?('rank.dat')
    @scores = IO.foreach('rank.dat').with_object([]) {|line, arr| arr << line.to_i }
  end

  def save_ranking
    IO.write('rank.dat', @scores.map(&:to_s).join("\n"))
  end

  def register_score(score)
    @scores.push(score)
    @scores.sort! {|a, b| b <=> a }
    last_score = @scores.size > 5 ? @scores.pop : nil
    save_ranking
    score != last_score
  end

end
