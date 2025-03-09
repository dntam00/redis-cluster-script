#!/bin/bash

for i in {0..7}
do
  # Define the file name pattern
  file="./cluster_data/750$i/nodes.conf"
  
  # Check if the file exists before attempting to remove it
  if [ -f "$file" ]; then
    rm "./cluster_data/750$i/nodes.conf"
    rm "./cluster_data/750$i/dump.rdb"
    rm -r "./cluster_data/750$i/appendonlydir"
  else
    echo "$file does not exist"
  fi
done