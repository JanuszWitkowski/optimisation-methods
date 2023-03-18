/*********************************************
 * OPL 12.3 Model
 * Author: Pawel Zielinski
 * Pub
 * Zagadnienie mieszanki+asortyment - model 
 *********************************************/
{string} alkohole = ...;
{string} drinki = ...;

float Koszt[alkohole] =...; // koszt alkoholu w $ za kwarte
float Cena[drinki] = ...; //  cena drinka w $
float AlkoholWDrinku[drinki] = ...; // ile uncji ma jeden drink
float IloscDostepnegoAlkoholu[alkohole] = ...; // dostepny alkohol w kwartach
 
// rekord
tuple AlkoholDrink {
  string a;
  string d;
}
//rekord
tuple AlkoholDrinkZawartosc {
  AlkoholDrink ad;
  float        z;
}   
{AlkoholDrinkZawartosc} AlkoholeDrinkiZawartosc =...;
{AlkoholDrink} AlkoholeDrinki = {ad | <ad,z> in AlkoholeDrinkiZawartosc};


//zmienne decyzjne
dvar float+ ilosc[AlkoholeDrinki]; // zawartosc alkoholu w drinku w uncjach

//wyrazenie
// ilosc zrobionych drinkow
dexpr float iloscDrinkow[d in drinki]=(sum(ad in  AlkoholeDrinki : ad.d == d ) ilosc[ad])/AlkoholWDrinku[d];

//ilosc zuzytego alkoholu w kwartach
dexpr float iloscZuzytegoAlkoholu[a in alkohole]=(sum(ad in  AlkoholeDrinki : ad.a == a) ilosc[ad])/32.0;

maximize
  sum( d in drinki) Cena[d]*iloscDrinkow[d]
  -sum ( a in alkohole )  Koszt[a]*iloscZuzytegoAlkoholu[a];
  
subject to {
  forall(a in alkohole) 
  	zasobyAlkoholi:
  	  sum(ad in  AlkoholeDrinki : ad.a == a) ilosc[ad] <= 32.0*IloscDostepnegoAlkoholu[a];
  	  
  forall(d in drinki)
    skladDrinkow:
      sum(adz in  AlkoholeDrinkiZawartosc : adz.ad.d == d )  adz.z*ilosc[adz.ad] == 0;
}    
  
  



