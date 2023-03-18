/* A simple example of linear programming model*/
/* There exists a feasible solution for the model below */
/* x1=24, x2=8 */

/* The declaration of decision variables x1, x2  */

var x1 >= 0;
var x2 >=0;


/* Objective function */
maximize  label : 4*x1 +5*x2;

/* Constraints */

subject to label1:   x1 + 2*x2 <= 40;
s.t.       label2: 4*x1 + 3*x2 <= 120; /* instead of subject to, s.t. for short*/

end;
