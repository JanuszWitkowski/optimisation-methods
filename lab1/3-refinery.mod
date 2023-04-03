/* OPTIMIZATION METHODS
ex 1.3 - Refinery
Author: Janusz Witkowski 254663
*/

set Ropy;               # Types of oils
set Paliwa;             # Results that the refinery produces
set Produkty;           # Products that are created during processes
set ProduktyKrakowane;  # Products that are created during destilate process
set Krakowalne;         # True/False
set Procesy;            # Operations that can be performed

param wydajnosc_destylacji{Produkty, Ropy}, >= 0, <= 1;     # Efficiency for destilation in [0,1]
param wydajnosc_krakowania{ProduktyKrakowane}, >= 0, <= 1;  # Efficiency for cracking in [0,1]
param koszty_ropy_na_tone{Ropy}, >= 0;                      # Costs of each oil in $/t
param koszty_procesow{Procesy}, >= 0;                       # Costs of possible processes in $/t
param wymagana_produkcja{Paliwa}, >= 0;                     # Demand for each fuel in t
param zawartosc_siarki{Procesy, Ropy}, >= 0, <= 1;          # Sulfur contamination of produced oil
param maksymalne_stezenie_siarki, >= 0, <= 1;               # Limit for sulfur in HouseFuels

var kupno_ropy{Ropy}, >= 0;                     # We need to buy this much oil of each type
var rozdzial_destylatu{Ropy, Krakowalne}, >= 0; # We need to split destilate between crakced and uncracked
var rozdzial_oleju{Ropy, Paliwa}, >= 0;         # We need to split produced oil between HouseFuels and HeavyFuels


# We want to minimize all costs
minimize calkowity_koszt: sum{ropa in Ropy}(
    (koszty_ropy_na_tone[ropa] + koszty_procesow['Destylacja']) * kupno_ropy[ropa] + 
    rozdzial_destylatu[ropa, 'Tak'] * koszty_procesow['Krakowanie']
);

# Constraints - We need to satisfy demand for each fuel type
s.t. wyprodukuj_co_najmniej_tyle_benzyny: 
    sum{ropa in Ropy}(
        wydajnosc_destylacji['Benzyna', ropa] * kupno_ropy[ropa] +
        wydajnosc_krakowania['Benzyna'] * rozdzial_destylatu[ropa, 'Tak'] 
    ) >= wymagana_produkcja['Silnikowe'];
s.t. wyprodukuj_co_najmniej_tyle_domowych:
    sum{ropa in Ropy}(
        rozdzial_oleju[ropa, 'Domowe'] +
        wydajnosc_krakowania['Olej'] * rozdzial_destylatu[ropa, 'Tak'] 
    ) >= wymagana_produkcja['Domowe'];
s.t. wyprodukuj_co_najmniej_tyle_ciezkich:
    sum{ropa in Ropy}(
        wydajnosc_destylacji['Resztki', ropa] * kupno_ropy[ropa] +
        rozdzial_destylatu[ropa, 'Nie'] + 
        rozdzial_oleju[ropa, 'Ciezkie'] +
        wydajnosc_krakowania['Resztki'] * rozdzial_destylatu[ropa, 'Tak']
    ) >= wymagana_produkcja['Ciezkie'];

# Constraints - Produced destilate must me properly distributed between crakced and uncracked. Same goes for produces oil, HouseFuels and HeavyFuels. 
s.t. dobry_podzial_destylatu{ropa in Ropy}: 
    sum{cracked in Krakowalne}(
        rozdzial_destylatu[ropa, cracked]
    ) = kupno_ropy[ropa] * wydajnosc_destylacji['Destylat', ropa];
s.t. dobry_podzial_oleju{ropa in Ropy}:
    sum{dest in Paliwa}(
        rozdzial_oleju[ropa, dest]
    ) = kupno_ropy[ropa] * wydajnosc_destylacji['Olej', ropa];     

# Constraint - We do NOT like sulfur in our HouseFuels above 0.5%
s.t. ograniczenie_na_siarke:
    sum{ropa in Ropy}(
        rozdzial_oleju[ropa, 'Domowe'] * zawartosc_siarki['Destylacja', ropa] +
        rozdzial_destylatu[ropa, 'Tak'] * wydajnosc_krakowania['Olej'] * zawartosc_siarki['Krakowanie', ropa]
    ) <= wymagana_produkcja['Domowe'] * maksymalne_stezenie_siarki;

solve;


printf "\n";
printf "KOSZT: %f\n", calkowity_koszt;
printf "\n";

printf "KUPIONA ROPA\n";
for{ropa in Ropy} {
    printf ("%s: %f\n"), ropa, kupno_ropy[ropa];
}
printf "\n";

printf "WYPRODUKOWANE\n";
printf "Ropa\t| Benzyna\t| Olej\t\t| Destylat\t| Resztki\n";
for{ropa in Ropy} {
    printf ("%s\t| %f\t| %f\t| %f\t| %f\n"), ropa, kupno_ropy[ropa] *  wydajnosc_destylacji['Benzyna', ropa], kupno_ropy[ropa] *  wydajnosc_destylacji['Olej', ropa],  kupno_ropy[ropa] *  wydajnosc_destylacji['Destylat', ropa],  kupno_ropy[ropa] *  wydajnosc_destylacji['Resztki', ropa];
}
printf "\n";

printf "ROZDZIAL DESTYLATU\n";
printf "Ropa\t| Destylacja\t| Krakowany\t| Czysty\n";
for{ropa in Ropy} {
    printf ("%s\t| %f\t| %f\t| %f\n"), ropa, rozdzial_destylatu[ropa, 'Tak'] + rozdzial_destylatu[ropa, 'Nie'], rozdzial_destylatu[ropa, 'Tak'], rozdzial_destylatu[ropa, 'Nie'];
}
printf "\n";

printf "ROZDZIAL OLEJU\n";
printf "Ropa\t| Destylacja\t| Ciezkie\t| Domowe\n";
for{ropa in Ropy} {
    printf ("%s\t| %f\t| %f\t| %f\n"), ropa, rozdzial_oleju[ropa, 'Ciezkie'] + rozdzial_oleju[ropa, 'Domowe'], rozdzial_oleju[ropa, 'Ciezkie'], rozdzial_oleju[ropa, 'Domowe'];
}
printf "\n";


data;

set Ropy := 'B1', 'B2';
set Paliwa := 'Silnikowe', 'Domowe', 'Ciezkie';
set Produkty := 'Benzyna', 'Olej', 'Destylat', 'Resztki';
set ProduktyKrakowane := 'Benzyna', 'Olej', 'Resztki';
set Krakowalne := 'Tak', 'Nie';
set Procesy := 'Destylacja', 'Krakowanie';

param wydajnosc_destylacji: B1 B2 :=
    Benzyna 0.15 0.1
    Olej 0.4 0.35
    Destylat 0.15 0.2
    Resztki 0.15 0.25;

param wydajnosc_krakowania :=
    Benzyna 0.5 
    Olej 0.2
    Resztki 0.06;

param koszty_ropy_na_tone :=
    B1 1300
    B2 1500;

param koszty_procesow :=
    Destylacja 10
    Krakowanie 20;

param wymagana_produkcja := 
    Silnikowe 200000
    Domowe 400000
    Ciezkie 250000;

param zawartosc_siarki: B1 B2 :=
    Destylacja 0.002 0.012
    Krakowanie 0.003 0.025;

param maksymalne_stezenie_siarki := 0.005;


end;