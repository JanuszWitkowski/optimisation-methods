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

If initial inventory  is positive I_0, then one can append period 0 and assign x_0 = I_0 and d_0 = 0 
with zero inventory cost.

Written in GNU MathProg by Pawel Zielinski
*/

/* input data */
param InitInvent>=0, default 0;

param T, integer,>=1; # number of periods 

set Periods:=if InitInvent =0 then {1..T} else {0} union {1..T};


param cI{t in Periods}>=0; #  costs of carrying one unit of inventory 
param cB{Periods}>=0; # costs of backordering one unit 
param c{Periods}>=0; # unit production costs
param u{Periods}>=0; #  the production capacity limits
param d{Periods}>=0; # demands  


param c0I{t in Periods}:=if t=0 then 0 else cI[t];
param c0B{t in Periods}:=if t=0 then 0 else cB[t];
param c0{t in Periods}:=if t=0 then 0 else c[t];
param u0{t in Periods}:=if t=0 then InitInvent else u[t];
param d0{t in Periods}:=if t=0 then 0 else d[t];

/* Checking  the total production capacity is at least
   as large as the total demand*/ 
check sum{t in Periods: t>0} d[t]<= sum{t in Periods : t>0} u[t];

/* decision variables */
var x{t in Periods} >=(if t=0 then InitInvent else 0), <=u0[t]; # production plan

var I{Periods}>=0; #inventory amount 

var B{Periods}>=0; # backordering amount

minimize TotalCost: sum{t in Periods} (c0[t]*x[t]+c0I[t]*I[t]+c0B[t]*B[t]);

s.t. balance{t in Periods}: B[t]-I[t]=sum{j in Periods : j<=t}(d0[j]-x[j]);
solve;

/* Displaying results */
display 'production plan';
display {t in Periods : t>0}: x[t];
display 'total cost=',  sum{t in Periods} (c0[t]*x[t]+c0I[t]*I[t]+c0B[t]*B[t]);
display {t in Periods : t>0}: I[t];
display {t in Periods : t>0}: B[t];


/*data section */
data;

param InitInvent:=10;
param T:=5;
param cI:= [1] 2 [2] 3 [3] 3 [4] 1 [5] 3;
param cB:= [1] 5 [2] 5 [3] 6 [4] 6 [5] 6;
param c:= [1] 5 [2] 5 [3] 4 [4] 4 [5] 5;
param d:= [1] 10 [2] 20 [3] 30 [4] 60 [5] 50;
param u:= [1] 5 [2] 10 [3] 40 [4] 100 [5] 20;


end;




