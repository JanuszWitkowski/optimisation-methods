using JuMP
using HiGHS

function job_flow(jobs, durations, weights, ready)
    model = Model(HiGHS.Optimizer)
    @variable(model, 0 <= c[j = 1:jobs], Int)
    @objective(model, Min, sum(weights[j] * c[j] for j in 1:jobs))
    for j in 1:jobs
        @constraint(model, c[j] - durations[j] >= ready[j])     # Do not start a job before it's ready.
    end
    for j in 1:jobs
        for i in 1:jobs
            # @constraint(model, (i == j) || ((c[j] <= c[i] && c[j] <= c[i] - durations[i]) || (c[j] >= c[i] && c[j] >= c[i] - durations[i])))
            if i != j
                @constraint(model, ((c[j] <= c[i] && c[j] <= c[i] - durations[i]) + (c[j] >= c[i] && c[j] >= c[i] - durations[i])) == 1)
            end
        end
    end
    println(model)
    optimize!(model)

    termination_status(model)
    println("Objective value: ", objective_value(model))
    c = JuMP.value.(c)
    println("c: ", c)
    for j in 1:jobs
        println(j, ":\t[", c[j] - durations[j], "\t- ", c[j], "]")
    end
end


# println(typeof(ARGS))
# println(length(ARGS))
jobs = 3
durations = [24 36 13]
weights = [17 18 19]
ready = [12 23 13]

job_flow(jobs, durations, weights, ready)

