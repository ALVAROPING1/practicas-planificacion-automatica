#!/usr/bin/env bash

COUNT=10
SEM=sem
MUTEX=mutex

delay () {
		  sleep 0.01
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
								echo "Semaphore acquired $SEMAPHORE"
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


downward_helper () {
		  local name
		  local path
		  local domain
		  local kind
		  name=$4:$1
		  path=$2
		  domain=$3
		  shift 4
		  mkdir -p "$name"
		  SEM=../sem
		  MUTEX=../mutex
		  cd "$name"
		  run "$DOWNWARD" $@ $domain $path > out.txt &
		  cd ..
		  MUTEX=/mutex
		  SEM=sem
}

downward () {
		  downward_helper $@ 1 --alias lama-first
		  downward_helper $@ 2 --alias seq-sat-lama-2011 --search-time-limit 1800
		  downward_helper $@ 3 --alias seq-opt-fdss-1 --search-time-limit 1800
}



if [ "$DOMAIN" == "" ]; then
		  echo "Please specify DOMAIN path"
		  exit -1
fi

if [ "$NAME" == "" ]; then
		  echo "Please specify NAME"
		  exit -1
fi

if [ "$DOWNWARD" == "" ]; then
		  echo "Specify DOWNWARD executable"
		  exit -1
fi

if [ "$JOBS" == "" ]; then
		  echo "Specify JOBS executable"
		  exit -1
fi

echo "$JOBS" > "$SEM"
for name in $(ls "$DOMAIN" | grep -v 'domain[.]pddl' | head -n $COUNT); do
		  path="$DOMAIN/$name"
		  downward "$name" "$path" "$DOMAIN/domain.pddl"
done

wait
rm "$SEM"
