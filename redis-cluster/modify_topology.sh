#!/bin/bash

MODE=$1

for i in {0..7}
do
    file="./cluster_data/750$i/nodes.conf"
    backup="./cluster_data/750$i/nodes_back.conf"
    if [ "$MODE" == "backup" ]; then
        if [ -f "$file" ]; then
            cp "$file" "$backup"
            rm "$file"
            echo "Backed up and removed $file"
        else
            echo "$file does not exist"
        fi
    elif [ "$MODE" == "restore" ]; then
        if [ -f "$backup" ]; then
            cp "$backup" "$file"
            echo "Restored $file from backup"
        else
            echo "Backup $backup does not exist"
        fi
    else
        echo "Invalid MODE: $MODE. Use 'backup' or 'restore'."
        exit 1
    fi
done