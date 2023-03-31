/* Define the parameters */
param n >= 1 integer;
param eps > 0;

/* Define the decision variables */
var x{i in 1..n} >= 0;

/* Define the objective function */
minimize obj: sum{i in 1..n} x[i];

/* Define the constraints */
s.t. constr1{i in 1..n}: sum{j in 1..n} (1/(i+j-1)) * x[j] = sum{j in 1..n} (1/(i+j-1));

s.t. constr2: abs(obj - n) <= eps;

/* Solve the problem */
solve;

/* Display the solution */
printf "n = %d, solution = ", n;
for {i in 1..n} {
  printf "%g ", x[i];
}
printf "\n";
