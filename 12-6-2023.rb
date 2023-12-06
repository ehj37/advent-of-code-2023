class RaceCalculator
  def initialize(file_path)
    @race_info = process_input(file_path)
  end

  def number_of_ways_to_win
    times, distances = @race_info
    races = times.zip(distances)
    races.reduce(1) { |product, (time, distance)| product * time_to_win_range(time, distance).size }
  end

  def kerned_number_of_ways_to_win
    time, distance = @race_info.map { |race_array| Integer(race_array.join, 10) }
    time_to_win_range(time, distance).size
  end

  private

  def time_to_win_range(time, distance)
    (((time - Math.sqrt(time**2 - 4 * distance)) / 2) + 1).floor..(((time + Math.sqrt(time**2 - 4 * distance)) / 2) - 1).ceil
  end

  def process_input(file_path)
    input = File.read(file_path)
    [input[/(?<=Time:).*/].scan(/\d+/).map { |i| Integer(i, 10) }, input[/(?<=Distance:).*/].scan(/\d+/).map { |i| Integer(i, 10) }]
  end
end