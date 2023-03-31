set Cities;
set Cranes;

param distances{Cities, Cities}, >= 0;
param excess{Cranes, Cities}, integer;
param transport{Campers, Cities}, >= 0;
param could_replace symbolic in Cranes;

