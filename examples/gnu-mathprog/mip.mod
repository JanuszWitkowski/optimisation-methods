/* A simple example of mixed integer programming model*/

/* The declaration of nonnegative real decision variables*/

var x1 >= 0;
var x4 >=0;


/* The declaration of nonnegative integer decision variables*/

var x2 integer >= 0;
var x3 integer >=0;


/* Objective function */
maximize  ObjectiveFunctionLabel : -3*x1 -2*x2+10;

/* Constraints */

s.t.       label1:     x1 - 2*x2 + x3      = 2.5;
s.t.       label2:   2*x1 + x2         +x4 >= 1.5; 


end;
