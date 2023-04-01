/* OPTIMIZATION METHODS
ex 1.1 - Hilbert's Matrix
Author: Janusz Witkowski 254663
*/

param n, integer, > 0;  # Size of the matrix; we'll be toying with it to see how errors grow
set N := {1..n};        # Solution vector; also our range

param A{i in N, j in N} := 1/(i + j - 1);   # Hilbert's Matrix
param B{i in N} := sum{j in N}(A[i,j]);     # Constraints vector
param C{i in N} := B[i];

var X{j in N}, >= 0;     # Decision variable; will be useful in error showcase

# Objective function, given in Hilbert's Matrix task
minimize objective_function: sum{i in N} C[i] * X[i];

# Constraint, given in Hilbert's Martix task
s.t. equality{i in N}: sum{j in N}(A[i, j] * X[j]) = B[i];

solve;

# Printing results
display X;
printf "\n";
printf "n = %d\n", n;
printf "error = %f\n", sqrt(sum{i in N}(1 - X[i])*(1 - X[i])) / sqrt(n);

end;
