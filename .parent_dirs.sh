#!/usr/bin/env bash

path="$1"
echo $path
dir=$(dirname "$path")
while true; do
    echo $dir/

    dirdir=$(dirname "$dir")
    if [[ "$dir" != "$dirdir" ]]; then
        dir="$dirdir"
    else
        break
    fi
done
