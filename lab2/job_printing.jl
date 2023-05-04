function horizon_to_moments(horizon)
    (n,m) = size(horizon)
    C = [0 for _ in 1:n]
    for i in 1:n
        for j in 1:m
            if horizon[i,j] == 1.0
                C[i] = j-1
                break
            end
        end
    end
    return C
end

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
        print_hyphen = true
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
                # print("  ")
                print_hyphen = false
            # else
            #     print_hyphen = false
                # println(c_i)
            # else
            #     print("-")
            end
        end
        if print_space
            if print_hyphen
                print("--")
            else
                print("  ")
            end
        end
    end
    println()
end

function print_machines(machines, jobs, durations, c)
    for i in machines
        print_job_solution(i, jobs, durations, c)
    end
end