/* Model programowania mieszanego (mieszanka problemow LP i programowania calkowitoliczbowego) */

/* Funkcja celu*/
max: -3 x1 - 2 x2 + 10;

/* ograniczenia */
  x1 - 2  x2 +x3        = 2.5;
2 x1 +    x2        +x4 =1.5;


/* zmienne x1,x4 sa domyslenie rzeczywiste nieujemne */

/* deklaracja zmiennych calkowitoliczbowych */
int x2,x3;