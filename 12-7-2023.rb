class CamelCardsCalculator
  class Hand
    include Comparable
    attr_reader :cards, :bid

    def initialize(cards:, bid:, j_as_joker: false)
      @cards = cards
      @bid = bid
      @j_as_joker = j_as_joker
    end

    def <=>(other)
      strength_comparison = self.relative_strength <=> other.relative_strength
      case strength_comparison
      when 1, -1
        strength_comparison
      else
        tiebreaker_value(other)
      end
    end

    def relative_strength
      hand_type_tally_requirements = [[5], [4, 1], [3, 2], [3, 1, 1], [2, 2, 1], [2, 1, 1, 1], [1, 1, 1, 1, 1]]
      if @j_as_joker
        non_joker_tally = @cards.split('').filter { |card| card != 'J' }.tally
        joker_amount = @cards.scan(/J/).count
        -card_tally_amounts_with_joker_subs([non_joker_tally], joker_amount).map do |card_tally_amount|
          hand_type_tally_requirements.index { |requirement| card_tally_amount.sort == requirement.sort }
        end.min
      else
        card_tally_amounts = @cards.split('').tally.values
        -hand_type_tally_requirements.index { |requirement| card_tally_amounts.sort == requirement.sort }
      end
    end

    private

    def card_tally_amounts_with_joker_subs(card_tallies, joker_count)
      return card_tallies.map(&:values) if joker_count == 0

      new_tallies = card_tallies.flat_map do |card_tally|
        [*card_tally.keys, 'J'].reduce([]) do |acc, key|
          new_tally = card_tally.clone
          card_tally[key] ? new_tally[key] += 1 : new_tally[key] = 1
          acc << new_tally
        end
      end

      card_tally_amounts_with_joker_subs(new_tallies, joker_count - 1)
    end

    def tiebreaker_value(other)
      @cards.split('').each_with_index do |card, i|
        comparison_value = ranked_card_values.index(other.cards[i]) <=> ranked_card_values.index(card)
        return comparison_value if comparison_value != 0
      end
      0
    end

    def ranked_card_values
      @ranked_card_values ||= @j_as_joker ? ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J'] : ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2']
    end
  end

  def initialize(file_path:, j_as_joker: false)
    @hands = File.read(file_path).each_line.map do |line|
      cards, bid = line.split
      Hand.new(cards: cards, bid: Integer(bid, 10), j_as_joker: j_as_joker)
    end
  end

  def total_winnings
    @hands.sort.each_with_index.reduce(0) { |sum, (hand, i)| sum + hand.bid * (i + 1) }
  end
end
