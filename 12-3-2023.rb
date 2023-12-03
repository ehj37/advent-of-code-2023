class EngineDeschematificatinator
  class LineElementType
    NUMBER = 'number'
    SYMBOL = 'symbol'
  end

  def initialize(engine_schematic)
    @schematic_lines = process_schematic_lines(engine_schematic)
  end

  def part_number_sum
    @schematic_lines.each_with_index.reduce(0) do |sum, (line, index)|
      previous_line = index > 0 ? @schematic_lines[index - 1] : nil
      next_line = @schematic_lines[index + 1]
      relevant_lines = [previous_line, line, next_line].compact

      symbol_indices = relevant_lines.flat_map do |relevant_line|
        relevant_line.filter_map { |line_element| line_element[:index] if line_element[:type] == LineElementType::SYMBOL }
      end.uniq

      part_numbers = line.filter_map do |line_element|
        if line_element[:type] == LineElementType::NUMBER
          range_start = line_element[:start_index] > 0 ? line_element[:start_index] - 1 : line_element[:start_index]
          range_end = line_element[:end_index] + 1
          line_element[:value] if symbol_indices.any? { |symbol_index| (range_start..range_end).cover?(symbol_index) }
        end
      end
      sum + part_numbers.sum
    end
  end

  def gear_ratio_sum
    @schematic_lines.each_with_index.reduce(0) do |sum, (line, index)|
      previous_line = index > 0 ? @schematic_lines[index - 1] : nil
      next_line = @schematic_lines[index + 1]
      relevant_lines = [previous_line, line, next_line].compact
      relevant_part_number_elements = relevant_lines.flat_map do |relevant_line|
        relevant_line.filter { |line_element| line_element[:type] == LineElementType::NUMBER }
      end

      asterisk_indices = line.filter_map { |line_element| line_element[:index] if line_element[:type] == LineElementType::SYMBOL && line_element[:value] == '*' }

      gear_sum_for_line = asterisk_indices.reduce(0) do |gear_sum, asterisk_index|
        adjacent_part_numbers = relevant_part_number_elements.filter_map do |part_number_element|
          range_start = part_number_element[:start_index] > 0 ? part_number_element[:start_index] - 1 : part_number_element[:start_index]
          range_end = part_number_element[:end_index] + 1
          part_number_element[:value] if (range_start..range_end).cover?(asterisk_index)
        end

        adjacent_part_numbers.length == 2 ? gear_sum + adjacent_part_numbers.reduce(:*) : gear_sum
      end

      sum + gear_sum_for_line
    end
  end

  private

  def process_schematic_lines(engine_schematic)
    engine_schematic.split("\n").map do |line|
      running_length = 0
      line.scan(/[0-9]+|\.+|./).filter_map do |line_element_string|
        start_index = running_length
        end_index = running_length + line_element_string.length - 1
        running_length += line_element_string.length
        if line_element_string.match?(/[0-9]+/)
          { type: LineElementType::NUMBER, value: Integer(line_element_string, 10), start_index: start_index, end_index: end_index }
        elsif !line_element_string.match(/\.+/)
          { type: LineElementType::SYMBOL, value: line_element_string, index: start_index }
        end
      end
    end
  end
end
