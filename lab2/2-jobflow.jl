#= OPTIMIZATION METHODS
ex 2.2 - Job Flow (single machine)
Author: Janusz Witkowski 254663
=#

using JuMP
# using GLPK
using Cbc
# using CPLEX 
include("job_printing.jl")


function job_flow(n_of_jobs::Int,               # Number of jobs.
                    durations::Vector{Int},     # How much time does each job take.
	           		ready::Vector{Int},         # Each job cannot start before it's ready.
	        		weights::Vector{Float64}    # Weights of each job, used in objective function.
    )

    T = maximum(ready) + sum(durations) + 1 # Length of the time horizon.
    Jobs = 1:n_of_jobs
    Horizon = 1:T

    # model = Model(GLPK.Optimizer)
    model = Model(Cbc.Optimizer)
    # model = Model(CPLEX.Optimizer)

    # Starting schedule for jobs (will be translated to finish times for objective function).
    @variable(model, C[Jobs, Horizon], Bin)
    # Minimize the sum of delays.
    @objective(model, Min, sum(weights[j] * ((t-1) + durations[j]) * C[j, t] for j in Jobs, t in Horizon)) 
    # Each job can only be started once.
    start_once = @constraint(model, [j in Jobs], sum(C[j, t] for t in Horizon) == 1)
    # Do not start the job if it's not ready.
    jobs_ready = @constraint(model, [j in Jobs], sum((t-1) * C[j, t] for t in Horizon) >= ready[j])
    # Jobs cannot overlap.
    no_overlap = @constraint(model, [t in Horizon], sum(C[j, s] for j in Jobs, s in max(1, t - durations[j] + 1):t) <= 1)

    print(model)
    optimize!(model)

    status = termination_status(model)
    if status == MOI.OPTIMAL
        return status, objective_value(model), value.(C)
    else
        return status, nothing, nothing
    end
end # job_flow


# Number of jobs.
n = 5
# Durations of jobs.
p = [ 3; 2; 4; 5; 1 ]
# Ready moments of jobs.
r = [ 2; 1; 3; 1; 0 ]	
# Weights of jobs.	
w = [ 5.0; 1.0; 5.0; 6.0; 1.0 ]		
# n = 5
# r = [1; 2; 3; 4; 5]
# p = [2; 3; 4; 5; 6]
# w = [1.0; 2.0; 3.0; 4.0; 5.0]
# n = 3
# r = [17; 3; 4]
# p = [5; 11; 15;]
# w = [3.0; 2.0; 1.0]
# n = 1
# r = [0]
# p = [0]
# w = [42.0]

(status, obj, table) = job_flow(n,p,r,w)

if status == MOI.OPTIMAL
    println("funkcja celu: ", obj)
    println("momenty rozpoczecia zadan: ", table)
    moments = horizon_to_moments(table)
    moments = start_times_to_finish_times(moments, p)
    for i in 1:n
        println(i, ":\t[", moments[i] - p[i], "\t- ", moments[i], "]")
    end
    print_job_solution(1, 1:n, p, moments)
else
    println("Status: ", status)
end


