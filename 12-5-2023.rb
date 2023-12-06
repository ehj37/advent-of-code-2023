# typed: strict

class AlmanacInterpreter
  ORDERED_CATEGORIES = ['seed', 'soil', 'fertilizer', 'water', 'light', 'temperature', 'humidity', 'location']

  attr_reader :seeds, :mappings

  def initialize(file_path)
    @seeds, @mappings = process_almanac(File.read(file_path))
  end

  def lowest_location
    lowest_location_helper(@seeds, 0)
  end

  def lowest_location_ranges
    seed_ranges = @seeds.each_slice(2).flat_map { |seed_range_start, seed_range_length| (seed_range_start..seed_range_start + seed_range_length - 1) }
    lowest_location_ranges_helper(seed_ranges, 0)
  end

  private

  def lowest_location_ranges_helper(source_ranges, current_map_index)
    current_mapping = @mappings[current_map_index]
    current_mapping_ranges = current_mapping.map do |destination_range_start, source_range_start, range_length|
      [(destination_range_start..destination_range_start + range_length), (source_range_start..source_range_start + range_length - 1)]
    end

    range_stack = source_ranges
    destination_ranges = []
    until range_stack.empty?
      popped_range = range_stack.pop

      first_matching_range_set = current_mapping_ranges.find do |_, source_range|
        source_range.include?(popped_range.begin) || source_range.include?(popped_range.end) || popped_range.include?(source_range.begin) || popped_range.include?(source_range.end)
      end
      if first_matching_range_set
        destination_range, source_range = first_matching_range_set
        destination_difference = destination_range.begin - source_range.begin
        new_destination_range_start = [popped_range.begin, source_range.begin].max + destination_difference
        new_destination_range_end = [popped_range.end, source_range.end].min + destination_difference
        destination_ranges << (new_destination_range_start..new_destination_range_end)
        scraps = []
        scraps << (popped_range.begin..source_range.begin - 1) if popped_range.begin < source_range.begin
        scraps << (source_range.end + 1..popped_range.end) if popped_range.end > source_range.end
        range_stack.push(*scraps) if scraps.any?
      else
        destination_ranges << popped_range
      end
    end
    current_map_index < @mappings.length - 1 ? lowest_location_ranges_helper(destination_ranges, current_map_index + 1) : destination_ranges.map(&:begin).min
  end

  def lowest_location_helper(source_numbers, current_map_index)
    current_mapping = @mappings[current_map_index]
    current_mapping_ranges = current_mapping.map do |destination_range_start, source_range_start, range_length|
      [(destination_range_start..destination_range_start + range_length - 1), (source_range_start..source_range_start + range_length - 1)]
    end
    destination_numbers = source_numbers.map do |source_number|
      matching_ranges = current_mapping_ranges.find { |_destination_range, source_range| source_range.include?(source_number) }
      matching_ranges ? matching_ranges.first.begin + source_number - matching_ranges.second.begin : source_number
    end
    current_map_index < @mappings.length - 1 ? lowest_location_helper(destination_numbers, current_map_index + 1) : destination_numbers.min
  end

  def process_almanac(almanac)
    seeds = almanac.scan(/(?<=seeds: ).*/).first.split.map { |i| Integer(i, 10) }
    maps = (0..ORDERED_CATEGORIES.length - 2).map do |i|
      map_name = "#{ORDERED_CATEGORIES[i]}-to-#{ORDERED_CATEGORIES[i + 1]}"
      next_map_name = "#{ORDERED_CATEGORIES[i + 1]}-to-#{ORDERED_CATEGORIES[i + 2]}" if ORDERED_CATEGORIES[i + 2]
      format_mapping(almanac, *[map_name, next_map_name].compact)
    end
    [seeds, maps]
  end

  def format_mapping(almanac, map_name, next_map_name = nil)
    map_regex = next_map_name ? /(?<=#{map_name} map:).*(?=\n#{next_map_name})/m : /(?<=#{map_name} map:).*/m
    almanac.scan(map_regex).flatten.first.split("\n").reject(&:empty?).map { |mapping| mapping.split.map { |i| Integer(i, 10) } }
  end
end
