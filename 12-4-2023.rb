class ScratchcardChecker
  def initialize(scratchcard_input)
    @scratchcards = process_scratchcard_input(scratchcard_input)
  end

  def scratchcard_point_sum
    @scratchcards.reduce(0) do |sum, scratchcard|
      _card_number, winning_numbers, possessed_numbers = scratchcard
      possessed_winning_numbers = possessed_numbers & winning_numbers
      sum + (possessed_winning_numbers.any? ? 2**(possessed_winning_numbers.length - 1) : 0)
    end
  end

  def scratchcard_sum
    sorted_match_amounts = @scratchcards.sort_by(&:first).map { |scratchcard| (scratchcard.second & scratchcard.third).length }
    sorted_match_amounts.each_with_object(Array.new(@scratchcards.length, 1)).with_index do |(match_amount, card_amounts), index|
      (1..match_amount).each do |add_ahead_index|
        break unless card_amounts[index + add_ahead_index]

        card_amounts[index + add_ahead_index] += card_amounts[index]
      end
    end.sum
  end

  private

  def process_scratchcard_input(scratchcard_input)
    scratchcard_input.split("\n").map do |scratchcard_line|
      card_number_string, winning_numbers_sting, possessed_numbers_string = scratchcard_line.split(/[:|]/)
      card_number = Integer(card_number_string[/\d+/], 10)
      winning_numbers = winning_numbers_sting.scan(/\d+/)
      possessed_numbers = possessed_numbers_string.scan(/\d+/)
      [card_number, winning_numbers, possessed_numbers]
    end
  end
end
