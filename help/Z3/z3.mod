/* Params */

set Operations;
set Oils;
set Fuels;
set Products;
set CrackingProducts;
set IsCracked;
set Processes;

param DestilationEfficiency{Products, Oils}, >= 0, <= 1;
param CrackingEfficency{CrackingProducts}, >= 0, <= 1;
param OilsCosts{Oils}, >= 0;
param ProcessesCosts{Processes}, >= 0;
param Demands{Fuels}, >= 0;
param SulfurContamination{Processes, Oils}, >= 0;

var oilBought{Oils}, >= 0;
var destilateDistribution{Oils, IsCracked}, >= 0;
var producedOilDistribution{Oils, Fuels}, >= 0;

minimize cost: sum{oil in Oils}(
    OilsCosts[oil] * oilBought[oil] * ProcessesCosts['Destilation'] + 
    destilateDistribution[oil, 'Yes'] * ProcessesCosts['Cracking']
);

s.t. satisfy_petrol: 
    sum{oil in Oils}(
        DestilationEfficiency['Benzyna', oil] * oilBought[oil] +
        CrackingEfficency['Benzyna'] * destilateDistribution[oil, 'Yes'] 
) = Demands['Silnikowe'];

s.t. satisfy_house:
    sum{oil in Oils}(
        producedOilDistribution[oil, 'Domowe'] +
        CrackingEfficency['Olej'] * destilateDistribution[oil, 'Yes'] 
) = Demands['Domowe'];

s.t. satisfy_heavy:
    sum{oil in Oils}(
        DestilationEfficiency['Resztki', oil] +
        destilateDistribution[oil, 'No'] + 
        producedOilDistribution[oil, 'Ciezkie'] +
        CrackingEfficency['Resztki'] * destilateDistribution[oil, 'Yes']
) = Demands['Ciezkie'];

s.t. cracking_equality{oil in Oils}: 
    sum{cracked in IsCracked}(
        destilateDistribution[oil, cracked]
) = oilBought[oil] * DestilationEfficiency['Destylat', oil];

s.t. oil_equality{oil in Oils}:
    sum{dest in Fuels}(
        producedOilDistribution[oil, dest]
) = oilBought[oil] * DestilationEfficiency['Olej', oil];     

s.t. sulfur_contamination:
    sum{oil in Oils}(
        producedOilDistribution[oil, 'Domowe'] * SulfurContamination['Destilation', oil] +
        destilateDistribution[oil, 'Yes'] * CrackingEfficency['Olej'] * SulfurContamination['Cracking', oil]
) <= Demands['Domowe'] * 0.005;

solve;

display cost;
printf "\n";

printf "Oil Bought\n";
for{oil in Oils} {
    printf ("Bought %d of %s\n"), oilBought[oil], oil;
}

printf "\n";

printf "Produced Pure Materials\n";
printf "OIL | PETROL | OIL | DESTILATE | MISC\n";
for{oil in Oils} {
    printf ("%s\t| %d\t| %d\t| %d\t| %d\n"), oil, oilBought[oil] *  DestilationEfficiency['Benzyna', oil], oilBought[oil] *  DestilationEfficiency['Olej', oil],  oilBought[oil] *  DestilationEfficiency['Destylat', oil],  oilBought[oil] *  DestilationEfficiency['Resztki', oil];
}

printf "\n";

printf "Destilate Distribution\n";
printf "OIL | PRODUCED | CRACKED | PURE\n";
for{oil in Oils} {
    printf ("%s\t| %d\t| %d\t| %d\n"), oil, destilateDistribution[oil, 'Yes'] + destilateDistribution[oil, 'No'], destilateDistribution[oil, 'Yes'], destilateDistribution[oil, 'No'];
}

printf "\n";

printf "Oil Distribution\n";
printf "OIL\t| PRODUCED\t| HEAVY\t| HOUSE\n";
for{oil in Oils} {
    printf ("%s\t| %d\t| %d\t| %d\n"), oil, producedOilDistribution[oil, 'Ciezkie'] + producedOilDistribution[oil, 'Domowe'], producedOilDistribution[oil, 'Ciezkie'], producedOilDistribution[oil, 'Domowe'];
}

end;
