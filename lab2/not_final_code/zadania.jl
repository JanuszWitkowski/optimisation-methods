using JuMP
# using GLPK
using Cbc
# using CPLEX
include("job_printing.jl")


function job_flow(m, durations, weights, ready)
    Jobs = 1:m
    Precedence = [(i, k) for i in Jobs, k in Jobs if i < k]
    BigValue = 10 * sum(durations)

    # model = Model(GLPK.Optimizer)
    model = Model(Cbc.Optimizer)
    # model = Model(CPLEX.Optimizer)

    # Main decision variable - finish times for each job.
    @variable(model, C[Jobs] >= 0, Int)
    # Helper variable - puts jobs in proper order.
    @variable(model, DoesPrecede[Precedence], Bin)
    # Minimize this sum.
    @objective(model, Min, sum(weights[i] * C[i] for i in Jobs))
    # Do not start the job if it's not ready.
    @constraint(model, [i in Jobs], C[i] - durations[i] >= ready[i])
    # If job k precedes job i, it has to have time to finish before starting job i.
    @constraint(model, [(i,k) in Precedence], C[k] - C[i] + BigValue * (1 - DoesPrecede[(i,k)]) >= durations[k])
    # If job i precedes job k, it has to have time to finish before starting job k.
    @constraint(model, [(i,k) in Precedence], C[i] - C[k] + BigValue * DoesPrecede[(i,k)] >= durations[i])

    println(model)
    optimize!(model)

    termination_status(model)
    println("Objective value: ", objective_value(model))
    C = JuMP.value.(C)
    println("C: ", C)
    for i in Jobs
        println(i, ":\t[", C[i] - durations[i], "\t- ", C[i], "]")
    end
    print_job_solution(1, Jobs, durations, C)
end


# n = 5
# p = [3 2 4 5 1]
# w = [1.0 1.0 1.0 1.0 1.0]
# r = [2 1 3 1 0]
n = 5
r = [3 2 4 5 1]
p = [2 1 3 1 0]
w = [5 1 5 6 1]

job_flow(n, p, w, r)

