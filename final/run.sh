#!/usr/bin/env bash

# ==== SEMAPHORE ============================================================ #

COUNT=10
SEM=build/sem
MUTEX=build/mutex

delay () {
        sleep 1.0
}

acquire_mutex () {
        while ! mkdir "$MUTEX" 2> /dev/null; do delay; done
}

release_mutex () {
        rmdir "$MUTEX"
}

release_semaphore () {
        acquire_mutex
        echo $(($(cat "$SEM") + 1)) > "$SEM"
        release_mutex
}

acquire_semaphore () {
        local finish
        finish=0
        while [ $finish -eq 0 ]; do
                acquire_mutex
                if [ $(cat "$SEM") -ne 0 ]; then
                        echo $(($(cat "$SEM") - 1)) > "$SEM"
                        finish=1
                fi
                release_mutex
        done
}


run () {
        acquire_semaphore
        echo "Running $@" > /dev/stderr
        $@
        release_semaphore
}

# ==== SCRIPT =============================================================== #

if [ "$JOBS" == "" ]; then
        echo "Specify JOBS executable"
        exit -1
fi

BUILD=build
MAX_TIME=28800       # 8 hours
PROBLEMS="insert-1 full-mirage full-earth full-water full all-for-estelle complex mega-complex very-difficult"

run_helper () {
        local name
        local path
        local args
        local problem
        name=$1
        path=$2
        args=$3
        problem=$4
        shift 4
        mkdir -p "$BUILD/$name/$problem"
        SEM=../../sem
        MUTEX=../../mutex
        cd "$BUILD/$name/$problem"
        echo $problem $name
        printf "!!!DATA $name,$problem" > result.txt
        run "$path" "$args" ../../../domain.pddl "../../$problem.pddl" >> result.txt &
        cd ../../..
        MUTEX=build/mutex
        SEM=build/sem
}



mkdir -pv "$BUILD"
echo "$JOBS" > "$SEM"

declare -a FD_LAMA_FIRST=(
   "fd-lama-first"
   "$HOME/Software/downward-release-24.06.1/fast-downward.py"
   "--alias lama-first --search-time-limit $MAX_TIME")
declare -a FD_SEQ_SAT_LAMA_2011=(
   "fd-seq-sat-lama-2011"
   "$HOME/Software/downward-release-24.06.1/fast-downward.py"
   "--alias seq-sat-lama-2011 --search-time-limit $MAX_TIME")
# declare -a DECSTAR_2023_SAT=( No axioms
#    "dec-star-2023-sat"
#    "$HOME/PDDL/planner15/fast-downward.py"
#    "--alias seq-sat-decstar --search-time-limit $MAX_TIME")
# declare -a DECSTAR_2023_OPT=(
#    "dec-star-2023-opt"
#    "$HOME/PDDL/planner15/fast-downward.py"
#    "--alias seq-opt-decstar --search-time-limit $MAX_TIME")
# declare -a DECSTAR_2023_AGL=(
#    "dec-star-2023-agl"
#    "$HOME/PDDL/planner15/fast-downward.py"
#    "--alias seq-agl-decstar --search-time-limit $MAX_TIME")

# declare -a SCORPION_2023=(
#    "scorpion"
#    "$HOME/PDDL/planner25/fast-downward.py"
#    "--alias seq-opt-scorpion-2023 --search-time-limit $MAX_TIME")

declare -a PLANNERS=(
   "(${FD_LAMA_FIRST[*]@Q})"
   "(${FD_SEQ_SAT_LAMA_2011[*]@Q})"
   # "(${SCORPION_2023[*]@Q})"
)

for problem in $PROBLEMS; do
   python3 make.py problems/$problem.json > build/$problem.pddl
   for item in "${PLANNERS[@]}"; do
      declare -a planner=$item
      name="${planner[0]}"
      path="${planner[1]}"
      args="${planner[2]}"
      run_helper "$name" "$path" "$args" "$problem"
   done
done

wait
rm "$SEM"
