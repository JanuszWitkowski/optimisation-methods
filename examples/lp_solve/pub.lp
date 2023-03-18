/* Zagadnienie mieszanki+asortyment */
/* funkcja celu */
max: 0.5 oc_ws+ 0.5 jj_ws +   // Whishey Sour
     0.66660 oc_man + 0.66660 jj_man +0.66660 mw_man + // Manhattan
     0.66660 gb_mar + 0.66660 mw_mar+                 // Martini
     0.75 oc_ps + 0.75 jj_ps + 0.75 gb_ps            // Pub Special
      -0.25 oc_ws -0.25 oc_man -0.25 oc_ps  // koszt Old Cambridge
      -0.3125 jj_ws -0.3125 jj_man -0.3125 jj_ps  // koszt Joy Juice
      -0.3125 mw_man  -0.3125 mw_mar              // koszt Mas Wicked
      -0.1875 gb_mar  -0.1875 gb_ps;               // koszt Gil boy
/* oganiczenia */
Manhattan:   oc_man +jj_man =  2 mw_man;
Martini:     gb_mar          = 2 mw_mar;
Pub_Special: oc_ps + jj_ps   =  gb_ps;

Old_Cambridge:  oc_ws + oc_man + oc_ps <=32;
Joy_Juice:      jj_ws + jj_man + jj_ps <=32;
Mas_Wicked:    mw_man +mw_mar         <=32;
Gil_boy:       gb_mar +gb_ps          <=64;
