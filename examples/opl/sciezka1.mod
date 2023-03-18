
/*********************************************
 * OPL 12.3 Model
 * Author: Pawel Zielinski
 * zagadnienie nakrotszej sciezki w grafie G=<A,V>  z wierzcholka s do t
 *********************************************/
int n = ...;   // liczba wierzcholkow
assert
	n>1;

range V = 1..n;

int s =...;
int t =...;

// wszelki wypadek
assert
  t in V  && s in V && s != t;

// przedzial wag 
float l = ...;
float u = ...;
assert
  l>= 0 && l<u;
    

// Rekord luk od i do j z kosztem (waga) c
tuple luk {
   key int i;
   key int j;
}
{luk} A = {<i,j> | i in V, j in V :i<j};// zbior lukow - generuje acykliczny graf

float c[a in A]; // koszt luku (i,j)

execute GenerowanieLosowychKosztow {
  for (var a in A) {
  	 c[a] =  l+(u-l)*Math.random();
     writeln(a.i,"->",a.j," = ", c[a]); // wydruk na konsoli
   }     
}  



//zmienne decyzyjne
dvar float+ x[A] in 0 .. 1; //* x_(i,j) =1 jezeli luk nalezy do najkrotszej sciezki, 0 w przeciwnym przypadku

// calkowity koszt
dexpr float Koszt = sum (a in A) c[a] * x[a];

minimize Koszt;
subject to {
   OgraniczenieZrodlo:
     sum (<s,j> in A) x[<s,j>] == 1;
   OgraniczenieUjscie:
     sum (<j,t> in A) x[<j,t>] == 1;    
   forall (i in V : i != s && i != t)
     // tyle samo wyplywa co wplywa *     
     OgraniczeniaBalansowe:
   	    sum (<i,j> in A) x[<i,j>] -sum (<j,i> in A) x[<j,i>] == 0;   	          
}

// wydruk rozwiazania na konsoli
execute OUTPUT_NA_KONSOLE {
   writeln("\n luki nalezace do sciezki\n");
   for(var a in A)
      if(x[a] > 0)
         writeln(a.i,"->",a.j);
}