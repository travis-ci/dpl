#!/bin/bash
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

let e=0

RED="\033[31;1m"
GREEN="\033[32;1m"
RESET="\033[0m"

travis_time_start() {
  travis_timer_id=$(printf %08x $(( RANDOM * RANDOM )))
  travis_start_time=$(travis_nanoseconds)
  echo -en "travis_time:start:$travis_timer_id\r${ANSI_CLEAR}"
}

travis_time_finish() {
  local result=$?
  travis_end_time=$(travis_nanoseconds)
  local duration=$(($travis_end_time-$travis_start_time))
  echo -en "\ntravis_time:end:$travis_timer_id:start=$travis_start_time,finish=$travis_end_time,duration=$duration\r${ANSI_CLEAR}"
  return $result
}
travis_nanoseconds() {
  local cmd="date"
  local format="+%s%N"
  local os=$(uname)

  $cmd -u $format
}


for path in lib/dpl/provider/*.rb; do
  file=$(basename $path)
  provider=${file%*.rb}
  travis_time_start
  echo -e "${GREEN}Testing $provider\n${RESET}"
  rvm gemset create $provider
  rvm gemset use $provider

  gem install dpl-*.gem

  echo -e "\n\n\n\n" | dpl --provider=$provider --skip-cleanup=true 2>&1 | egrep 'LoadError'
  if [[ $? -eq 0 ]]; then
    echo "${RED}Failed to load $provider\n${RESET}"
    (( e += 1 ))
  fi
  travis_time_finish
done

exit $e
