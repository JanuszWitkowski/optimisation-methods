#= OPTIMIZATION METHODS
ex 2.4 - Resources
Author: Janusz Witkowski 254663
=#

using JuMP
# using GLPK
using Cbc
# using CPLEX


function resource_management(n_of_resources,    # Number of resources.
                                limits,         # Limits for each renewable resouce.
                                n_of_jobs,      # Number of jobs.
                                durations,      # How much time does each job take.
                                demand,         # How much of each resource does each job require.
                                precedence      # Edges from graph of job's order.
    )

    T = sum(durations) + 1  # Length of the time horizon.
    Jobs = 1:n_of_jobs
    Resources = 1:n_of_resources
    Horizon = 1:T

    # model = Model(GLPK.Optimizer)
    model = Model(Cbc.Optimizer)
    # model = Model(CPLEX.Optimizer)

    # Starting schedule for jobs.
    @variable(model, S[Jobs,Horizon], Bin)
    # Helper variable - maximum of finish times.
    @variable(model, C_max >= 0)
    # Minimize the maximum delay.
    @objective(model, Min, C_max)
    # C_max is the maximum of all moments in C (= S + durations).
    max_delay = @constraint(model, [i in Jobs], sum((t-1) * S[i,t] for t in Horizon) + durations[i] <= C_max)
    # Each job can only be started once.
    start_once = @constraint(model, [i in Jobs], sum(S[i,t] for t in Horizon) == 1)
    # Do not let any job start before required jobs finish.
    job_precede = @constraint(model, [(i1,i2) in precedence], sum((t-1) * S[i2,t] for t in Horizon) - sum((t-1+durations[i1]) * S[i1,t] for t in Horizon) >= 0)
    # job_precede = @constraint(model, [(i1,i2) in precedence], sum((t-1) * S[i2,t] - (t-1+durations[i1]) * S[i1,t] for t in Horizon) >= 0)
    # Don't exceed limits of a resource during the process.
    resouce_limitations = @constraint(model, [e in Resources, t in Horizon], sum(sum(S[i,s] for s in max(1, t - durations[i] + 1):t) * demand[e,i] for i in Jobs) <= limits[e])

    print(model)
    optimize!(model)

    status = termination_status(model)
    if status == MOI.OPTIMAL
        return status, objective_value(model), value.(C_max), value.(S), solve_time(model)
    else
        return status, nothing, nothing, nothing, nothing
    end
end # resource_management

p = 1
N = [30]
n = 8
t = [50 47 55 46 32 57 15 62]
r = [9 17 11 4 13 7 7 17]
g = [(1,2),(1,3),(1,4),(2,5),(3,6),(4,6),(4,7),(5,8),(6,8),(7,8)]

(status, obj, c_max, table, stime) = resource_management(p,N,n,t,r,g)

if status == MOI.OPTIMAL
    c = trunc(Int, c_max) + 1
    for i in 1:n
        for s in 1:c
            if sum(table[i,max(1, s - t[i] + 1):s]) >= 0.9
                print(i)
            else
                print('-')
            end
        end
        println()
    end
    for i in 1:n
        for s in 1:c
            if table[i,s] >= 0.9
                println("Job ", i, ":\t[", s-1, " - ", s + t[i] - 1, "]")
                break
            end
        end
    end
    println("Funkcja celu: ", obj)
    println("Czas rozwiązania: ", stime)
else
    println("Status: ", status)
end

