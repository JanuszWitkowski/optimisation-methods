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

/* Arrays and sets */

/* enumerated set Cameras represents the set of cameras manufactured by the company */

set Cameras; 

/* array of three decision variables: production['cub'], production['quick'] and production['vip'] */

var production{Cameras} >=0;


/* objective function represents profit */

maximize profit: 3*production['cub'] + 9*production['quick'] + 25*production['vip'];

/* constraints determine composition manufacturing cameras */

s.t. time_manufacture: 0.1*production['cub'] + 0.2*production['quick']  +  0.7*production['vip'] <= 250;   
s.t. time_assemble:    0.2*production['cub'] + 0.35*production['quick'] +  0.1*production['vip'] <= 350;
s.t. time_inspect:     0.1*production['cub'] + 0.2*production['quick'] +   0.3*production['vip'] <= 150;
s.t. requirements_cub:     production['cub']                         >= 250;
s.t. requirements_quick:             production['quick']             >= 375;
s.t. requirements_vip:                            production['vip']  >= 150;

data;
/* Definition of the set Cameras */
set Cameras:= 'cub' 'quick' 'vip';

end;

