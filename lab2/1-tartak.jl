#= OPTIMIZATION METHODS
ex 2.1 - Sawmill
Author: Janusz Witkowski 254663
=#

using JuMP
using GLPK
# using Cbc


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

function unused(x, cuts, demand, widths, n_of_cuts, n_of_widths)
    return sum((sum(cuts[i, j] * x[i] for i in 1:n_of_cuts) - demand[j]) * widths[j] for j in 1:n_of_widths)
end

function leftovers(x, main_width, widths, cuts, n_of_cuts, n_of_widths)
    return sum(x[i] * (main_width - sum(widths[j] * cuts[i, j] for j in 1:n_of_widths)) for i in 1:n_of_cuts)
end


# PARAMETERS GIVEN
main_width = 22
widths = [7 5 3]
demand = [110 120 80]
# main_width = 12
# widths = [4 5]
# demand = [20 100]

# PARAMETERS CALCULATED
n_of_widths = length(widths)
cuts = []
calc_cuts!(cuts, [0 for _ in 1:n_of_widths], main_width, widths, n_of_widths)
cuts = unique(cuts)
n_of_cuts = length(cuts)
cuts = mapreduce(permutedims, vcat, cuts)


model = Model(GLPK.Optimizer)
# model = Model(Cbc.Optimizer)
@variable(model, 0 <= x[i = 1:n_of_cuts], integer=true)
@objective(model, Min, unused(x, cuts, demand, widths, n_of_cuts, n_of_widths) + leftovers(x, main_width, widths, cuts, n_of_cuts, n_of_widths))
c_good_cuts = @constraint(model, [i = 1:n_of_cuts], sum(cuts[i, j] for j in 1:n_of_widths) <= main_width)        # These have to be good cuts
c_supply_demand = @constraint(model, [j = 1:n_of_widths], sum(cuts[i, j] * x[i] for i in 1:n_of_cuts) >= demand[j])    # Supply the demand
println(model)
optimize!(model)

termination_status(model)
println("Objective value: ", objective_value(model))
x = JuMP.value.(x)
println("Solution: ", x)
println("Possible cuts: ", cuts)
println("Unused: ", unused(x, cuts, demand, widths, n_of_cuts, n_of_widths))
println("Leftovers: ", leftovers(x, main_width, widths, cuts, n_of_cuts, n_of_widths))

