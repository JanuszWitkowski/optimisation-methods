using JuMP
#using CPLEX 
# using GLPK
using Cbc
include("job_printing.jl")


function job_flow(n::Int, m::Int,
                    durations::Vector{Int},
					verbose = true)

    #  n - liczba zadan
    #  m - liczba maszyn
    #  durations - wektor czasow wykonania zadan
    # verbose - true, to kominikaty solvera na konsole 		

    T = sum(durations) + 1 # dlugosc horyzontu czasowego
    Jobs = 1:n
    Machines = 1:m
    Horizon = 1:T

    # wybor solvera
    # model = Model(CPLEX.Optimizer) # CPLEX		
    # model = Model(GLPK.Optimizer) # GLPK
    model = Model(Cbc.Optimizer) # Cbc the solver for mixed integer programming


    # Finish schedule for jobs.
    @variable(model, C[Jobs,Machines,Horizon], Bin) 
    # Helper variable - maximum of C
    @variable(model, C_max >= 0, Int)

    # Minimize the sum of delays.
    @objective(model, Min, C_max) 

    # C_max is the maximum of all moments in C.
    @constraint(model, [i in Jobs], sum((t-1) * C[i,j,t] for j in Machines, t in Horizon) <= C_max)
    # Each job can be finished only once.
    @constraint(model, [i in Jobs], sum(C[i,j,t] for j in Machines, t in Horizon) == 1)
    # Do not start the job before time=0.
    @constraint(model, [i in Jobs], sum((t-1) * C[i,j,t] for j in Machines, t in Horizon) - durations[i] >= 0)
    # Jobs cannot overlap (while on the same machine).
    @constraint(model, [j in Machines, t in Horizon], sum(C[i,j,s] for i in Jobs, s in max(1, t - durations[i]):t) <= 1)

    print(model) # drukuj model
    # rozwiaz egzemplarz
    if verbose
        optimize!(model)		
    else
        set_silent(model)
        optimize!(model)
        unset_silent(model)
    end

    status=termination_status(model)
    println("T=", T)

    if status== MOI.OPTIMAL
            return status, objective_value(model), value.(C_max), value.(C)
        else
            return status, nothing, nothing, nothing
        end
        
end # job_flow

# # Number of jobs.
# n = 5
# # Durations of jobs.
# p=[ 3; 2; 4; 5; 1 ]
# # Ready moments of jobs.
# r=[ 2; 1; 3; 1; 0 ]	
# # Weights of jobs.	
# w=[ 1.0; 1.0; 1.0; 1.0; 1.0 ]

n = 9
m = 3
p = [1; 2; 1; 2; 1; 1; 3; 6; 2]


(status, fcelu, c_max, table) = job_flow(n,m,p)

if status == MOI.OPTIMAL
    println("funkcja celu: ", fcelu)
    # println("momenty rozpoczecia zadan: ", table)
    moments = multiple_horizons_to_moments(table)
    println(moments)
    for j in 1:m
        for i in 1:n
            if moments[i,j] > -1
                println("(", j, ") ", i, ":\t[", moments[i,j] - p[i], "\t- ", moments[i,j], "]")
            end
        end
    end
    print_machines(1:n, 1:m, p, moments)
else
    println("Status: ", status)
end


