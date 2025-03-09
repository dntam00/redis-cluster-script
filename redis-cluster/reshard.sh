#!/bin/bash

if [ -z "$1" ]; then
  echo "usage: $0 <send command to node>"
  exit 1
fi

command_node=$1

redis-cli -p "$command_node" --cluster reshard 127.0.0.1:"$command_node"