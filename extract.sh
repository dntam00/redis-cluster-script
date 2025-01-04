#/bin/bash

cluster_nodes=$(redis-cli -h 127.0.0.1 -p 7500 cluster nodes)

base_port=7506
node_id=$(echo "$cluster_nodes" | awk -v port="$base_port" '{if ($2 ~ "127\\.0\\.0\\.1:" port "@") print $1}')

echo "$cluster_nodes"

echo "Node ID for port 7500: $node_id"