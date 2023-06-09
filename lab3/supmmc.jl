#= OPTIMIZATION METHODS
ex 3 - Scheduling on Unrelated Parallel Machines and Makespan Criterion
Author: Janusz Witkowski 254663
=#

using JuMP
# import GLPK
import Cbc
# import CPLEX


function read_file(filename)
    lines = open(filename) do file
        readlines(file)
    end
    sizes = parse.(Int,split(replace(lines[1], r"[^0-9.]"=>" ")))
    n, m = sizes[1], sizes[2]
    # println(n ," - ", m)
    times = zeros(Int, n, m)
    for (i,line) in enumerate(lines[3:end])
        parsed = parse.(Int,split(replace(line, r"[^0-9.]"=>" ")))
        times[i,:] = parsed[2:2:end]
    end
    return times
end


function greedy_schedule(times)
    (n, m) = size(times)
    makespans = zeros(Int64, m)

    for j in 1:n
        minimum, machine = findmin(times[j,:])
        makespans[machine] += minimum
    end

    return maximum(makespans)
end


function check_feasibility(times, T, no_pruning)
    (n, m) = size(times)
    Jobs = 1:n
    Machines = 1:m
    S_j = [[] for _ in Jobs]
    S_i = [[] for _ in Machines]
    for j in Jobs
        for i in Machines
            if times[j,i] <= T || no_pruning
                append!(S_j[j], i)
                append!(S_i[i], j)
            end
        end
    end

    # model = Model(GLPK.Optimizer)
    model = Model(Cbc.Optimizer)
    # model = Model(CPLEX.Optimizer)

    @variable(model, x[Jobs, Machines] >= 0)
    @constraint(model, [j in Jobs], sum(x[j,i] for i in S_j[j]) == 1)
    @constraint(model, [i in Machines], sum(x[j,i] * times[j,i] for j in S_i[i]) <= T)
    @objective(model, Min, 0)

    set_silent(model)
    optimize!(model)
    # unset_silent(model)

    if termination_status(model) == MOI.OPTIMAL
        return true, value.(x)
    end
    return false, nothing
end


function binary_search(times, range)
    (n, m) = size(times)
    l = range ÷ m
    r = range
    mid = 0
    result = nothing
    while l < r
        mid = (l+r) ÷ 2
        feasible, result = check_feasibility(times, mid, false)
        if feasible
            r = mid - 1
        else
            l = mid + 1
        end
    end
    return mid + 1, result
end


function lowest_infeasible(times, T)
    while T > 0
        feasible, _ = check_feasibility(times, T, true)
        if !feasible 
            break
        end
        T -= 1
    end
    return T
end

function feasibility_points(times, T)
    feasible, _ = check_feasibility(times, T, true)
    if feasible
        while T > 0
            feasible, _ = check_feasibility(times, T, true)
            if !feasible 
                return T, T+1
            end
            T -= 1
        end
    else
        while true
            feasible, _ = check_feasibility(times, T, true)
            if feasible 
                return T-1, T
            end
            T += 1
        end
    end
end




DEFAULT_FILENAME = "RCmax/instancias100a120/111.txt"

filename = DEFAULT_FILENAME
if length(ARGS) > 0
    filename = ARGS[1]
end
println("Instance: ", filename)
p = read_file(filename)
# display(p)
alpha = greedy_schedule(p)
println("Alpha: ", alpha)
T_min, result = binary_search(p, alpha)
# feasibility, _ = check_feasibility(p, T_min, true)
# lowest = lowest_infeasible(p, T_min)
T_a, T_b = feasibility_points(p, T_min)
display(result)
println("Value of objective function for instance ", filename)
println("T_min = ", T_min)
# println("Feasibile: ", feasibility)
# println("Lowest infeasible T: ", lowest)
println("Feasibility border: ($T_a, $T_b)")

