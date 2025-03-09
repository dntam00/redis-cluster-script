#!/bin/bash

data="1) 1) (integer) 0
   2) (integer) 6127
   3) 1) "127.0.0.1"
      2) (integer) 7500
      3) "bf5747789e6e06ed987ba7f1674a25ffb9511315"
      4) (empty array)
   4) 1) "127.0.0.1"
      2) (integer) 7505
      3) "7b93c1741a627ed7442e28799c77fdb71db5f5ea"
      4) (empty array)
2) 1) (integer) 6128
   2) (integer) 10922
   3) 1) "127.0.0.1"
      2) (integer) 7501
      3) "2ab68255ec18689cebadcf4ff18c7ec702088232"
      4) (empty array)
   4) 1) "127.0.0.1"
      2) (integer) 7503
      3) "0c1ced2d06751bc853e49ff3c2a448c291352026"
      4) (empty array)
3) 1) (integer) 10923
   2) (integer) 11588
   3) 1) "127.0.0.1"
      2) (integer) 7500
      3) "bf5747789e6e06ed987ba7f1674a25ffb9511315"
      4) (empty array)
   4) 1) "127.0.0.1"
      2) (integer) 7505
      3) "7b93c1741a627ed7442e28799c77fdb71db5f5ea"
      4) (empty array)
4) 1) (integer) 11589
   2) (integer) 16383
   3) 1) "127.0.0.1"
      2) (integer) 7502
      3) "4c3af22b42a9c9f37d78c7c5e7a89f5ee773ef32"
      4) (empty array)
   4) 1) "127.0.0.1"
      2) (integer) 7504
      3) "2ef71809133a85506ec1c31f41d00a2ac8313f36"
      4) (empty array)"

process_slot_data() {
    local slot_start=""
    local slot_end=""
    local total_gap=0

    while IFS= read -r line; do
        echo "Line: $line"
        if [[ $line =~ ^[0-9]+\) ]]; then
            echo selected: "$line"
            if [[ -n $slot_start ]]; then
                gap=$((slot_end - slot_start + 1))
                total_gap=$((total_gap + gap))
            fi
            slot_start=$(echo $line | awk '{print $3}')
        elif [[ $line =~ ^[[:space:]]+2\) ]]; then
            slot_end=$(echo $line | awk '{print $3}')
        fi
        # echo "Slot start: $slot_start, Slot end: $slot_end"
    done <<< "$(echo -e "$data")"

    if [[ -n $slot_start ]]; then
        gap=$((slot_end - slot_start + 1))
        total_gap=$((total_gap + gap))
    fi

    echo "Total gap: $total_gap"
}

# Main script execution
process_slot_data