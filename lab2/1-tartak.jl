using JuMP
using HiGHS

# function ()
    
# end

main_width = 22
n_of_widths = 3
widths = [7 5 3]
demand = [110 120 80]
n_of_cuts = 12
cuts = [3 0 0; 2 1 1; 2 0 2; 1 3 0; 1 2 1; 1 1 3; 1 0 5; 0 4 0; 0 3 2; 0 2 4; 0 1 5; 0 0 7]

model = Model(HiGHS.Optimizer)
@variable(model, 0 <= x[i = 1:n_of_cuts], integer=true)
@objective(model, Min, sum(sum(cuts[i, j] * x[i] for i in 1:n_of_cuts) - demand[j] for j in 1:n_of_widths) + sum(main_width * x[i] - sum(cuts[i, j] * x[i] for j in 1:n_of_widths) for i in 1:n_of_cuts))
for i in 1:n_of_cuts
    @constraint(model, sum(cuts[i, j] for j in 1:n_of_widths) <= main_width)
end
for j in 1:n_of_widths
    @constraint(model, sum(cuts[i, j] * x[i] for i in 1:n_of_cuts) >= demand[j])
end
println(model)
optimize!(model)
termination_status(model)
println("Objective value: ", objective_value(model))
# JuMP.value.(x)
println("x: ", JuMP.value.(x))
