# typed: strict
# frozen_string_literal: true

class CalibrationCalculator
  extend T::Sig

  INTEGER_STRING_MAPPING = T.let(
    {
      # They didn't mention zero in part two, so ¯\_(ツ)_/¯
      'one' => 1,
      'two' => 2,
      'three' => 3,
      'four' => 4,
      'five' => 5,
      'six' => 6,
      'seven' => 7,
      'eight' => 8,
      'nine' => 9,
    }.freeze, T::Hash[String, Integer]
  )

  sig { params(calibration_document: String).void }
  def initialize(calibration_document)
    @calibration_document_lines = T.let(calibration_document.split, T::Array[String])
  end

  sig { returns(Integer) }
  def sum_for_digits
    @calibration_document_lines.reduce(0) do |sum, line|
      numbers_strings = line.scan(/[0-9]/).flatten
      integers = numbers_strings.map { |number_string| Integer(number_string, 10) }
      sum + T.must(integers.first) * 10 + T.must(integers.last)
    end
  end

  sig { returns(Integer) }
  def sum_for_digits_and_spelled_out
    @calibration_document_lines.reduce(0) do |sum, line|
      numbers_strings = line.scan(/(?=(#{INTEGER_STRING_MAPPING.keys.join('|')}|[0-9]))/).flatten
      integers = numbers_strings.map { |number_string| INTEGER_STRING_MAPPING[number_string]&.to_i || Integer(number_string, 10) }
      sum + T.must(integers.first) * 10 + T.must(integers.last)
    end
  end
end
