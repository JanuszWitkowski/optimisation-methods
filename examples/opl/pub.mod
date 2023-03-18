/*********************************************
 * OPL 12.3 Model
 * Author: Pawel Zielinski
 * Pub
 * Zagadnienie mieszanki+asortyment - model + dane - tak nie powinno sie pisac!!!
 *********************************************/

// zmienne decyzyjne
dvar float+ ocws;    // zawartosc Old Cambridge w drinku Whiskey Sour (w uncjach),
dvar float+ ocman;   // zawartosc Old Cambridge w drinku Manhattan (w uncjach),
dvar float+ ocps;    // zawartosc Old Cambridge w drinku Pub Special (w uncjach),
dvar float+ jjws;    // zawartosc Joy Juice w drinku Whiskey Sour (w uncjach),
dvar float+ jjman;   // zawartosc Joy Juice w drinku Manhattan (w uncjach),
dvar float+ jjps;    // zawartosc Joy Juice w drinku Pub Special (w uncjach),
dvar float+ mwman;   // zawartosc Ma’s Wicked w drinku Manhattan (w uncjach),
dvar float+ mwmar;   // zawartosc Ma’s Wicked w drinku Martini (w uncjach),
dvar float+ gbmar;   // zawartosc Gil-boy w drinku Martini (w uncjach),
dvar float+ gbps;    // zawartosc Gil-boy w drinku Pub Special (w uncjach)



// funkcja celu
maximize 
	 (ocws + jjws)/2 +   // Whishey Sour
     2*(ocman + jjman + mwman)/3 + // Manhattan
      2*(gbmar + mwmar)/3+                 // Martini
     3*(ocps + jjps + gbps)/4            // Pub Special
    - 8*(ocws + ocman +ocps)/32  // koszt Old Cambridge
    - 10*(jjws + jjman +jjps)/32  // koszt Joy Juice
    - 10*(mwman + mwmar)/32              // koszt Mas Wicked
    -  6*(gbmar  +gbps)/32;

// ograniczenia    
subject to {
  Manhattan:
    ocman +jjman ==  2*mwman;
  Martini:     
  	gbmar        ==  2*mwmar;
  PubSpecial: 
  	ocps + jjps  ==  gbps;
  OldCambridge: 
   ocws + ocman + ocps <=  32;
  JoyJuice:  
   jjws + jjman + jjps <= 32;
  MasWicked:    
    mwman + mwmar      <= 32;
  Gilboy:       
    gbmar + gbps       <= 64;    
}        
     