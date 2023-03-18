/* The min cost flow problem 
Consider the problem of shipment of
a commodity through a network in order to
satisfy demands  at certain nodes V_3
from available supplies  
at other nodes V_1.
For each i in V_1 supply a_i is given,
for each i in V_3 demand b_i is given.
Each arc (i,j) has an associated cost c_{ij}
that denotes the cost per unit flow on that arc.
A capacity u_{ij} is also associated with 
each arc (i,j)
that denotes the maximum amount that can flow
on the arc.
The problem consists in finding a least cost flow.

Written in GNU MathProg by Pawel Zielinski

*/

param n, integer, >= 2; #the number of nodes 

set V:={1..n}; # the set of nodes 
set V1 within V; # sources - supply nodes
set V3 within V; # sinks - demand nodes
check: (V1 inter V3) within {}; # check if V1 and V3 are disjoint sets

set V2:=V diff V1 diff V3; # transshipment nodes

set A  within V cross V; # the set of arcs 

set S{i in V}:={j in V: (i,j) in A}; # the set of direct successors of i
set P{i in V}:={j in V: (j,i) in A}; # the set of direct predecessors of i


param a{V1}>=0; # the supplies 
param b{V3}>=0; # the demands 

check sum{i in V1} a[i] = sum{i in V3} b[i]; # check if the problem is balanced

param c{A}>= 0; # the arc costs 
param u{A}>= 0; # the capacities of arcs

var x{(i,j) in A}>= 0, <= u[i,j]; # the flow on arc (i,j)

minimize Cost: sum{(i,j) in A} c[i,j]*x[i,j];


s.t. supplies{i in V1}:sum{j in S[i]} x[i,j]-sum{j in P[i]}x[j,i]=a[i];
s.t. trans{i in V2}:   sum{j in S[i]} x[i,j]-sum{j in P[i]}x[j,i]=0;
s.t. demands{i in V3}: sum{j in S[i]} x[i,j]-sum{j in P[i]}x[j,i]=-b[i];

solve;

display 'flow';
display{ (i,j) in A}:i,j,'=',x[i,j];

data;

/* Wheastone bridge */


param n := 4;

set V1:=1;
set V3:=4;

param a:=[1] 1;
param b:=[4] 1; 

param : A :  c  u :=
       1 2   1  1
       1 3   4  1
       2 3   2  1
       2 4   8  1
       3 4   5  1;
end;
