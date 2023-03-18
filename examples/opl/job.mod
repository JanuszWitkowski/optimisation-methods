/*********************************************
 * OPL 12.3 Model
 * Author: Pawel Zielinski
 * Danych jest m zadan i n maszyn oraz
 * czasy wykonania i-tego zadania na j-tej maszynie
 * i=1,..,m, j=1,...,n.
 * Kazde zadanie musi byc wykonane najpierw na maszynie 1 potem na 2
 * i tak do n.
 *Podac harmonogram wykonania wszystkich zadan tak aby czas 
 * zakonczenia calego procesu byl najmniejszy 
 
 *********************************************/

//parametry
int m = ...; // liczba zadan
int n = ...; // liczba maszyn

range Task = 1..m;
range Machine = 1..n;



float d[Task][Machine] = ...; //d_ij czas wykonania zadania i na j-tej maszynie
float B=1+sum(i in Task, j in Machine) d[i,j]; //duza liczba wraz z inicjalizacja

tuple MachineTaskTask {
  int j;
  int i;
  int k;
}
{MachineTaskTask} Precedence ={<j,i,k> | j in Machine, i in Task, k in Task: i<k};


// zmienne decyzyjne
dvar float+ t[Task][Machine]; // zmienne moment rozpoczecia i-tego zadania na j-tej maszynie
dvar float+ ms; //zmienna czas zakonczenia wykonawania wszystkich zadan - makespan 
dvar boolean y[Precedence]; // zmienne pomocnicze 
                            // potrzebne przy zamienia ograniczen zasobowych
 
 // funckcja celu
minimize 
	ms; //minimalizacja czasu zakonczenia wszystkich zadan


subject to{
  // moment rozpoczecia i-tego zadania na j+1-szej maszynie 
  // musi >= od momentu zakonczenia i-tego zadania na j-tej maszynie   
  forall(i in Task, j in Machine:j<n)
  	 poprzedzanie:
  	   t[i][j+1]>=t[i][j]+d[i][j]; 
  	   
  // t_ij>=t_kj+d_kj lub t_kj>=t_ij+d_ij 
  // ograniczenia zosobowe tj,. tylko jedno zadanie wykonywane jest
  // w danym momencie na j-tej maszynie 	   
  forall(<j,i,k> in Precedence) 
  	zasoby1:
  	   t[i][j]-t[k][j]+B*y[<j,i,k>]>=d[k][j];
  forall(<j,i,k> in Precedence) 	   
  	zasoby2:
  	  	 t[k][j]-t[i][j]+B*(1-y[<j,i,k>])>=d[i][j]; 
  	  	 
  // ms rowna sie czas zakonczenia wszystkich zadan na ostatniej maszynie	  	   
  forall(i in Task)
  	dociskanie:
  	  t[i][n]+d[i][n]<=ms;   
}  

                            
                                                     