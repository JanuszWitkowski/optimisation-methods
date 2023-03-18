#####################################################			
# Pawel Zielinski
#####################################################	

# The spanning tree problem G=<E,V> 

using JuMP
#using CPLEX 
using GLPK
#using Clp


struct  Edge
	i::Int       # edge {i,j}
	j::Int
	c::Float64   # cij  the cost of edge {i,j}
end



#Data
verbose=true
n=6
E = [Edge(1,2,2.0), Edge(1,3,6.0), Edge(2,4,4.0), Edge(2,5,7.0), 
     Edge(3,4,2.0), Edge(4,6,10.0), Edge(5,6,9.0)] # The graph
##################		 


# Building model for the spanning tree.
# choosing LP solver
#model = Model(CPLEX.Optimizer) # CPLEX		
model = Model(GLPK.Optimizer) # GLPK
#model = Model(Clp.Optimizer) # Clp 



A=union([(e.i, e.j) for e in E],[(e.j, e.i) for e in E])
V=1:n
Vminus1=setdiff(V, [1])


@variable(model, x[E]>=0) #x_e=1   if  edge e belongs to the spanning tree; 0 otherwise 
@variable(model, y[A]>=0) 
@variable(model, f[A, Vminus1]>=0)     #flow variables

@objective(model,Min, sum(e.c * (y[(e.i, e.j)]+y[(e.j, e.i)]) for e in E)) # the objective function

for k in Vminus1 # sources
  @constraint(model, sum(f[(j,1),k] for j = filter(j -> (j,1) in A, V)) 
	- sum(f[(1,j),k] for j = filter(j -> (1,j) in A, V))==-1)
end

for k in Vminus1, i in Vminus1 # balances
  if i!=k 
		@constraint(model, sum(f[(j,i),k] for  j=filter(j -> (j,i) in A, V)) 
		- sum(f[(i,j),k] for  j=filter(j -> (i,j) in A, V))==0)
	end
end


for k in Vminus1 # sinks
  @constraint(model, sum(f[(j,k),k] for j=filter(j -> (j,k) in A, V)) 
	- sum(f[(k,j),k] for j= filter(j -> (k,j) in A, V))==1)
end






for k in Vminus1, a in A #capacity
	@constraint(model, f[a,k] <= y[a])
end

@constraint(model, sum(y[a] for a in A)==n-1) #tree


for e in E
	@constraint(model, x[e]==y[(e.i, e.j)]+y[(e.j, e.i)])
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
	 for e in E
		 println("(",e.i,",",e.j,"): ",x[e]) # a spanning tree
	 end
else
   println("Status: ", status)
end




