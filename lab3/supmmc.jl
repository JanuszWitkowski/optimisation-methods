#= OPTIMIZATION METHODS
ex 3 - Scheduling on Unrelated Parallel Machines and Makespan Criterion
Author: Janusz Witkowski 254663
=#

using JuMP
# import GLPK
import Cbc
# import CPLEX
# import HiGHS



# Use greedy schedule to calculate upper bound, and thus get our range to search in.
function upper_bound(durations)
    (n, m) = size(durations)
    makespans = zeros(Int64, m)
    for j in 1:n
        minimum, machine = findmin(durations[j,:])
        makespans[machine] += minimum
    end
    return maximum(makespans)
end


# Our LP(T) builder.
# durations - times of execution of each job on each machine.
# T - Upper bound for durations.
# no_pruning - boolean flag; if true, we use all jobs.
function lp_t(durations, T, no_pruning)
    (n, m) = size(durations)
    Jobs = 1:n
    Machines = 1:m

    # The S_T set, split into two arrays
    S_jobs = [[] for _ in Jobs]
    S_machines = [[] for _ in Machines]

    for j in Jobs
        for i in Machines
            if durations[j,i] <= T || no_pruning
                append!(S_jobs[j], i)
                append!(S_machines[i], j)
            end
        end
    end

    # model = Model(GLPK.Optimizer)
    model = Model(Cbc.Optimizer)
    # model = Model(CPLEX.Optimizer)
    # model = Model(HiGHS.Optimizer)

    # Decision variable - tries to pack together jobs into machines, with continuous values from 0 to 1.
    @variable(model, x[Jobs, Machines] >= 0)
    # Relaxation - a job must be properly distributed accross machines.
    @constraint(model, [j in Jobs], sum(x[j,i] for i in S_jobs[j]) == 1)
    # Upper limit for makespan is T.
    @constraint(model, [i in Machines], sum(x[j,i] * durations[j,i] for j in S_machines[i]) <= T)
    # The objective function has no meaning here - so let's minimize the approximate value of pi.
    @objective(model, Min, 3.1415925358979)

    set_silent(model)
    optimize!(model)
    # unset_silent(model)

    term_status = termination_status(model)
    if term_status == MOI.OPTIMAL
        return true, value.(x)
    end
    return false, nothing
end


# Searching for T*.
# durations - times of execution.
# range - value used to determine bounds in which we search.
function binary_search(durations, range)
    (n, m) = size(durations)
    left = div(range, m)
    right = range
    middle = 0
    table = nothing
    while left < right
        middle = div(left + right, 2)
        is_solution_feasible, table = lp_t(durations, middle, false)
        if is_solution_feasible
            right = middle - 1
        else
            left = middle + 1
        end
    end
    is_solution_feasible, table = lp_t(durations, left, false)
    return left, table
end


# Helper function; finds the first occurance of an element and returns it's index.
function find_the_first(condition, collection)
    for (index, item) in enumerate(collection)
        if condition(item)
            return index
        end
    end
    return nothing
end


# Helper function; calculates maximum makespan.
function calculate_makespan(durations, table)
    (n, m) = size(durations)
    Jobs = 1:n
    Machines = 1:m
    return maximum([sum(table[j,i] * durations[j,i] for j in Jobs) for i in Machines])
end


# Used to set fractionally-set jobs to machines in whole.
#  durations - times of execution.
# table - solutoon to LP(T*) problem.
function perfect_matching(durations, table)
    (n, m) = size(durations)
    Jobs = 1:n
    Machines = 1:m

    # How many fractionally-set jobs does each machine have.
    fractionally_set_edges = [count(x -> 1 > x > 0, table[:,i]) for i in Machines]
    considered_machine = 1

    # Repeat until all jobs are integrally-set.
    while sum(fractionally_set_edges) > 0
        # Set any job to any machine; prevents loops.
        if count(me -> me == 1, fractionally_set_edges) == 0
            machine = find_the_first(elem -> elem > 0, fractionally_set_edges)
            job = find_the_first(elem -> 0 < elem < 1, table[:,machine])
            for other_machine in Machines
                table[job, other_machine] = 0
            end
            table[job, machine] = 1
        end
        # Set a job to the machine if it's the only job it has.
        if fractionally_set_edges[considered_machine] == 1
            job = find_the_first(elem -> 0 < elem < 1, table[:,considered_machine])
            for other_machine in 1:m
                table[job, other_machine] = 0
            end
            table[job, considered_machine] = 1
        end

        fractionally_set_edges = [count(x -> 1 > x > 0, table[:,i]) for i in Machines]
        considered_machine = (considered_machine % m) + 1
    end

    return table
end


# Full algorithm; calculates makespan for an instance in a file with filename.
function approximate_makespan(filename)
    durations = read_instance(filename)
    alpha = upper_bound(durations)
    T_min, table = binary_search(durations, alpha)
    proper_table = perfect_matching(durations, table)
    makespan = calculate_makespan(durations, proper_table)
    return makespan
end


# Helper function; checks for lowest infeasible solutions from a given one.
function lowest_infeasible(durations, T)
    while T > 0
        is_solution_feasible, _ = lp_t(durations, T, true)
        if !feasible 
            break
        end
        T -= 1
    end
    return T
end

# Helper function; returns bounds of feasibility.
function feasibility_points(durations, T)
    is_solution_feasible, _ = lp_t(durations, T, true)
    if is_solution_feasible
        while T > 0
            is_solution_feasible, _ = lp_t(durations, T, true)
            if !feasible 
                return T, T+1
            end
            T -= 1
        end
    else
        while true
            is_solution_feasible, _ = lp_t(durations, T, true)
            if is_solution_feasible 
                return T-1, T
            end
            T += 1
        end
    end
end

# Helper function.
function possible_opt(T)
    return div(T, 2)
end


# Parser for instance files.
function read_instance(filename)
    lines = open(filename) do file
        readlines(file)
    end
    sizes = parse.(Int,split(replace(lines[1], r"[^0-9.]"=>" ")))
    n, m = sizes[1], sizes[2]
    durations = zeros(Int, n, m)
    for (i,line) in enumerate(lines[3:end])
        parsed = parse.(Int,split(replace(line, r"[^0-9.]"=>" ")))
        durations[i,:] = parsed[2:2:end]
    end
    return durations
end




DEFAULT_FILENAME = "RCmax/instancias100a120/111.txt"

filename = DEFAULT_FILENAME
if length(ARGS) > 0
    filename = ARGS[1]
end
# println("Instance: ", filename)
# p = read_instance(filename)
# # display(p)
# alpha = upper_bound(p)
# println("Alpha: ", alpha)
# T_min, table = binary_search(p, alpha)
# # feasibility, _ = lp_t(p, T_min, true)
# # lowest = lowest_infeasible(p, T_min)
# T_a, T_b = feasibility_points(p, T_min)
# display(table)
# println("Value of objective function for instance ", filename)
# println("T_min = ", T_min)
# # println("Feasibile: ", feasibility)
# # println("Lowest infeasible T: ", lowest)
# println("Feasibility border: ($T_a, $T_b)")
# println("OPT is equal at least ", possible_opt(T_min))

elapsed = @elapsed (makespan = approximate_makespan(filename))
println("Makespan: ", makespan)
println("Time: ", elapsed)

