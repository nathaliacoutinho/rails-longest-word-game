require 'open-uri'
class GamesController < ApplicationController

  def new
    @grid = generate_grid(rand(4..10))
    @start_time = Time.now
  end

  def score
    attempt     = params[:attempt]
    grid        = params[:grid].split(" ")
    start_time  = Time.parse(params[:start_time])

    result        = run_game(attempt, grid, start_time, Time.now)
    @score        = result[:score]
    @time         = result[:time]
    @message      = result[:message]

  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "good job!"]
      else
        [0, "Oh no, this is not an english word"]
      end
    else
      [0, "You're word is not in the grid"]
    end
  end

  def included?(guess, grid)
    guess.split("").all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
end
