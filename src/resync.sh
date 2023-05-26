#!/bin/bash

if [[ $# < 2 ]]; then
    cat << EOF
Usage: resync PATH HOSTNAME [HOSTNAMES...]
PATH is a git repository path being the synchronization source.
HOSTNAME(S) are one or multiple SSH hostnames being the synchronization destination.
EOF
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "Error: $1 is not a valid directory!"
    exit 1
fi

while inotifywait -r -e modify,create,delete,move "$1"; do
    for remote in $*; do
        rsync -avz --progress "$1" $remote:
    done
done
