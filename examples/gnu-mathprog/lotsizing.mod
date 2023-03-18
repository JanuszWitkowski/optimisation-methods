/*
We are given T periods. For period t, t=1,..., T let d_t be the demand 
in period t, d_t >= 0.
We wish to meet prescribed demand d_t for each of T periods t=1,..., T
by either producing an amount x_t up to u_t ( the production capacity limit on x_t) 
in period t  and/or by
drawing upon the inventory I_{t-1} carried from the previous period.
Furthermore, we might not fully
satisfy the demand of any period from the production in that period or from current
inventory, but could fulfill the demand from production in future periods -
we permit backordering.
The costs of carrying one unit of inventory from period t to period t+1
 is given by c^I_t >= 0 and the costs of backordering one unit from 
period t+1 to period t is given by 
c^B_t >= 0.The unit production cost in period t is c_t. We assume that
the total production capacity is at least
as large as the total demand.
So, we wish to find a production plan x_t, t=1,...,T,
that minimizes the total cost of production, storage and backordering subject 
to the conditions of satisfying each demand.

Written in GNU MathProg by Pawel Zielinski
*/

/* input data */
param T, integer,>=1; # number of periods 

set Periods:={1..T};  # set of Periods 

param cI{Periods}, >=0; #  costs of carrying one unit of inventory 

param cB{Periods}, >=0; # costs of backordering one unit 

param c{Periods}, >=0; # unit production costs

param u{Periods}>=0; #  the production capacity limits

param d{Periods}>=0; # demands  

/* Checking  the total production capacity is at least
   as large as the total demand*/ 
check sum{t in Periods} d[t]<= sum{t in Periods} u[t];

/* decision variables */
var x{t in Periods}>=0,<=u[t]; # production plan

var I{Periods}>=0; #inventory amount 

var B{Periods}>=0; # backordering amount

minimize TotalCost: sum{t in Periods} (c[t]*x[t]+cI[t]*I[t]+cB[t]*B[t]);

s.t. balance{t in Periods}: B[t]-I[t]=sum{j in Periods : j<=t}(d[j]-x[j]);
solve;

/* Displaying results */
display 'production plan';
display {t in Periods}: x[t];
display 'total cost=',  sum{t in Periods} (c[t]*x[t]+cI[t]*I[t]+cB[t]*B[t]);
display {t in Periods}: I[t];
display {t in Periods}: B[t];


/*data in a separated file */


end;




