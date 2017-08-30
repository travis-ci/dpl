#!/bin/bash

let e=0


for path in lib/dpl/provider/*.rb; do
  file=$(basename $path)
  provider=${file%*.rb}
  echo -e "Testing $provider\n"
  rvm gemset create $provider
  rvm gemset use $provider

  set -v
  gem install dpl-*.gem

  echo -e "\n\n\n\n" | dpl --provider=$provider --skip-cleanup=true 2>&1 | egrep 'LoadError'
  if [[ $? -eq 0 ]]; then
    echo "Failed to load $provider\n"
    (( e += 1 ))
  fi
done
exit $e
