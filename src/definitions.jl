const wall = '🟫'
const free = '🟩'
const hero = '🏃'
const dragon = '🐉'
const goal = '❎'
const finish = '🏁'

struct State
    path::Vector{CartesianIndex}
    dragon_path::Vector{CartesianIndex}
end

struct PositionWithDirection
    position::CartesianIndex
    first_step::CartesianIndex
end

const none = CartesianIndex(-1, -1)
const unvisited = -1
const adjacencies = [CartesianIndex(1, 0), CartesianIndex(-1, 0), CartesianIndex(0, 1), CartesianIndex(0, -1)]

path_length_message(n) = "The shortest path is $n steps."
const no_solution_message = "The way is shut. It was made by those who are Dragons, and the Dragons keep it, until the time comes. The way is shut."
