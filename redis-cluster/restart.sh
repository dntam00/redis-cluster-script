start_redis_cluster() {
    local port=7501
    local node_dir="cluster_data/$port"
    mkdir -p "$node_dir"
    pushd "$node_dir" > /dev/null

    # Start a Redis server with cluster enabled and no replicas
    redis-server --port "$port" --cluster-enabled yes \
                 --cluster-config-file "nodes.conf" \
                 --cluster-node-timeout 5000 --save "" --appendonly yes \
                 --appendfilename "appendonly.aof" \
                 --dbfilename "dump.rdb" \
                 --logfile "redis.log" &
    local pid=$!
    redis_pids+=("$pid")
    popd > /dev/null
}


start_redis_cluster