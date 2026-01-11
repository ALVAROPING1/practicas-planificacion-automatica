function put_result () {
   # Planificador,Tiempo total,Tiempo de traducción,Tiempo de búsqueda,
   # Coste del plan,Longitud del plan,Nodos expandidos,Memoria de traducción,
   # Memoria de búsqueda
   print "";
   printf planner ";" problem;
   printf ";" total_time;
   printf ";" trad_time;
   printf ";" search_time;
   printf ";" plan_cost;
   printf ";" plan_length;
   printf ";" expanded;
   printf ";" trad_mem;
   printf ";" search_mem;
   printf ";" solution;
}

function strip (s) {
   if (substr(s, 1, 1) !~ /[0-9]/) {
      return strip(substr(s, 2));
   } else if (substr(s, length(s)) !~ /[0-9]/) {
      return strip(substr(s, 1, length(s) - 1));
   } else {
      return s;
   }
}

BEGIN { solution = 0; search_mem = 0; }

/^!!!!/                             { planner = $2; problem = $3 }
$4 == "Total" && $5 == "time:"      { total_time = strip($6); }
$1 == "Done!"                       { trad_time = strip($2); }
$4 == "Search" && $5 == "time:"     { search_time = strip($6); }
$4 == "Plan" && $5 == "cost:"       { plan_cost = $6; }
$4 == "Plan" && $5 == "length:"     { plan_length = $6; }
$8 == "expanded"                    { expanded = $7; }
$8 == "Expanded" && $5 ~ /[0-9]+/   { expanded = $5; }
/^Translator peak memory: /         { trad_mem = $4; }
/^[[]t=[0-9]+[.][0-9]+s, [0-9]+ KB/ {
   search_mem = search_mem < $2 ? $2 : search_mem;
   search_time = strip($1);
   total_time = trad_time + search_time;
}

(($4 == "Solution" && $5 == "found" && $6 == "-" && $7 == "keep") ||
     ($0 ~ /^Solution found[.]/)) { solution++; put_result(); }


/^INFO[ ]+Planner time:/            { total_time = strip($4); }

END {
   if (solution == 0) {
      search_time = total_time - trad_time;
      plan_cost = "infinity";
      plan_length = "infinity";
      put_result();
   }
}
