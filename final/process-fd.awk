function strip (s) {
   if (substr(s, 1, 1) == "[") {
      return strip(substr(s, 2));
   } else if (substr(s, length(s)) == "s") {
      return strip(substr(s, 1, length(s) - 1));
   } else {
      return s;
   }
}

/^INFO[ ]*Planner time:/            { total_time = strip($4) }
$1 == "Done!"                       { trad_time = strip($2); }
$4 == "Search" && $5 == "time:"     { search_time = strip($6); }
$4 == "Plan" && $5 == "cost:"       { plan_cost = $6; }
$4 == "Plan" && $5 == "length:"     { plan_length = $6; }
$4 == "Expanded" && $5 ~ /[0-9]+/   { expanded = $5; }
/^Translator peak memory: /         { trad_mem = $4; }
/^Peak memory: /                    { search_mem = $3; }

END {
   # Planificador,Tiempo total,Tiempo de traducción,Tiempo de búsqueda,
   # Coste del plan,Longitud del plan,Nodos expandidos,Memoria de traducción,
   # Memoria de búsqueda
   printf "," total_time;
   printf "," trad_time;
   printf "," search_time;
   printf "," plan_cost;
   printf "," plan_length;
   printf "," expanded;
   printf "," trad_mem;
   printf "," search_mem;
   print ""
}
