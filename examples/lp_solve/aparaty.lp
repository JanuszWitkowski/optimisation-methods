/* Wybor asortymentu  - Firma Candid Camera Company*/

/* funkcja celu */
max: 3 cub + 9 quick + 25 vip;

/* ograniczenia */
produkcja:  0.1 cub + 0.2  quick +  0.7 vip <= 250;
montaz:     0.2 cub + 0.35 quick +  0.1 vip <= 350;
testowanie: 0.1 cub + 0.2  quick + 0.3 vip <= 150;
	        cub                        >= 250;
			    quick          >= 375;
                                       vip >= 150;
int cub, quick,vip; 					