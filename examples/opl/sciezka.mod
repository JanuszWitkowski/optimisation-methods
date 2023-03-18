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

  

// Rekord luk od i do j z kosztem (waga) c
tuple luk {
   key int i;
   key int j;
   float c;
}
{luk} A = ...;// zbior lukow

//zmienne decyzyjne
dvar float+ x[A] in 0 .. 1; //* x_(i,j) =1 jezeli luk nalezy do najkrotszej sciezki, 0 w przeciwnym przypadku

// calkowity koszt
dexpr float Koszt = sum (a in A) a.c * x[a];

minimize Koszt;
subject to {
   OgraniczenieZrodlo:
     sum (<s,j,c> in A) x[<s,j,c>] == 1;
   OgraniczenieUjscie:
     sum (<j,t,c> in A) x[<j,t,c>] == 1;    
   forall (i in V : i != s && i != t)
     // tyle samo wyplywa co wplywa *     
     OgraniczeniaBalansowe:
   	    sum (<i,j,c> in A) x[<i,j,c>] -sum (<j,i,c> in A) x[<j,i,c>] == 0;   	          
}


execute OUTPUT_NA_KONSOLE {
   writeln("\n luki nalezace do sciezki\n");
   for(var a in A)
      if(x[a] > 0)
         writeln(a.i,"->",a.j);
}
 