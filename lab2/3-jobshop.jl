#= OPTIMIZATION METHODS
ex 2.3 - Job Shop
Author: Janusz Witkowski 254663
=#

using JuMP
# using GLPK
using Cbc
# using CPLEX 
include("job_printing.jl")


function job_shop(n_of_jobs::Int,           # Number of jobs.
                    n_of_machines::Int,     # Number of machines.
                    durations::Vector{Int}, # How much time does each job take.
                    preceding,              # Edges from graph of job's order.
    )

    T = sum(durations) + 1  # Length of the time horizon.
    Jobs = 1:n_of_jobs
    Machines = 1:n_of_machines
    Horizon = 1:T
    Precedence = [if (i1,i2) in preceding 1 else 0 end for i1 in Jobs, i2 in Jobs]  # Full graph.

    # model = Model(GLPK.Optimizer) # GLPK
    model = Model(Cbc.Optimizer) # Cbc
    # model = Model(CPLEX.Optimizer) # CPLEX

    # Starting schedule for jobs.
    @variable(model, S[Jobs,Machines,Horizon], Bin) 
    # Helper variable - maximum of finish times.
    @variable(model, C_max >= 0, Int)
    # Minimize the maximum delay.
    @objective(model, Min, C_max) 
    # C_max is the maximum of all moments in C (= S + durations).
    max_delay = @constraint(model, [i in Jobs], sum(((t-1) + durations[i]) * S[i,j,t] for j in Machines, t in Horizon) <= C_max)
    # Each job can only be started once.
    start_once = @constraint(model, [i in Jobs], sum(S[i,j,t] for j in Machines, t in Horizon) == 1)
    # Jobs cannot overlap (while on the same machine).
    no_overlap = @constraint(model, [j in Machines, t in Horizon], sum(S[i,j,s] for i in Jobs, s in max(1, t - durations[i]+1):t) <= 1)
    # Do not let any job start before required jobs finish.
    job_precede = @constraint(model, [i1 in Jobs, i2 in Jobs], Precedence[i1,i2] * (sum((t) * S[i2,j,t] for j in Machines, t in Horizon) - sum((t + durations[i1]) * S[i1,j,t] for j in Machines, t in Horizon)) >= 0)

    print(model)
    optimize!(model)

    status = termination_status(model)
    if status == MOI.OPTIMAL
        return status, objective_value(model), value.(C_max), value.(S)
    else
        return status, nothing, nothing, nothing
    end
end # job_shop


n = 9
m = 3
p = [1; 2; 1; 2; 1; 1; 3; 6; 2]
# Preceding relations
r = [(1,4) (2,4) (2,5) (3,4) (3,5) (4,6) (4,7) (5,7) (5,8) (6,9) (7,9)]


(status, obj, c_max, table) = job_shop(n,m,p,r)

if status == MOI.OPTIMAL
    println("funkcja celu: ", obj)
    # println("momenty rozpoczecia zadan: ", table)
    moments = multiple_start_times_to_finish_times(multiple_horizons_to_moments(table), p)
    println(moments)
    for j in 1:m
        for i in 1:n
            if moments[i,j] > -1
                println("(", j, ") ", i, ":\t[", moments[i,j] - p[i], "\t- ", moments[i,j], "]")
            end
        end
    end
    # print_machines(1:n, 1:m, p, moments)
    for j in 1:m
        print("M", j, "\t|")
        for t in 0:trunc(Int, c_max)
            counter = 0
            for i in 1:n
                if t < moments[i,j] && t >= moments[i,j] - p[i]
                    counter += 1
                    print(i)
                end
            end
            if counter == 0
                print("-")
            end
        end
        println()
    end
else
    println("Status: ", status)
end


