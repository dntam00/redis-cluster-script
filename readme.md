# Redis cluster

This repository contains redis script to build, modify a cluster at local machine.

Start a cluster with 3 master shards and each shard has 1 replica node:

```bash
./start_cluster.sh 3 1
```

Add a new shard destined to run on port 7506 to cluster:

```bash
./add_shard.sh 7506
```

Rebalance hash slot to new shard:

```bash
./reshard.sh <send_command_to_any_master_node>
```