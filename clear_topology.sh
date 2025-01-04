#!/bin/bash

# clear nodes.conf to make cluster topology invalid.

if [ -z "$1" ]; then
    echo "usage: $0 <total_nodes>"
    exit 1
fi

total_nodes=$1

for i in $(seq 0 $total_nodes);
do
    file="./cluster_data/750$i/nodes.conf"
    if [ -f "$file" ]; then
        rm "$file"
        echo "remove file $file"
    else
        echo "$file does not exist"
    fi
done