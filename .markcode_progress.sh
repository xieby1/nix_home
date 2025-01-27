#!/usr/bin/env bash

n=$(grep "#MC" -rl --include="*.nix" | grep -v "book/" | wc -l)
d=$(find -name "*.nix" | grep -v "book/" | wc -l)

sed -i '1 s,[0-9]\+/[0-9]\+,'$n'/'$d',' ./README.md
