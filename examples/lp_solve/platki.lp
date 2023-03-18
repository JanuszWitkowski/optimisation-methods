/* Problem mieszanki - firma Breakfest Company */
/* funkcja celu  */
min: 4 A +3 B + 2 C;

/* Ograniczenie*/
zapot:   A+B+C >= 1000;
sklaA:    0.9 A -0.1 B - 0.1 C >= 0;  /* co najmniej 10% skladnika A */
sklaB:   -0.1 A +0.9 B - 0.1 C >= 0;  /* co najmniej 20% skladnika B */
sklaC:                       C <= 400; /* ogr zwiazane ze smakiem */
                       
   