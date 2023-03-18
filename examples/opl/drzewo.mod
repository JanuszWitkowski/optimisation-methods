/*********************************************
 * OPL 12.3 Model
 * Author: Pawel Zielinski
 * zagadnienie drzewa rozpinajacego w grafie G=<E,V>
 *********************************************/
int n = ...;   // liczba wierzcholkow
assert
	n>1;
	
range Vminus1 = 2..n;
  

// Rekord krawed od i - j 
tuple krawedz {
   key int i;
   key int j;
}
{krawedz} E = ...;// zbior krawedzi
{krawedz} A =E union {<j,i> | <i,j> in E}; 

float  c[E] = ...; // c[i,j]  waga krawedzi (i,j) 

// zmienne decyzyjne

dvar float+ f[A, Vminus1];
// zmienne przeplywowe 

dvar float+ y[A];
/* yij=1  lub yji=1 jesli krawedza {i,j} nalezy do drzewa
 rozpinajacego */
 
 // calkowity koszt drzewa
 dexpr float Koszt = sum (<i,j> in E) c[<i,j>] * (y[<i,j>]+y[<j,i>]);


 // funkcja celu koszt drzew
 minimize 
  	Koszt; // minimalizacja na dlugosci drzewa rozpinajacego

 subject to{
  forall (k in Vminus1)
     zrodla:
       sum(<j,1> in A) f[<j,1>,k]-sum(<1,j> in A) f[<1,j>,k]== -1;
  forall (k in Vminus1, i in Vminus1 : k != i)
     bilans:
       sum(<j,i> in A) f[<j,i>,k]-sum(<i,j> in A) f[<i,j>,k]== 0;
  forall (k in Vminus1)
     ujscia:
       sum(<j,k> in A) f[<j,k>,k]-sum(<k,j> in A) f[<k,j>,k]== 1;
  forall (k in Vminus1, <i,j> in A)
     pojemnosci:
       f[<i,j>,k] <= y[<i,j>];
  drzewo:
     sum(<i,j> in A) y[<i,j>] == n-1;
 }


execute OUTPUT_NA_KONSOLE {
  writeln("koszt drzewa =", Koszt);
   writeln("krawedzie drzewa rozpinajacego");
   for(var e in A)
      if(y[e] > 0)
         writeln(e.i,"->",e.j);
}         
         

 
 
 