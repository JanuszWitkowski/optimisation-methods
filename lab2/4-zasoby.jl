#= OPTIMIZATION METHODS
ex 2.4 - Resources
Author: Janusz Witkowski 254663
=#

using JuMP
# using GLPK
using Cbc
# using CPLEX

M = 1000

function solve(n, p, t, r, g)
    T = sum(t)
    u = [if (i1,i2) in g 1 else 0 end for i1 in 1:n, i2 in 1:n]

    # model = Model(GLPK.Optimizer)
    model = Model(Cbc.Optimizer)
    # model = Model(CPLEX.Optimizer)

    # starting moments for each task
    @variable(model, x[1:n,1:T], Bin)
    # C_max
    @variable(model, C >= 0)
    # each task starts one onece
    @constraint(model, [i in 1:n], sum(x[i,:]) == 1)
    # precedence from task data
    @constraint(model, [i in 1:n, j in 1:n; i < j && u[i,j] == 1], sum(x[i,time]*(time-1) for time in 1:T) + t[i] <= sum(x[j,time]*(time-1) for time in 1:T))
    # C_max is the max
    @constraint(model, [i in 1:n], C >= sum(x[i,time]*(time-1) for time in 1:T) + t[i])
    # resource constraints
    @constraint(model, [resource in 1:p, time in 1:T], sum(sum(x[i,max(1,time-t[i]+1):time])*r[resource,i] for i in 1:n) <= N[resource])
    @objective(model, Min, C)
    optimize!(model)
    for i in 1:n
        for w in 1:240
            if value.(sum(x[i,max(1,w-t[i]+1):w])) >= 0.9
                print("#")
            else
                print('-')
            end
        end
        print("\n")
    end
    println(value(C))
    println(solve_time(model))
end

n = 8
p = 1
N = [30]
t = [50 47 55 46 32 57 15 62]
r = [9 17 11 4 13 7 7 17]
g = [(1,2),(1,3),(1,4),(2,5),(3,6),(4,6),(4,7),(5,8),(6,8),(7,8)]

solve(n,p,t,r,g)
