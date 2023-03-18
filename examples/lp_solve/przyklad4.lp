/* Zmodyfikowany Przyklad 3 z materialow do wykladu */
/* Przyklad ilustruje sytuacje, w ktorej funkja celu nie jest ograniczona z gory */
/* lp_solve generuje komunikat UNBOUNDED ! */
/* Funkcja celu */
max:  x1 +0.3333 x2;

/* Ograniczenia */
ograniczenie_nr_1:   -2 x1  + 5 x2 <= 150;
ograniczenie_nr_2:      x1  +   x2 >= 20;
                        x1         >= 5;
/* domyslnie zmienne x1 i x2 sa rzeczywiste nieujemne */