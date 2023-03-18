/* The spanning tree problem G=<E,V> 
Written in GNU MathProg by Pawel Zielinski
*/

param n, integer, >= 2;
/* the number of nodes */

set V:={1..n};
/* the set of nodes */

set E  within V cross V;
/* the set of edges */

set A :=E union setof{(i,j) in E} (j,i);


param c{(i,j) in E}, >= 0;
/* cij  the cost of arc (i,j) */

var f{(i,j) in A, k in V diff {1}} >=0;
/* flow variables */

var y{(i,j) in A} >=0;
/* yij=1  or yji=1 if  edge {i,j} belongs to the spanning tree */

minimize Cost: sum{(i,j) in E} c[i,j]*(y[i,j]+y[j,i]);





s.t. source{k in V diff {1}}:
     sum{(j,1) in A} f[j,1,k]-sum{(1,j) in A} f[1,j,k]= -1;

s.t. balance1{k in V diff {1},i in V diff {1} : k <> i}:
     sum{(j,i) in A} f[j,i,k]-sum{(i,j) in A} f[i,j,k]= 0;

s.t. sinks{k in V diff {1}}:
     sum{(j,k) in A} f[j,k,k]-sum{(k,j) in A} f[k,j,k]= 1;

s.t. capacity{k in V diff {1}, (i,j) in A}:
     f[i,j,k] <= y[i,j];

s.t. tree: sum{(i,j) in A} y[i,j]=n-1; 



solve;


/* output results on the screen */

display 'a spanning tree';
display {(i,j) in A: y[i,j]!=0 }: y[i,j];

display 'the cost of the tree=',  sum{(i,j) in E} c[i,j]*(y[i,j]+y[j,i]);




data;


/* the optimal value 24 */

param n := 6;

param : E :   c :=
       1 2   2
       1 3   6
       2 4   4
       2 5   7
       3 4   2
       4 6   10
       5 6   9;
      

end;
