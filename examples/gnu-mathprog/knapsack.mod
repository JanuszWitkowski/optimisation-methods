/* 
The multidimensional zero-one knapsack problem
can be described as follows: given two sets of n items and m
 knapsack constraints (or resources), for each item j a profit p_j 
is assigned and for each constraint i a consumption value r_ij is designated. 
 The goal is to determine a set of items that maximizes the total profit, not exceeding the given constraint capacities $c_i$.

Written in GNU MathProg by Pawel Zielinski

*/



/* Parameters */
param n>0 integer; /* the number of items */
param m>0 integer; /* the number of resources */

/* Sets declared in more elegant way*/
set Items:=1..n; 
set Resources:=1..m;

/* parametry */

param capacity{Resources}>=0;  /* array  represents the capacity of the resources*/
param consumption{Resources,Items}>=0; /* the consumption of resource  by item */
param profit{Items}>=0;  /* array  the value of each item */


/* Decision variables */

/* variable */
var choose{Items} >=0 binary;



/* Objective function */

maximize Value: sum{j in Items} profit[j]*choose[j];

/* Constraints */
s.t. ResourceConstraints{i in Resources}: sum{j in Items} consumption[i,j]*choose[j] <= capacity[i];
solve;

display{j in Items: choose[j]=1} choose[j];

/* Data */

data;

param n:=13;
param m:=7;
param profit:= 
         1  95 
         2  75 
         3  55 
         4  12 
         5  86 
         6  11 
         7  66 
         8  83 
         9  83 
         10 10 
         11 9 
         12 8
         13 7;
param consumption:1      2     3    4    5    6    7   8   9    10    11    12 13:=
      1    19 1 10 1 1 14 152 11 1 1 1 1  3
      2    0 4 53 0 0 80 0 4 5 0 0 0 4 
      3    4 660 3 0 30 0 3 0 4 90 0 0  6 
      4    7 0 18 6 770 330 7 0 0 6 0 0  8 
      5    1 20 0 0 52 3 0 0 0 5 4 0 3
      6    0 0 40 70 4 63 0 0 60 0 4 0  3
      7    0 33 0 0 0 5 0 3 0 661 0 10 1;

param capacity:= 
          1 182 
          2 73 
          3 788 
          4 924 
          5 266 
          6 78 
          7 809;    
end;