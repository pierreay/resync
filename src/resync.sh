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

trap "exit" INT

source="$1"
shift
echo "Source: $source"
echo -n "Destination(s): "
for remote in $*; do
    echo -n "$remote "
done
echo -e "\n"

while inotifywait -r -e modify,create,delete,move "$source"; do
    for remote in $*; do
        rsync -avz --progress "$source" $remote:
    done
done
