using JuMP, GLPKMathProgInterface, DataFrames

variables = Dict{Int, Array{Variable, 2}}()

# optimization model
m = Model(solver = GLPKSolverMIP())

for k in 1:5
    global variables[k] = @variable(m, [1:2, 1:2], Bin)
end

# staff x shift binary assignment matrix
# 1 if employee i assigned to shift j, 0 otherwise
@variable(m, x[1:staff, 1:shift], Bin)

# maximize preference score sum
@objective(m, Max, sum(pref_matrix[i,j]*x[i,j] for i in 1:staff, j in 1:shift))

# constraints

# cons1: exactly one person per shift
for j in 1:shift
    @constraint(m, sum( x[i,j] for i in 1:staff) == 1)
end

# cons2: maximum 4 shifts per week per person
for i in 1:staff
    @constraint(m, sum( x[i,j] for j in 1:shift) <= 4)
end

# cons3: minimum 1 shift per week per person
for i in 1:staff
    @constraint(m, sum( x[i,j] for j in 1:shift) >= 1)
end

# cons4: no employee works both Sat and Sun in one weekend
for i in 1:staff
    @constraint(m, sum( x[i,j] for j in union(sat_shift,sun_shift)) <= 1)
end

# cons5: desk employees cannot work shelving shifts
for i in desk_staff
    @constraint(m, sum( x[i,j] for j in shel_shift) == 0)
end

# cons6: shelving employees cannot work desk shifts
for i in shel_staff
    @constraint(m, sum( x[i,j] for j in desk_shift) == 0)
end

# cons7: nobody works 2 shifts (or more) in one day:
for i in 1:staff
    @constraint(m,  sum( x[i,j] for j in mon_shift) <= 1)
    @constraint(m,  sum( x[i,j] for j in tue_shift) <= 1)
    @constraint(m,  sum( x[i,j] for j in wed_shift) <= 1)
    @constraint(m,  sum( x[i,j] for j in thu_shift) <= 1)
    @constraint(m,  sum( x[i,j] for j in fri_shift) <= 1)
    @constraint(m,  sum( x[i,j] for j in sat_shift) <= 1)
    @constraint(m,  sum( x[i,j] for j in sun_shift) <= 1)
end

# print(m)

status = solve(m)

println("Objective value: ", getobjectivevalue(m))
assn_matrix = Array{Int64}(getvalue(x))
