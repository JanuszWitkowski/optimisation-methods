#= OPTIMIZATION METHODS
ex 2.1 - Sawmill
Author: Janusz Witkowski 254663
=#

using JuMP
# using GLPK
using Cbc
# using CPLEX


# Calculate all different ways to cuts lesser planks from the main one.
function calc_cuts!(cuts, current_cut, current_width, widths, n_of_widths)
    counter = 0
    for i in 1:n_of_widths
        if current_width >= widths[i]
            counter += 1
            new_cut = [cut for cut in current_cut]
            new_cut[i] += 1
            new_width = current_width - widths[i]
            calc_cuts!(cuts, new_cut, new_width, widths, n_of_widths)
        end
    end
    if counter == 0
        push!(cuts, current_cut)
    end
end

# How many produces planks are over the demand.
function unused(x, cuts, demand, widths, n_of_cuts, n_of_widths)
    return sum((sum(cuts[i, j] * x[i] for i in 1:n_of_cuts) - demand[j]) * widths[j] for j in 1:n_of_widths)
end

# Count all mini-planks that will be left from imperfect cuts.
function leftovers(x, main_width, widths, cuts, n_of_cuts, n_of_widths)
    return sum(x[i] * (main_width - sum(widths[j] * cuts[i, j] for j in 1:n_of_widths)) for i in 1:n_of_cuts)
end


function sawmill(main_width::Int,       # Width of a main plank.
                widths::Matrix{Int},    # All widths required.
                demand::Matrix{Int}     # Amount of widths required.
    )

    # PARAMETERS CALCULATED
    n_of_widths = length(widths)
    cuts = []   # All different cuts possible.
    calc_cuts!(cuts, [0 for _ in 1:n_of_widths], main_width, widths, n_of_widths)
    cuts = unique(cuts)
    n_of_cuts = length(cuts)
    cuts = mapreduce(permutedims, vcat, cuts)

    # model = Model(GLPK.Optimizer)
    model = Model(Cbc.Optimizer)
    # model = Model(CPLEX.Optimizer)

    # How many planks do we cut with a specific cut.
    @variable(model, 0 <= x[i = 1:n_of_cuts], integer=true)
    # Minimize number of lost planks [in units].
    @objective(model, Min, unused(x, cuts, demand, widths, n_of_cuts, n_of_widths) + leftovers(x, main_width, widths, cuts, n_of_cuts, n_of_widths))
    # These have to be good cuts (safety constraint).
    c_good_cuts = @constraint(model, [i = 1:n_of_cuts], sum(cuts[i, j] for j in 1:n_of_widths) <= main_width)              
    # Supply the demand.
    c_supply_demand = @constraint(model, [j = 1:n_of_widths], sum(cuts[i, j] * x[i] for i in 1:n_of_cuts) >= demand[j])    
    
    println(model)
    optimize!(model)

    termination_status(model)
    println("Objective value: ", objective_value(model))
    x = JuMP.value.(x)
    println("Possible cuts: ", cuts)
    println("Solution: ", x)
    println("Planks used: ", sum(x[j] for j in 1:n_of_cuts))
    println("Planks produced:")
    for i in 1:n_of_widths
        println(widths[i], ":\t", sum(x[j] * cuts[j,i] for j in 1:n_of_cuts))
    end
    println("Unused: ", unused(x, cuts, demand, widths, n_of_cuts, n_of_widths))
    println("Leftovers: ", leftovers(x, main_width, widths, cuts, n_of_cuts, n_of_widths))
end


# PARAMETERS GIVEN
# m = 22
# w = [7 5 3]
# d = [110 120 80]
m = 22
w = [7 5 3]
d = [110 129 80]
# m = 12
# w = [4 5]
# d = [20 100]

sawmill(m, w, d)
