

param n, integer, > 0;
/* rozmiar macierzy Hilberta */

param A{i in {1..n}, j in {1..n}} := 1/(i + j - 1);
param b{i in {1..n}} := sum{j in {1..n}}(1/(i + j - 1));
param c{i in {1..n}} := b[i];

var x{i in {1..n}}, >= 0;

minimize cost: sum{i in {1..n}} x[i] * c[i];

subject to solution{i in {1..n}}: sum{j in {1..n}} x[i] * A[i, j] = b[i];

solve;

