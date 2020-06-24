function nodes_position = ParameterEstimation_load_experimental_data(robot, ExpData, line_index)

nodes_position = zeros(size(robot.nodes_position));

for i = 1:size(nodes_position, 2)
    index = ExpData.NodeMap(i, 2);
    if ExpData.NodeMap(i, 1) ~= i
        error('map is in incorrect format!')
    end
    nodes_position(:, i) = ExpData.Maker{index}.val(line_index, :)';
end

end