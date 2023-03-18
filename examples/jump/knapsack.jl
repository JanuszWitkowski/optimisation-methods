
#####################################################	
# The multidimensional zero-one knapsack problem
# can be described as follows: given two sets of n items and m
# knapsack constraints (or resources), for each item j a profit p_j 
# is assigned and for each constraint i a consumption value r_ij is designated. 
# The goal is to determine a set of items that maximizes the total profit, not exceeding 
# the given constraint capacities $c_i$.
#
# Written in julia by Pawel Zielinski
#####################################################	





using LinearAlgebra

using JuMP
#using CPLEX 
using GLPK
#using Cbc


function knapsack(consumption::Matrix{Int},
						      capacity::Vector{Int},
						      profit::Vector{Int};
							  verbose = true
					      	)
  (m,n)=size(consumption)
	
#  n - the number of items
#  m - the number of resources
#  consumption -  the matrix represents the consumption of resource  by item
#  capacity - the vector  represents the capacity of the resources	
#  profit -  the vector repressents   the value of each item
# verbose - true, non silent mode of a sover		
	
#model = Model(CPLEX.Optimizer) # CPLEX		
model = Model(GLPK.Optimizer) # GLPK
#model = Model(Cbc.Optimizer) # Cbc the solver for mixed integer programming
	

	
	maxprofit = maximum(capacity) # the reduction of solution space 
	
	
	
	@variable(model,maxprofit>=choose[1:n]>=0, Int) # integer decission variables
	
	@objective(model,Max, dot(profit,choose))  # the profit

  @constraint(model,consumption*choose .<=capacity) # resource constraints
	
	print(model) # print an instance of the model
	
	 # solve the instance
	if verbose
		optimize!(model)		
	else
	  set_silent(model)
	  optimize!(model)
	  unset_silent(model)
 	end
	
	status=termination_status(model)
	
	if status== MOI.OPTIMAL
		 return status, objective_value(model), value.(choose)
	else
		return status, nothing,nothing
	end
	
		
end #knapsack

profit=[ 95; 
         75; 
         55; 
         12; 
         86; 
         11; 
         66; 
         83; 
         83; 
         10; 
         9; 
         8;
         7]
consumption=[19 1 10 1 1 14 152 11 1 1 1 1  3;
      0 4 53 0 0 80 0 4 5 0 0 0 4; 
      4 660 3 0 30 0 3 0 4 90 0 0  6; 
      7 0 18 6 770 330 7 0 0 6 0 0  8; 
      1 20 0 0 52 3 0 0 0 5 4 0 3;
      0 0 40 70 4 63 0 0 60 0 4 0  3;
      0 33 0 0 0 5 0 3 0 661 0 10 1]

capacity=[ 182; 
          73; 
          788; 
          924; 
          266; 
          78; 
          809]    

(status, prof, choose)=knapsack(consumption,capacity,profit)

if status== MOI.OPTIMAL
	 println("Profit: ", prof)
   println("choose: ", choose)
else
   println("Status: ", status)
end
