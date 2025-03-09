#!/bin/bash

if [ -z "$1" ]; then
  echo "usage: $0 <number_of_nodes>"
  exit 1
fi

nodes=$1
total=0

for ((i=0; i<nodes; i++)); do
    pubsub=$(redis-cli -p "750$i" pubsub shardchannels | grep -Ev "(empty array|^[[:space:]]*$)" | wc -l)
    total=$((total + pubsub))
    echo "node 750$i: $pubsub"
done

echo "===================="
echo "total pubsub: $total"