#!/bin/bash

for i in {0..5}; do redis-cli -p "750$i" pubsub shardchannels | grep -Ev "(empty array|^[[:space:]]*$)" | wc -l; done