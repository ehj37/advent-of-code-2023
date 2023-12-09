class NetworkNavigator
  def initialize(file_path)
    @direction_instructions, @nodes = process_input(File.read(file_path))
  end

  def steps_to_zzz
    node_mapping = @nodes.index_by(&:first)

    current_node = 'AAA'
    steps = 0
    until current_node == 'ZZZ'
      direction = @direction_instructions[steps % @direction_instructions.length]
      current_node = direction == 'L' ? node_mapping[current_node].second : node_mapping[current_node].third
      steps += 1
    end
    steps
  end

  # def ghost_mode_steps_to_zzz
  #   node_mapping = @nodes.index_by(&:first)
  #   ending_nodes = @nodes.filter_map { |node| node.first if node.first[2] == 'Z' }

  #   unresolved_nodes = @nodes.filter_map { |node| node.first if node.first[2] == 'A' }
  #   steps = 0
  #   until unresolved_nodes.all? { |node| ending_nodes.include?(node) }
  #     direction = @direction_instructions[steps % @direction_instructions.length]
  #     unresolved_nodes = unresolved_nodes.map { |unresolved_node| direction == 'L' ? node_mapping[unresolved_node].second : node_mapping[unresolved_node].third }
  #     steps += 1
  #   end
  #   steps
  # end

  private

  def process_input(file_contents)
    meaningful_content = file_contents.split("\n").filter(&:present?)
    [meaningful_content.first, meaningful_content[1..].map { |line| line.scan(/\w{3}/) }]
  end
end
