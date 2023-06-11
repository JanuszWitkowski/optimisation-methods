import matplotlib.pyplot as plt
import csv

quotients = []
quo_times = []
times_opt = []
times_apx = []
makespans_apx = []
makespans_opt = []

# INSTANCE_NAME   = "10a100"
# INSTANCE_NAME   = "100a120"
# INSTANCE_NAME   = "100a200"
INSTANCE_NAME   = "1000a1100"

GRAPH_NAME      = "wykres_"
FILE_MAKESPAN   = "makespans" + INSTANCE_NAME + ".csv"
FILE_OPT        = "opt" + INSTANCE_NAME + ".csv"
FILE_QUOTIENTS  = GRAPH_NAME + INSTANCE_NAME + "_stosunki" + ".png"
FILE_TIMES      = GRAPH_NAME + INSTANCE_NAME + "_czasy" + ".png"
FILE_TIMES_QUO  = GRAPH_NAME + INSTANCE_NAME + "_czasy_lim" + ".png"

if __name__ == "__main__":
    with open(FILE_MAKESPAN) as csvfile:
            reader = csv.reader(csvfile, delimiter=';')
            for row in reader:
                # quotients.append(float(row[1]))
                # times_apx.append(float(row[2]))
                # times_opt.append(float(row[3]))
                makespans_apx.append(float(row[1]))
                times_apx.append(float(row[2]))
    with open(FILE_OPT) as csvfile:
            reader = csv.reader(csvfile, delimiter=';')
            for row in reader:
                makespans_opt.append(float(row[1]))
                times_opt.append(float(row[4]))
    
    for idx, _ in enumerate(makespans_apx):
        quotients.append(makespans_apx[idx] / makespans_opt[idx])
    
    for idx, _ in enumerate(times_apx):
        quo_times.append(times_opt[idx] / times_apx[idx])

    plt.plot(range(200), quotients)
    plt.plot(range(200), [1] * 200)
    plt.plot(range(200), [2] * 200)
    plt.xlabel("Instancje")
    plt.ylabel("c = Cmax_approx/Cmax_opt")
    plt.savefig(FILE_QUOTIENTS, dpi=300)
    plt.close()

    plt.plot(range(200), times_apx, label='Aproksymacja')
    plt.plot(range(200), times_opt, label='Optymalizacja CPLEX')
    plt.xlabel("Instancje")
    plt.ylabel("Czas wykonania")
    plt.legend()
    plt.savefig(FILE_TIMES, dpi=300)
    plt.close()

    plt.plot(range(200), quo_times)
    plt.plot(range(200), [0] * 200)
    plt.xlabel("Instancje")
    plt.ylabel("Stosunki czasów wykonania time_opt/time_approx")
    plt.savefig(FILE_TIMES_QUO, dpi=300)
    plt.close()

