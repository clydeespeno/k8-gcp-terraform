#!/bin/bash

instance=$1
count=$(($2 - 1))

for i in $(seq 0 "$count"); do
  taint_instance="google_compute_instance.$instance"
  index="[$i]"
  cmd="terraform taint "$taint_instance$index""
  echo $cmd
  eval $cmd
  echo ""
done
