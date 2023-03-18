#####################################################			
# Pawel Zielinski
#####################################################	
using LinearAlgebra

using JuMP
#using CPLEX 
using GLPK
#using Clp

function LP(A::Matrix{Float64},
						b::Vector{Float64},
						c::Vector{Float64};
						verbose = true
						)
(m,n)=size(A)
# m - liczba ograniczen
# n - liczba zmiennych
# A - macierz ograniczen
# b - wektor prawych stron
# c - wektor wspolczynnikow funkcji celu						
# verbose - true, to kominikaty solvera na konsole 						
										
    #model = Model(CPLEX.Optimizer) # wybor solvera CPLEX		
	model = Model(GLPK.Optimizer) # wybor solvera GLPK
	#model = Model(Clp.Optimizer) # wybor solvera Clp dla liniowego programowania
					
	
	
	@variable(model, x[1:n]>=0) # zmienne decyzyjne
	
	@objective(model,Max, dot(c,x))  # funkcja celu 

    @constraint(model,A*x .<=b) # ogranizenia
	
	print(model) # drukuj skonkretyzowany model
	
	# rozwiaz model
	if verbose
		optimize!(model)		
	else
	  set_silent(model)
	  optimize!(model)
	  unset_silent(model)
 	end
	
	status=termination_status(model)
	
	if status== MOI.OPTIMAL
		 return status, objective_value(model), value.(x)
	else
		return status, nothing,nothing
	end
	
	
	
		
end #LP

 # Przyklad 1 z materialow do wykladu 
 # Przyklad ilustruje sytuacje, ze istnieje dokladnie jedno rozwiazanie 
 # Funkcja celu 
 # max: 4 x1 +5 x2;
 #
 # Ograniczenia 
 #   x1  + 2 x2 <= 40;
 # 4 x1  + 3 x2 <= 120;
 # x1 i x2 sa rzeczywiste nieujemne 
 


b = [ 40.0; 120.0]
A = [1.0 2.0;
     4.0 3.0]
c = [ 4.0; 5.0]

(status, fval, x)=LP(A,b,c)
if status== MOI.OPTIMAL
	 println("fval: ", fval)
   println("x: ", x)
else
   println("Status: ", status)
end



 # Przyklad 2 z materialow do wykladu 
 # Przyklad ilustruje sytuacje, ze istnieje nieskonczenie wiele rozwiazan 
 # Funkcja celu 
 # max: 4 x1 +3 x2;
 # Ograniczenia 
 #    x1  + 2 x2 <= 40;
 #  4 x1  + 3 x2 <= 120;
 #  x1 i x2 sa rzeczywiste nieujemne 

b = [ 40.0; 120.0]
A = [1.0 2.0;
     4.0 3.0]
c = [ 4.0; 3.0]

(status, fval, x)=LP(A,b,c)
if status== MOI.OPTIMAL
	 println("fval: ", fval)
   println("x: ", x)
else
   println("Status: ", status)
end


 # Przyklad ilustruje sytuacje, w ktorej funkja celu nie jest ograniczona z gory
 # Funkcja celu 
 # max:  x1 +0.3333 x2; 
 # Ograniczenia 
 # -2 x1  + 5 x2 <= 150;          -2 x1  + 5 x2     <= 150;
 # x1  +   x2 >= 20;               - x1    -   x2   <= -20;
 # x1         >= 5;                - x1             <=  -5;
 # domyslnie zmienne x1 i x2 sa rzeczywiste nieujemne
b = [ 150.0; -20.0; -5.0]
A = [-2.0 5.0;
     -1.0 -1.0; 
		 -1.0 0.0]
c = [ 1.0; 0.3333]

(status, fval, x)=LP(A,b,c)
if status== MOI.OPTIMAL
	 println("fval: ", fval)
   println("x: ", x)
else
   println("Status: ", status)
end

 # Przyklad ilustruje sytuacje, w ktorej nie ma rozwiazan dopuszczalnych
 # Funkcja celu 
 # min:  x1 +0.3333 x2; <-> max: -x1 - 0.3333 x2; 
 # Ograniczenia 
 # -2 x1  + 5 x2 <= 150;          -2 x1  + 5 x2     <= 150;
 # x1  +   x2 >= 20;               - x1    -   x2   <= -20;
 # x1         >= 5;                - x1             <=  -5;
 # x1  +   x2 <= 10;                 x1  +   x2     <= 10;
 # domyslnie zmienne x1 i x2 sa rzeczywiste nieujemne
b = [ 150.0; -20.0; -5.0; 10.0]
A = [-2.0 5.0;
     -1.0 -1.0;
		 -1.0  0.0;
		  1.0  1.0] 
c = [ -1.0; -0.3333]

(status, fval, x)=LP(A,b,c,verbose = false)
if status== MOI.OPTIMAL
	 println("fval: ", fval)
   println("x: ", x)
else
   println("Status: ", status)
end
   