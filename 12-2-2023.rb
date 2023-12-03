class CubeDeconundrumifier
  class Game
    attr_reader :game_number, :draws

    def initialize(game_number:, draws:)
      @game_number = game_number
      @draws = draws
    end
  end

  def initialize(game_records_string)
    @games = parsed_game_records(game_records_string)
  end

  def possible_game_id_sum(hypothetical_color_amounts)
    @games.reduce(0) { |game_id_sum, game| is_possible_game?(game, hypothetical_color_amounts) ? game_id_sum + game.game_number : game_id_sum }
  end

  def minimum_power_sets_sum
    @games.reduce(0) { |power_sum, game| power_sum + minimum_power(game) }
  end

  private

  def minimum_power(game)
    color_minimums = game.draws.reduce({}) do |acc, draw|
      acc.merge(draw) { |_key, oldval, newval| oldval > newval ? oldval : newval }
    end
    color_minimums.values.reduce(:*)
  end

  def is_possible_game?(game, hypothetical_color_amounts)
    game.draws.all? do |color_amounts|
      color_amounts.all? { |color, amount| hypothetical_color_amounts[color] >= amount }
    end
  end

  def parsed_game_records(game_records_string)
    game_records = game_records_string.split("\n")
    game_records.map do |game_string|
      game_text, draws_string = game_string.split(':')
      game_number = Integer(game_text.split(' ').last, 10)
      draws = draws_string.split('; ')
      color_amounts = draws.map do |draw|
        color_outcomes = draw.split(', ')
        color_outcomes.each_with_object({}) do |color_outcome, colors_acc|
          number_string, color = color_outcome.split(' ')
          colors_acc[color] = Integer(number_string, 10)
        end
      end

      Game.new(game_number: game_number, draws: color_amounts)
    end
  end
end
