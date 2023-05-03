using JuMP
using GLPK
# using Cbc
# using CPLEX
include("job_printing.jl")

# function my_maximum(C)
#     C_max = C[1]
#     for i in 2:length(C)
#         if C[i] > C_max
#             C_max = C[i]
#         end
#     end
# end


function job_shop(n, m, durations)
    Jobs = 1:n      # indexing with i
    Machines = 1:m  # indexing with j
    Precedence = [(j,i,k) for j in Machines, i in Jobs, k in Jobs if i < k]
    BigValue = 10 * sum(durations)

    model = Model(GLPK.Optimizer)
    # model = Model(Cbc.Optimizer)
    # model = Model(CPLEX.Optimizer)

    # Main decision variable - finish times for each job.
    @variable(model, C[Jobs] >= 0, Int)
    # 
    @variable(model, 1 <= M[Jobs] <= m, Int)
    # Helper variable - puts jobs in proper order.
    @variable(model, DoesPrecede[Precedence], Bin)
    # 
    @variable(model, C_max >= 0, Int)
    # Minimize this sum.
    @objective(model, Min, C_max)
    # # Do not start the job if it's not ready.
    # @constraint(model, [i in Jobs], C[i] - durations[i] >= ready[i])
    # 
    @constraint(model, [i in Jobs], C_max >= C[i])
    # If job k precedes job i, it has to have time to finish before starting job i.
    @constraint(model, [(j,i,k) in Precedence], C[k] - C[i] + BigValue * (1 - DoesPrecede[(j,i,k)]) >= durations[k])
    # If job i precedes job k, it has to have time to finish before starting job k.
    @constraint(model, [(j,i,k) in Precedence], C[i] - C[k] + BigValue * DoesPrecede[(j,i,k)] >= durations[i])

    println(model)
    optimize!(model)

    termination_status(model)
    println("Objective value: ", objective_value(model))
    C = JuMP.value.(C)
    println("C: ", C)
    for i in Jobs
        println(i, ":\t[", C[i] - durations[i], "\t- ", C[i], "]")
    end
    print_machines(Machines, Jobs, durations, C)
end

m = 3
n = 9
p = [1 2 1 2 1 1 3 6 2]

job_shop(n, m, p)
