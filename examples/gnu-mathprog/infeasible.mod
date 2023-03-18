/* A simple example of linear programming model*/
/* The set of feasible solutions is empty  */
/* There is no a feasible solution */

/* The declaration of decision variables x1, x2  */

var x1 >= 0;
var x2 >=0;


/* Objective function */
maximize  ObjectiveFunctionLabel : 4*x1 +2*x2;

/* Constraints */

subject to label1:     x1 + x2       = 2;
s.t.       label2:     x1 + x2       >= 4; 


end;
