
function is_out_of_maze(maze, position)
    position[1] <= 0 || position[1] > size(maze)[1] || position[2] <= 0 || position[2] > size(maze)[2]
end

# Computes the distance of each position to initial. Also returns the first step required to 
# reach each position adjacent to follow
function compute_distances(maze, initial; follow=none)
    q = Queue{PositionWithDirection}()
    enqueue!(q, PositionWithDirection(initial, none))

    distances = Matrix{Int}(undef, size(maze))   
    fill!(distances, -1)
    distances[initial] = 0

    follow_steps = Vector{CartesianIndex}(undef, length(adjacencies))   
    fill!(follow_steps, none)

    while !isempty(q)
        @unpack position, first_step = dequeue!(q)
        for adjacency in adjacencies
            new_position = position + adjacency
      
            # Check that position is valid
            if is_out_of_maze(maze, new_position) || maze[new_position] == wall
                continue
            end

            if distances[new_position] == -1
                # We have not visited this position yet
                distances[new_position] = distances[position] + 1

                # Contains the first step in this path
                new_step = first_step == none ? adjacency : first_step

                for i in eachindex(follow_steps)
                    if new_position == follow + adjacencies[i]
                        # Store the first step leading to this position
                        follow_steps[i] = new_step
                    end
                end

                enqueue!(q, PositionWithDirection(new_position, new_step))
            end
        end
    end

    return distances, follow_steps
end

# Simulates the hero and dragon movements
function simulate(maze, distances, initial)
    q = PriorityQueue{State, Int}()
    enqueue!(q, initial, 0)

    last_safety = Matrix{Int}(undef, size(maze))
    fill!(last_safety, unvisited)

    while !isempty(q)
        current_state = dequeue!(q)
        @unpack path, dragon_path = current_state

        hero_position = last(path)
        dragon_position = last(dragon_path)

        # The hero has escaped
        if distances[hero_position] == 0 
            return path, dragon_path
        end

        dragon_distance, dragon_next_steps = compute_distances(maze, dragon_position, follow=hero_position)
        last_safety[hero_position] = dragon_distance[hero_position]

        for (i, adjacency) in enumerate(adjacencies)
            new_position = hero_position + adjacency
            # Check invalid positions (out of maze, wall, or adjacent to dragon)
            if is_out_of_maze(maze, new_position) || distances[new_position] == -1 || dragon_distance[new_position] <= 1
                continue
            end

            # Only go to new position if it brings the hero closer to the goal, or brings the hero further from the dragon
            # Don't revisit tiles that are more dangerous now than before
            if distances[new_position] < distances[hero_position] || 
                (dragon_distance[new_position] > dragon_distance[hero_position] && 
                last_safety[new_position] < dragon_distance[new_position] - 1)

                # Dragon chases hero to new position
                new_dragon_position = dragon_position + dragon_next_steps[i]
                new_state = State(vcat(path, [new_position]), vcat(dragon_path, [new_dragon_position]))

                # Prioritize paths that minimize distance to the goal while maximizing distance to the dragon 
                # There is a higher penalization to get closer to the dragon
                enqueue!(q, new_state, distances[new_position] - 3*dragon_distance[new_position])
            end
        end
    end
    # No path to the exit without being eaten
    return nothing, nothing
end
