/* The shortest path problem in a complete acyclic graph G=(V,A)*/
/* Graph G is acyclic and complete, arc costs are randomly generated from interval [a,b] */
    

param n, integer, >= 2;
/* the number of nodes */

set V :={1..n};
/* the set of nodes */


set A:={i in V, j in V:i<j};
/* the set of arcs in the complete acyclic graph*/



param a >=0;
param b, >a;
/* the interval of costs */

param c{(i,j) in A}, >= 0 :=Uniform(a,b);
/* cij  the cost of arc (i,j) */
/* the costs are randomly generated according to uniform distribution */

param s, in V, default 1;
/* source s  */

param t, in V, != s, default n;
/* sink t */

var x{(i,j) in A}, >= 0, <= 1;
/* x[i,j] =1 if  arc (i,j) belongs to the shortest path, 0 otherwise*/


minimize Cost: sum{(i,j) in A} c[i,j]*x[i,j];






s.t. nodes{i in V}:
/*mass balance constraints */

   sum{(j,i) in A} x[j,i] + (if i = s then 1)
   /* the sum of inflow of node i */

   = 

   sum{(i,j) in A} x[i,j] + (if i = t then 1);
   /* the sum of outflow of node i */


solve;

/* output of results on screen */
display 'generated costs';
display {(i,j) in A}: c[i,j];

display 'solution';
display {(i,j) in A: x[i,j]!=0 }: x[i,j];


/* data are in the separated file path1.dat */