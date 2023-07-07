using JuMP
using GLPK
# using Cbc

function end_begin_str(job, jobs, durations, c, is_begin)
    if is_begin
        for j in jobs
            if job != j
                if c[j] == c[job] - durations[job]
                    return "|"
                end
            end
        end
        return "["
    else
        for j in jobs
            if job != j
                if c[job] == c[j] - durations[j]
                    return " "
                end
            end
        end
        return "]"
    end
end

function print_job_solution(index, jobs, durations, c)
    c_max = maximum(c)
    print("M", index, "\t|")
    for c_i in 0:c_max
        # tmp = j
        # modulus = 0
        # while tmp > 0
        #     modulus += 1
        #     tmp /= 10
        # end
        print_space = true
        for j in jobs
            if c_i == c[j] - durations[j]
                # print("[", j)
                print(end_begin_str(j, jobs, durations, c, true), j)
                print_space = false
            elseif c_i == c[j]
                # print("]")
                print(end_begin_str(j, jobs, durations, c, false), " ")
                print_space = false
            elseif c_i > c[j] - durations[j] && c_i < c[j]
                print("  ")
                print_space = false
                # println(c_i)
            # else
            #     print("-")
            end
        end
        if print_space
            print("  ")
        end
    end
    println()
end


function job_flow(jobs, durations, weights, ready)
    model = Model(GLPK.Optimizer)
    # model = Model(Cbc.Optimizer)
    @variable(model, 0 <= c[j = 1:jobs], Int)
    # Helper variable
    @variable(model, 0 <= schedule)
    @objective(model, Min, sum(weights[j] * c[j] for j in 1:jobs))
    for j in 1:jobs
        @constraint(model, c[j] - durations[j] >= ready[j])     # Do not start a job before it's ready.
    end
    # for j in 1:jobs
    #     for i in 1:jobs
    #         # @constraint(model, (i == j) || ((c[j] <= c[i] && c[j] <= c[i] - durations[i]) || (c[j] >= c[i] && c[j] >= c[i] - durations[i])))
    #         if i != j
    #             # @constraint(model, ((c[j] <= c[i] && c[j] <= c[i] - durations[i]) + (c[j] >= c[i] && c[j] >= c[i] - durations[i])) == 1)
    #             @constraint(model, (c[j] - c[i]) * (c[j] - c[i] + durations[i]) >= 0)   # NON-LINEAR!!
    #         end
    #     end
    # end
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

# print_job_solution(1, [1 2 3], [2 4 6], [2 6 15])

