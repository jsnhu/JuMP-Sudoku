using JuMP, GLPKMathProgInterface

#=
    Sudoku board split into 9x9x9 cubic matrix.
    row i, column j, depth k
    Each depth k represents the assignments [i,j]
    of one digit in a solved board.
=#


# optimization model
m = Model(solver = GLPKSolverMIP())

# inserting binary variable assignment matrices into dictionary
@variable(m, board[1:9, 1:9, 1:9], Bin)

# arbitrary objective function
@objective(m, Max, sum(board[i,j,k] for i in 1:9, j in 1:9, k in 1:9))

# constraints

# cons1: each digit appears exactly once in each row
for i in 1:9
    for k in 1:9
        @constraint(m, sum(board[i, j, k] for j in 1:9) == 1)
    end
end

# cons2: each digit appears exactly once in each column
for j in 1:9
    for k in 1:9
        @constraint(m, sum(board[i, j, k] for i in 1:9) == 1)
    end
end

# cons3: each square contains only one digit
for i in 1:9
    for j in 1:9
        @constraint(m, sum(board[i, j, k] for k in 1:9) == 1)
    end
end

# cons4: each digit appears exactly once in each 3x3 box
for k in 1:9
    for u in [0, 3, 6]
        for v in [0, 3, 6]
            @constraint(m, sum(board[i, j, k] for i in 1:3, j in 1:3) == 1)
        end
    end
end

# print(m)

status = solve(m)

println("Objective value: ", getobjectivevalue(m))
solution = Array{Int8}(getvalue(board))

sol_matrix = Array{Int8}(undef, 9, 9)

for k in 1:9
    for i in 1:9
        for j in 1:9
            if solution[i,j,k] == 1
                sol_matrix[i,j] = k
            end
        end
    end
end
