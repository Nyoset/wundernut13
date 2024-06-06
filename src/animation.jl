move_up_n_lines(n) = print("\u1b[$(n)F")

function move_up(s::AbstractString)
    string_height = length(collect(eachmatch(r"\n", s)))
    move_up_n_lines(string_height)
    nothing
end

function animate(frames; frame_delay)
    print("\u001B[?25l") # Hide cursor
    for frame in frames[1:end-1]
        print(frame)
        sleep(frame_delay)
        move_up(string(frame))
    end
    print(frames[end])
    print("\u001B[?25h") # Show cursor again
    nothing
end

function generate_frames(maze, path, dragon_path, goal_tile)
    frames = []
    for (hero_tile, dragon_tile) in zip(path, dragon_path)
        frame = ""
        for i in 1:size(maze)[1]
            for j in 1:size(maze)[2]
                if CartesianIndex(i, j) == hero_tile
                    frame *= hero
                elseif CartesianIndex(i, j) == dragon_tile
                    frame *= dragon
                elseif CartesianIndex(i, j) == goal_tile
                    frame *= finish
                else
                    frame *= maze[i, j]
                end
            end
            frame *= "\n"
        end
        push!(frames, frame)
    end
    return frames
end

function animate_path(maze, path, dragon_path, goal_position; frame_delay)
    frames = generate_frames(maze, path, dragon_path, goal_position)
    animate(frames; frame_delay)
end


function frames(maze, hero_tile, dragon_tile, goal_tile)
    frame = ""
    for i in 1:size(maze)[1]
        for j in 1:size(maze)[2]
            if CartesianIndex(i, j) == hero_tile
                frame *= hero
            elseif CartesianIndex(i, j) == dragon_tile
                frame *= dragon
            elseif CartesianIndex(i, j) == goal_tile
                frame *= finish
            else
                frame *= maze[i, j]
            end
        end
        frame *= "\n"
    end
    print(frame)
end