#####################################################			
# Pawel Zielinski
#####################################################	

# The shortest path problem in a directed graph G=<V,A>


using JuMP
#using CPLEX 
using GLPK
#using Clp


struct  Arc
	i::Int       # arc (i,j)
	j::Int
	c::Float64   # cij  the cost of arc (i,j) 
end




#Data
verbose=true
n=4
s=1 # the source
t=n # the sink
A = [Arc(1,2,1.0), Arc(1,3,4.0), Arc(2,3,2.0), Arc(2,4,8.0), Arc(3,4,5.0)] # The network





# Building model for the shortest path problem

# choosing LP solver
#model = Model(CPLEX.Optimizer) # CPLEX		
model = Model(GLPK.Optimizer) # GLPK
#model = Model(Clp.Optimizer) # Clp 

@variable(model, x[A]>=0) # x[i,j] =1 if  arc belongs to the shortest path, 0 otherwise
@objective(model,Min, sum(a.c * x[a] for a in A)) # the objective function

V=1:n # the set of nodes

@constraint(model, sum(x[a] for a in A if a.j==t) == 1)
@constraint(model, sum(x[a] for a in A if a.i==s) == 1)
for k=filter(v->v!=s && v!=t,V)
  @constraint(model, sum(x[a] for a in A if a.j==k) == sum(x[a] for a in A if a.i==k))
end


print(model) # print the instance of problem


if verbose
	optimize!(model)		
else
  set_silent(model)
  optimize!(model)
  unset_silent(model)
end

status=termination_status(model)





if status== MOI.OPTIMAL
	 println("the total cost: ", objective_value(model))
	 x=value.(x)
	 for a in A
		 println("(",a.i,",",a.j,"): ",x[a]) # a shortest path
	 end
else
   println("Status: ", status)
end





