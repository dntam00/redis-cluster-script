#!/bin/bash

wait_for_redis() {
  local port=$1
  while ! redis-cli -p "$port" ping > /dev/null 2>&1; do
    echo "waiting for Redis node on port $port to start..."
    sleep 1
  done
  echo "redis node on port $port is available."
}

# Array to hold PIDs of Redis server processes
declare -a redis_pids

add_shard() {
    local masters=1
    local replicas=1
    local base_port=$1
    local cluster_dir="./cluster_data"

    {
        local port=$((base_port))
        local node_dir="$cluster_dir/$port"
        rm -rf "$node_dir"
        mkdir -p "$node_dir"
        pushd "$node_dir" > /dev/null

        # Start a Redis server with cluster enabled and no replicas
        redis-server --port "$port" --cluster-enabled yes \
                    --cluster-config-file "nodes.conf" \
                    --cluster-node-timeout 5000 --save "10 1" --appendonly yes \
                    --appendfilename "appendonly.aof" \
                    --dbfilename "dump.rdb" \
                    --logfile "redis.log" &
        redis_pids[i]=$!
        popd > /dev/null
        redis_nodes+=("127.0.0.1:$port")
    }

    {
        local port=$((base_port + masters))
        local node_dir="$cluster_dir/$port"
        mkdir -p "$node_dir"
        pushd "$node_dir" > /dev/null

        # Start a Redis server with cluster enabled and no replicas
        redis-server --port "$port" --cluster-enabled yes \
                    --cluster-config-file "nodes.conf" \
                    --cluster-node-timeout 5000 --save "10 1" --appendonly yes \
                    --appendfilename "appendonly.aof" \
                    --dbfilename "dump.rdb" \
                    --logfile "redis.log" &
        local pid=$!
        redis_pids+=("$pid")
        popd > /dev/null
        redis_nodes+=("127.0.0.1:$port")
    }

    for port in "${redis_nodes[@]}"; do
        wait_for_redis "${port##*:}"
    done

    echo "create new master node: ${redis_nodes[*]}"

    redis-cli -h 127.0.0.1 -p 7500 --cluster add-node "127.0.0.1:$base_port" 127.0.0.1:7500

    sleep 5

    cluster_nodes=$(redis-cli -h 127.0.0.1 -p 7500 cluster nodes)

    echo "current cluster nodes: $cluster_nodes"

    # new_master_node_id=$(echo "$cluster_nodes" | awk '/127\.0\.0\.1:7506@/ {print $1}')
    new_master_node_id=$(echo "$cluster_nodes" | awk -v port="$base_port" '{if ($2 ~ "127\\.0\\.0\\.1:" port "@") print $1}')

    echo "start add new master node: $new_master_node_id to cluster"

    redis-cli -h 127.0.0.1 -p 7500 --cluster add-node 127.0.0.1:7507 127.0.0.1:7500 --cluster-slave --cluster-master-id "$new_master_node_id"
}

# Function to shut down Redis cluster nodes
shutdown_redis_cluster() {
  echo "Shutting down Redis cluster nodes..."
  for pid in "${redis_pids[@]}"; do
    kill "$pid"
  done
}

# Trap Ctrl+C (SIGINT) to call shutdown function
trap shutdown_redis_cluster SIGINT

# Check if the number of masters and replicas is provided
if [ -z "$1" ]; then
  echo "usage: $0 <new_shard_port>"
  exit 1
fi

add_shard "$1"

# Wait until a keyboard interrupt (Ctrl+C) is detected
echo "redis cluster is running. Press Ctrl+C to stop."
wait