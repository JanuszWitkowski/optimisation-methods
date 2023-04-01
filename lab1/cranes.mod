set Cities;
set Cranes;

param distances{Cities, Cities}, >= 0;
param deficient{Cranes, Cities}, integer, >= 0;
param redundant{Cranes, Cities}, integer, >= 0;
param transport{Cranes}, >= 0;
param can_replace{Cranes, Cranes}, integer, >= 0, <= 1;

# solution of problem
var solution{Cities, Cities, Cranes}, integer, >= 0;

minimize cost_func: sum{crane in Cranes, from in Cities, to in Cities}(
    distances[from, to] * solution[from, to, crane] * transport[crane]
);

s.t. satisfy_deficiencies{to in Cities, needed in Cranes}: (sum{from in Cities, given in Cranes} (solution[from, to, given] * can_replace[given, needed])) >= deficient[needed, to];

s.t. take_no_more_than_excess{from in Cities, given in Cranes}: (sum{to in Cities} solution[from, to, given]) <= redundant[given, from];

solve;
printf "\n";

printf "TRANSPORT SCHEDULE\n";
for{from in Cities} {
    for{to in Cities} {
        for{crane in Cranes} {
            printf (if solution[from, to, crane] != 0 then "Move %d %s cranes from %s to %s\n" else ""), solution[from, to, crane], crane, from, to ;
        }
    }
}
printf "\n";

printf "DEFICIENT | REDUNDANT | STOCK STATUS | CITY\n";
for{city in Cities} {
    for{crane in Cranes} {
        printf "%d\t| %d\t| %s\t| %s\n", deficient[crane, city] - (sum{from in Cities} solution[from, city, crane]), redundant[crane, city] - (sum{to in Cities} solution[city, to, crane]), crane, city;
    }
}
printf "\n";

printf "TOTAL COST: %f\n", cost_func;
printf "\n";

end;

# glpsol --model cranes.mod --data cranes.dat --output out/cranes.txt | tee out/cranes.log
