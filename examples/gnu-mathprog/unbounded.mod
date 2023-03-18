/* A simple example of linear programming model*/
/* The set of feasible solutions is unbounded  */
/* There is no a finite optimal solution */

/* The declaration of decision variables x1, x2  */

var x1 >= 0;
var x2 >=0;


/* Objective function */
maximize  UnboundedObjectiveFunction : 4*x1 +2*x2;

/* Constraints */

subject to label1:   3*x1 + 6*x2 >= 18;
s.t.       label2:     x1 - 2*x2 <= 4; 


end;
