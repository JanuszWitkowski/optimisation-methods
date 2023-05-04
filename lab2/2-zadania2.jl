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
    #model = Model(CPLEX.Optimizer) # CPLEX		
    #  model = Model(GLPK.Optimizer) # GLPK
    model = Model(Cbc.Optimizer) # Cbc the solver for mixed integer programming


    #  zmienne moment zakończenia j-tego zadania
    # tjt=1 jesli zadanie rozpoczyna sie w momencie t-1; t in Horizon 
    # 0 w.p.p
    @variable(model, C[Jobs,Horizon], Bin) 

    # minimalizacja sumy wazonych opoznien zadan
    @objective(model, Min, sum(weights[j] * C[j,t] * (t-1) for j in Jobs, t in Horizon)) 

    # dokladnie jeden moment zakończenia j-tego zadania
    @constraint(model, [j in Jobs], sum(C[j,t] for t in 1:T) == 1)

    # moment zakończenia j-tego zadania co najmniej jak moment gotowosci rj zadania
    @constraint(model, [j in Jobs], sum((t-1) * C[j,t] for t in 1:T) - durations[j] >= ready[j])
    # zadania nie nakladaja sie na siebie
    @constraint(model, [t in Horizon], sum(C[j,s] for j in Jobs, s in max(1, t - durations[j]):t) <= 1)


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
            return status, nothing,nothing
        end
        
end # job_flow

n = 5
# czasy wykonia j-tego zadania 
p=[ 3; 2; 4; 5; 1 ]
# momenty dostepnosci j-tego zadania
r=[ 2; 1; 3; 1; 0 ]	
# wagi j-tego zadania		
w=[ 1.0; 1.0; 1.0; 1.0; 1.0 ]							 


(status, fcelu, table) = job_flow(n,p,r,w)

if status == MOI.OPTIMAL
    println("funkcja celu: ", fcelu)
    println("momenty rozpoczecia zadan: ", table)
    moments = horizon_to_moments(table)
    for i in 1:n
        println(i, ":\t[", moments[i] - p[i], "\t- ", moments[i], "]")
    end
        print_job_solution(1, 1:n, p, moments)
    else
    println("Status: ", status)
end


