# Transform input into a matrix and extract relevant positions
function parse_maze(input)
    maze = mapreduce(permutedims, vcat, input)

    hero_position = findfirst(item -> item == hero, maze)
    dragon_position = findfirst(item -> item == dragon, maze)
    goal_position = findfirst(item -> item == goal, maze)

    maze[hero_position] = free
    maze[dragon_position] = free
    maze[goal_position] = free

    return maze, hero_position, dragon_position, goal_position
end

function escape_maze(input; fps=7)
    # Parse the input
    maze, hero_position, dragon_position, goal_position = parse_maze(input)
   
    # Precompute the distances of each tile to the exit
    goal_distances, _ = compute_distances(maze, goal_position)

    initial = State([hero_position], [dragon_position])
    # Compute the solution. The paths are just stored for later visualization, otherwise we would not need them
    @time path, dragon_path = simulate(maze, goal_distances, initial)

    # There exists no solution
    if isnothing(path)
        return no_solution_message
    end

    # Make animation of the solution
    animate_path(maze, path, dragon_path, goal_position, frame_delay=1/fps)

    print(path_length_message(length(path) - 1))
end
