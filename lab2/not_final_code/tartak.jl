#= OPTIMIZATION METHODS
ex 2.1 - Sawmill
Author: Janusz Witkowski 254663
=#

using JuMP
using GLPK


function unused(x, cuts, demand, widths, n_of_cuts, n_of_widths)
    return sum((sum(cuts[i, j] * x[i] for i in 1:n_of_cuts) - demand[j]) * widths[j] for j in 1:n_of_widths)
end

function leftovers(x, main_width, widths, cuts, n_of_cuts, n_of_widths)
    return sum(x[i] * (main_width - sum(widths[j] * cuts[i, j] for j in 1:n_of_widths)) for i in 1:n_of_cuts)
end


# PARAMETERS GIVEN
main_width = 22
n_of_widths = 3
widths = [7 5 3]
demand = [110 120 80]
n_of_cuts = 12
cuts = [3 0 0; 2 1 1; 2 0 2; 1 3 0; 1 2 1; 1 1 3; 1 0 5; 0 4 0; 0 3 2; 0 2 4; 0 1 5; 0 0 7]


model = Model(GLPK.Optimizer)
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

