/*  The flow shop problem

Given m different items that are to be routed through n machines.
Each item must be processed first on machine 1, then on 
machine 2, and finally on machine n. 
The sequence of items may differ for each machine.
Assume that the times dij required to perform the work on item i
by machine j are known.
Our objective is to minimize the total time necessary to process 
all the items called makespan.


Written in GNU MathProg by Pawel Zielinski
 */


param n, integer, >=1;
/* the number of machine */


param m, integer, >=1;
/* the number of items */
 
set Machines:={1..n};
/* the set of machines */

set Items:={1..m};
/* set of items */

param d{i in Items, j in Machines} >=0;
/* dij required to perform the work on item i by machine j  */

param B:=1+sum{i in Items, j in Machines} d[i,j];
/*Big number */

var t{i in Items, j in Machines} >=0;
/* variable represents starting time of processing item i on machine j */

var ms>=0;
/* makespan */

var y{j in Machines, i in Items, k in Items: i<k}, binary;
/* variables needed to model disjunctive  constraints*/

minimize makespan: ms;
/* the minimization  of makespan*/

s.t. precedence{i in Items, j in Machines:j<n}: t[i,j+1]>=t[i,j]+d[i,j];
/* starting time of processing item i on machine j+1 must be
	>= than starting time of processing item i on machine j */ 


s.t. resources1{j in Machines, i in Items, k in Items: i<k}:
     t[i,j]-t[k,j]+B*y[j,i,k]>=d[k,j];
s.t. resources2{j in Machines, i in Items, k in Items: i<k}:
     t[k,j]-t[i,j]+B*(1-y[j,i,k])>=d[i,j];

/* t_ij>=t_kj+d_kj or t_kj>=t_ij+d_ij 
   resource constraints,i.e.  at the moment only one item
   can be processed on machine j */

s.t. makespan1{i in Items}:
     t[i,n]+d[i,n]<=ms;

/*ms equals completion time of processing all items on the last machine */

data;

param n:=3; # the number of machine

param m:=7; # the number of items

/* the times dij required to perform the work on item i by machine j */
param d:     1       2       3:=
       1     3       3       2
       2     9       3       8
       3     9       8       5
       4     4       8       4
       5     6      10       3
       6     6       3       1
       7    7      10       3;       
end;