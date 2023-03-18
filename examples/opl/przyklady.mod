/*********************************************
 * OPL 12.3 Model
 * Author: Pawel Zielinski
 * Przyklady z wykladu
 ********************************************/

int m = ...;
int n = ...;
range wiersze = 1..m;
range kolumny = 1..n;
float b[wiersze] = ...;
float A[wiersze][kolumny] = ...;
float c[kolumny] = ...;


dvar float+ x[kolumny];


maximize 
	sum (j in kolumny) c[j]*x[j];
subject to {
  forall(i in wiersze)
    ograniczenia:
      sum (j in kolumny) A[i][j]*x[j]<=b[i];
}






