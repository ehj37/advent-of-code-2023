class OasisAnalyzer
  def initialize(file_path)
    @histories = File.read(file_path).each_line.map { |line| line.split.map(&:to_i) }
  end

  def next_value_sum
    @histories.map { |h| next_value(h) }.sum
  end

  def previous_value_sum
    @histories.map { |h| previous_value(h) }.sum
  end

  private

  def previous_value(history)
    difference_sequences(history).reverse.reduce(0) { |value, sequence| sequence.first - value }
  end

  def next_value(history)
    difference_sequences(history).reverse.reduce(0) { |value, sequence| sequence.last + value }
  end

  def difference_sequences(sequence)
    return [sequence] if sequence.all?(&:zero?)

    next_sequence = sequence[1..].zip(sequence[0..sequence.length - 2]).map { |a, b| a - b }
    [sequence, *difference_sequences(next_sequence)]
  end
end