printf "Planner;Problem;Total_Time;Translation_Time;Search_Time;Plan_Cost;Plan_Length;Expanded;Translation_Memory;Search_Memory;Solution"
for solver_dir in $(find build -mindepth 1 -maxdepth 1 -type d); do
   solver=$(basename "$solver_dir")
   for problem_dir in "$solver_dir"/*; do
      problem=$(basename "$problem_dir")
      (echo "!!!! $solver $problem"; cat "$problem_dir/result.txt") | awk -f process-fd.awk
   done
done
(echo "!!!! fd-lama-firstX very-difficult"; cat simplified-domain/very-difficult.out) | awk -f process-fd.awk

echo ""
