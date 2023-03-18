/* The shortest path problem in a directed graph G=<V,A> */

param n, integer, >= 2; # the number of nodes 

set V:={1..n};                  # the set of nodes 
set A  within V cross V;        # the set of arcs 

param c{(i,j) in A}, >= 0;      # cij  the cost of arc (i,j) 
param s, in V, default 1;       # source s  
param t, in V, != s, default n; # sink t 

var x{(i,j) in A}, >= 0, <= 1;
/* x[i,j] =1 if  arc belongs to the shortest path, 0 otherwise*/

minimize Cost: sum{(i,j) in A} c[i,j]*x[i,j];
s.t. node{i in V}:
   sum{(j,i) in A} x[j,i] + (if i = s then 1)
   = 
   sum{(i,j) in A} x[i,j] + (if i = t then 1);

solve;

data;

/* Wheastone bridge */


param n := 4;

param : A :   c :=
       1 2   1
       1 3   4
       2 3   2
       2 4    8
       3 4   5;

end;
