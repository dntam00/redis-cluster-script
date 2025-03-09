#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "usage: $0 <to_be_removed_master_port> <send_command_to_target_port>"
  exit 1
fi

to_be_removed_master_port=$1
send_command_to_target_port=$2

echo "start to failover $to_be_removed_master_port"

redis-cli -h 127.0.0.1 -p "$to_be_removed_master_port" debug segfault

echo "wait..."

sleep 10

cluster_nodes=$(redis-cli -h 127.0.0.1 -p $send_command_to_target_port cluster nodes)

echo "current cluster nodes: $cluster_nodes"

old_master_node_id=$(echo "$cluster_nodes" | awk -v port="$to_be_removed_master_port" '{if ($2 ~ "127\\.0\\.0\\.1:" port "@") print $1}')

echo "start to forget old master node: $old_master_node_id from cluster"

redis-cli -h 127.0.0.1 -p "$send_command_to_target_port" cluster forget "$old_master_node_id"

echo "finish"

cluster_nodes=$(redis-cli -h 127.0.0.1 -p $send_command_to_target_port cluster nodes)

echo "current cluster nodes: $cluster_nodes"

# redis-cli -p 7500 cluster addslots {0..665} {5461..6127} {10923..11588}