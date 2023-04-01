set Ropy;
set Produkty;
set Paliwa;

param koszt_ropy_za_tone{Ropy}, >= 0;
param koszt_destylacji_za_tone, >= 0;
param koszt_krakowania_za_tone, >= 0;
param wydajnosc_destylacji{Ropy, Produkty}, >= 0.0, <= 1.0;
param wydajnosc_krakowania{Produkty}, >= 0.0, <= 1.0;
param krakowany_produkt symbolic in Produkty;
param sklad_paliw{Paliwa, Produkty}, integer, >= 0, <= 1;
param wymagana_produkcja{Paliwa}, >= 0;
param dozwolona_siarka{Paliwa}, >= 0.0, <= 1.0;
param zawartosc_siarki{Ropy, Produkty}, >= 0.0, <= 1.0;

# Zmienne do rozwiazania
var kupione_tony_ropy{Ropy}, >= 0.0;
# var do_krakowania{Ropy}, >= 0.0, <= 1.0;
var tony_ropy_do_krakowania{Ropy}, >= 0.0;
var produkty_na_paliwa{Produkty, Paliwa}, >= 0.0, <= 1.0;

# Zmienne pomocnicze
var produkcja_paliw{Paliwa}, >= 0.0;
var siarka_w_paliwach{Paliwa}, >= 0.0;


minimize laczne_koszta: sum{ropa in Ropy}(
    kupione_tony_ropy[ropa] * (
        koszt_ropy_za_tone[ropa] + koszt_destylacji_za_tone
        # + (wydajnosc_destylacji[ropa, krakowany_produkt] * do_krakowania[ropa] * koszt_krakowania_za_tone)
    ) + tony_ropy_do_krakowania[ropa] * wydajnosc_destylacji[ropa, krakowany_produkt] * koszt_krakowania_za_tone
);

s.t. def_produkcja_paliw{paliwo in Paliwa}:
    produkcja_paliw[paliwo] = sum{ropa in Ropy, produkt in Produkty}(
        sklad_paliw[paliwo, produkt] * (
            (if produkt != krakowany_produkt then kupione_tony_ropy[ropa] else (kupione_tony_ropy[ropa] - tony_ropy_do_krakowania[ropa])) *
            wydajnosc_destylacji[ropa, produkt] +
            tony_ropy_do_krakowania[ropa] * wydajnosc_destylacji[ropa, krakowany_produkt] * wydajnosc_krakowania[produkt]
        )
    );

s.t. def_siarka_w_paliwach{paliwo in Paliwa}:
    siarka_w_paliwach[paliwo] = sum{ropa in Ropy, produkt in Produkty}(
        zawartosc_siarki[ropa, produkt] * sklad_paliw[paliwo, produkt] * (
            (if produkt != krakowany_produkt then kupione_tony_ropy[ropa] else (kupione_tony_ropy[ropa] - tony_ropy_do_krakowania[ropa])) *
            wydajnosc_destylacji[ropa, produkt] +
            tony_ropy_do_krakowania[ropa] * wydajnosc_destylacji[ropa, krakowany_produkt] * wydajnosc_krakowania[produkt]
        )
    );

s.t. odpowiedni_podzial{produkt in Produkty}:
    sum{paliwo in Paliwa}(produkty_na_paliwa[produkt, paliwo]) <= 1.0;

s.t. odpowiedni_przedzial_ropy_do_krakowania{ropa in Ropy}:
    tony_ropy_do_krakowania[ropa] <= kupione_tony_ropy[ropa];

s.t. wyprodukuj_co_najmniej{paliwo in Paliwa}: 
    produkcja_paliw[paliwo] >= wymagana_produkcja[paliwo];

s.t. uwazaj_na_siarke{paliwo in Paliwa}:
    siarka_w_paliwach[paliwo] <= dozwolona_siarka[paliwo] * produkcja_paliw[paliwo];

solve;


printf "\nOPTYMALNY KOSZT: %f\n", laczne_koszta;
printf "\n";

printf "ZAKUP ROPY\n";
for{ropa in Ropy} {
    printf "%s %f\n", ropa, kupione_tony_ropy[ropa];
}
printf "\n";

printf "DO KRAKOWANIA\n";
for{ropa in Ropy} {
    printf "%s %f\n", ropa, tony_ropy_do_krakowania[ropa];
}
printf "\n";

printf "OSTATECZNA PRODUKCJA PALIW\n";
for{paliwo in Paliwa} {
    printf "%s %f\n", paliwo, produkcja_paliw[paliwo];
}
printf "\n";

printf "SIARKA W PALIWACH\n";
for{paliwo in Paliwa} {
    printf "%s %f (%f)\n", paliwo, siarka_w_paliwach[paliwo] / produkcja_paliw[paliwo], dozwolona_siarka[paliwo];
}
printf "\n";


data;

set Ropy := 'B1' 'B2';
set Produkty := 'Benzyna' 'Olej' 'Destylat' 'Resztki' 'BenzynaKrakowana' 'OlejKrakowany' 'ResztkiKrakowane';
set Paliwa := 'Silnikowe' 'Domowe' 'Ciezkie';

param koszt_ropy_za_tone := 
    B1 1300
    B2 1500;

param koszt_destylacji_za_tone := 10;
param koszt_krakowania_za_tone := 20;

param wydajnosc_destylacji: Benzyna Olej Destylat Resztki BenzynaKrakowana OlejKrakowany ResztkiKrakowane :=
    B1 0.15 0.40 0.15 0.15 0.0 0.0 0.0
    B2 0.10 0.35 0.20 0.25 0.0 0.0 0.0;

param wydajnosc_krakowania :=
    Benzyna 0.0
    Olej 0.0
    Destylat 0.0
    Resztki 0.0
    BenzynaKrakowana 0.50
    OlejKrakowany 0.20
    ResztkiKrakowane 0.06;

param krakowany_produkt := Destylat;

param sklad_paliw: Benzyna Olej Destylat Resztki BenzynaKrakowana OlejKrakowany ResztkiKrakowane :=
    Silnikowe 1 0 0 0 1 0 0
    Domowe 0 1 0 0 0 1 0
    Ciezkie 0 1 1 1 0 0 1;

param wymagana_produkcja :=
    Silnikowe 200000
    Domowe 400000
    Ciezkie 250000;

param dozwolona_siarka :=
    Silnikowe 1.0
    Domowe 0.005
    Ciezkie 1.0;

param zawartosc_siarki: Benzyna Olej Destylat Resztki BenzynaKrakowana OlejKrakowany ResztkiKrakowane :=
    B1 0.0 0.002 0.0 0.0 0.0 0.003 0.0
    B2 0.0 0.012 0.0 0.0 0.0 0.025 0.0;


end;
