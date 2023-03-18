/*  
Set E={1,2,...,n} be a given set of items. A nonnegative real cost c_i is associated with every item i \in E and we wish to choose a subset X subset E that contains exactly p items, whose total cost sum_{i\in X} c_i is minimal.

Written in GNU MathProg by Pawel Zielinski
*/

/* input data */
param n, integer, >= 1;     # the number of items
param p, integer, >= 1, <n; # the number of items for selecting
set E:={1..n};              # the set of items
param c{E} >=0;             # the costs of items

/* The variables */ 
var x{E} binary;

/* The objective function */
minimize TotalCost: sum{i in E} c[i]*x[i];
/* The constraint */
s.t. exact_p: sum{i in E} x[i] = p; 
solve;

/* Displaying  results */
display 'solution X';
display{i in E: x[i]=1 }: x[i];
display 'total costs=',sum{i in E} c[i]*x[i];

/* Data section */
data;
param n:=10;
param p:=6;
param c:=[1] 3 [2] 2 [3] 6 [4] 3 [5] 9 [6] 5 [7] 8 [8]  1 [9] 2 [10] 6;
end;

