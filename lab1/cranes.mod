/* OPTIMIZATION METHODS
ex 1.2 - Cranes Transportation Flow
Author: Janusz Witkowski 254663
*/

set Cities;     # Enum for cities
set Cranes;     # Enum for crane types

param distances{Cities, Cities}, >= 0;                  # How long does it take to commute from one city to another
param deficient{Cranes, Cities}, integer, >= 0;         # How much cranes of each type does every city need
param redundant{Cranes, Cities}, integer, >= 0;         # How much cranes of each type can every city give
param transport{Cranes}, >= 0;                          # Transport costs are proportional to distances
param can_replace{Cranes, Cranes}, integer, >= 0, <= 1; # can_replace[x, y] means "x can replace y"

# Solutions for this problem are commute schedules for cranes between cities
var commute{Cities, Cities, Cranes}, integer, >= 0;

# Objective function is instructed to seek solution with the lowest total cost possible
minimize transportation_costs: sum{crane in Cranes, from in Cities, to in Cities}(
    distances[from, to] * commute[from, to, crane] * transport[crane]
);

# Constraint - Satise needs for cranes for every city
s.t. satisfy_deficiencies{to in Cities, needed in Cranes}: sum{from in Cities, given in Cranes}(commute[from, to, given] * can_replace[given, needed]) >= deficient[needed, to];

# Constraint - You can't give away a crane if you don't have one
s.t. take_no_more_than_excess{from in Cities, given in Cranes}: sum{to in Cities}(commute[from, to, given]) <= redundant[given, from];

# Constraint - No crane should be lost in the final solution
s.t. upper_bound_for_imported_cranes{to in Cities}: sum{from in Cities, crane in Cranes}(commute[from, to, crane]) >= sum{crane in Cranes}(deficient[crane, to]);

solve;
printf "\n";

printf "TRANSPORT SCHEDULE\n";
for{from in Cities} {
    for{to in Cities} {
        for{crane in Cranes} {
            printf (if commute[from, to, crane] != 0 then "Move %d %s cranes from %s to %s\n" else ""), commute[from, to, crane], crane, from, to ;
        }
    }
}
printf "\n";

printf "DEFICIENT | REDUNDANT | STOCK STATUS | CITY\n";
for{city in Cities} {
    for{crane in Cranes} {
        printf "%d\t| %d\t| %s\t| %s\n", deficient[crane, city] - (sum{from in Cities} commute[from, city, crane]), redundant[crane, city] - (sum{to in Cities} commute[city, to, crane]), crane, city;
    }
}
printf "\n";

printf "TOTAL COST: %f\n", transportation_costs;
printf "\n";

end;

# glpsol --model cranes.mod --data cranes.dat --output out/cranes.txt | tee out/cranes.log
