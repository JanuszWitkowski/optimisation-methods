using JuMP
#using CPLEX 
# using GLPK
using Cbc
include("job_printing.jl")


function job_flow(n::Int,
                    durations::Vector{Int},
	           		ready::Vector{Int},
	        		weights::Vector{Float64};
					verbose = true)

    #  n - liczba zadan
    #  durations - wektor czasow wykonania zadan
    #  ready - wektor momentow dostepnosci zadan
    #  weights - wektor wag zadan
    # verbose - true, to kominikaty solvera na konsole 		

    T = maximum(ready) + sum(durations) + 1 # dlugosc horyzontu czasowego
    Jobs = 1:n
    Horizon = 1:T

    # wybor solvera
    # model = Model(CPLEX.Optimizer) # CPLEX		
    # model = Model(GLPK.Optimizer) # GLPK
    model = Model(Cbc.Optimizer) # Cbc the solver for mixed integer programming


    # # Finish schedule for jobs.
    # @variable(model, C[Jobs,Horizon], Bin) 
    # # Minimize the sum of delays.
    # @objective(model, Min, sum(weights[j] * C[j,t] * (t-1) for j in Jobs, t in Horizon)) 
    # # Each job can be finished only once.
    # @constraint(model, [j in Jobs], sum(C[j,t] for t in Horizon) == 1)
    # # Do not start the job if it's not ready.
    # @constraint(model, [j in Jobs], sum((t-1) * C[j,t] for t in Horizon) - durations[j] >= ready[j])
    # # Jobs cannot overlap.
    # @constraint(model, [t in Horizon], sum(C[j,s] for j in Jobs, s in max(1, t - durations[j] + 1):t) <= 1)

    # # Finish schedule for jobs.
    # @variable(model, C[Jobs,Horizon], Bin) 
    # # Minimize the sum of delays.
    # @objective(model, Min, sum(weights[j] * C[j,t] * (t) for j in Jobs, t in Horizon)) 
    # # Each job can be finished only once.
    # @constraint(model, [j in Jobs], sum(C[j,t] for t in Horizon) == 1)
    # # Do not start the job if it's not ready.
    # @constraint(model, [j in Jobs], sum((t) * C[j,t] for t in Horizon) - durations[j] >= ready[j])
    # # Jobs cannot overlap.
    # @constraint(model, [t in Horizon], sum(C[j,s] for j in Jobs, s in max(1, t - durations[j] + 1):t) <= 1)

    # 1 dla momentu rozpoczecia zadania
    @variable(model, 0 <= C[Jobs, Horizon] <= 1, Bin)
    # jeden moment rozpoczęcia
    @constraint(model, [j in Jobs], sum(C[j, t] for t in 1:T) == 1)
    # jeden na raz
    @constraint(model, [t in Horizon], sum(C[j, s] for j in Jobs, s in max(1, t-durations[j]+1):t) <= 1)
    # nie zaczynamy wczesniej niz mozna
    @constraint(model, [j in Jobs], sum(t * C[j, t] for  t in 1:T) >= ready[j])
    @objective(model, Min, sum(weights[j] * (t + durations[j]) * C[j, t] for j in Jobs, t in Horizon)) 


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

    if status== MOI.OPTIMAL
            return status, objective_value(model), value.(C)
        else
            return status, nothing, nothing
        end
        
end # job_flow

# Number of jobs.
n = 5
# Durations of jobs.
p=[ 3; 2; 4; 5; 1 ]
# Ready moments of jobs.
r=[ 2; 1; 3; 1; 0 ]	
# Weights of jobs.	
w=[ 1.0; 1.0; 1.0; 1.0; 1.0 ]		
# n = 5
# r = [1; 2; 3; 4; 5]
# p = [2; 3; 4; 5; 6]
# w = [1.0; 2.0; 3.0; 4.0; 5.0]					 


(status, fcelu, table) = job_flow(n,p,r,w)

if status == MOI.OPTIMAL
    println("funkcja celu: ", fcelu)
    println("momenty rozpoczecia zadan: ", table)
    moments = start_times_to_finish_times(horizon_to_moments(table), p)
    for i in 1:n
        println(i, ":\t[", moments[i] - p[i], "\t- ", moments[i], "]")
        # println(i, ":\t[", moments[i] + 1, "\t- ", moments[i] + p[i] + 1, "]")
    end
    print_job_solution(1, 1:n, p, moments)
else
    println("Status: ", status)
end


