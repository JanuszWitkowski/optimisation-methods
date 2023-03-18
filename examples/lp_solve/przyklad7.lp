/* Model programowania binarnego */

/* Funkcja celu*/
max: -8 x1 - 2 x2 -4 x3 -7 x4 - 5x5 +10;

/* ograniczenia */
  -3x1  -  3 x2   +  x3 +2x4 +3x5 <= -2;
  -5x1  -  3 x2   - 2x3  -x4  +x5 <=-4;


bin x1, x2, x3, x4, x5;
