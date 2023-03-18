/*  
(S.P. Bradley, A.C. Hax, T.L. Magnanti, Applied Mathematical Programming,
Addison-Wesley Publishing Company, 1977)

The Candid Camera Company manufactures three lines of cameras: 
the Cub, the Quickiematic and the VIP, whose
contributions are $3, $9, and $25, respectively. 
The distribution center requires that at least 250 Cubs, 375 Quickiematics,
and 150 VIPs be produced each week. Each camera requires a certain amount 
of time in order to: (1) manufacture the body parts; (2) assemble the
parts (lenses are purchased from outside sources and can be ignored in the production 
scheduling decision); and (3)    inspect, test, and package the final product. 
The Cub takes 0.1 hours to manufacture, 0.2 hours to assemble, and 0.1
hours to inspect, test, and package. The Quickiematic needs 0.2 hours to manufacture,
0.35 hours to assemble, and 0.2 hours for the final set of operations. 
The VIP requires 0.7, 0.1, and 0.3 hours, respectively. In addition, there
are 250 hours per week of manufacturing time available, 350 hours of 
assembly, and 150 hours total to inspect, test,and package.
The Candid Camera Company would like a production plan maximazing its profits.

Written in GNU MathProg by Pawel Zielinski

*/


/* The model for one instance for the above problem */

/* Isolating the data from the model */

/* Enumerated sets*/

set Cameras; 
set Times;

/* Parameters */

param profit{Cameras} >=0;             # one dimensional array of profit
param consumption{Times,Cameras} >=0;  # two dimensional array
param capacity{Times} >=0;             # one dimensional array of amount of times
param demand{Cameras} >=0;             # one dimensional array of the distribution center requirements 

/* Variables */ 

var production{j in Cameras} >=demand[j]; # the array of decision variables plus trivial bounds

/* objective function represents profit */

maximize Profit: sum{j in Cameras} profit[j]*production[j];


/* constraints determine composition manufacturing cameras */

s.t. time_constraints{i in Times}: sum{j in Cameras} consumption[i,j]*production[j] <=capacity[i]; 

/* Data section */
data;

/* Definitions of the sets */
set Cameras:= cub quick vip;
set Times:= manufacture assemble inspect;

/* The initialization of the parameters */

param profit:= cub   3
               quick 9
               vip   25;

param capacity:= manufacture 250
                 assemble    350
                 inspect     150;

param demand:=cub   250
		      quick 375
			  vip   150;
			
param consumption: 	cub 	quick vip:=
		manufacture	0.1     0.2   0.7   
		assemble	0.2     0.35  0.1
		inspect	    0.1     0.2   0.3;




end;

