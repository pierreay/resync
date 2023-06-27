#!/bin/bash

source log.sh

if [[ $# < 2 ]]; then
    cat << EOF
Usage: resync PATH HOSTNAME [HOSTNAMES...]
PATH is a git repository path being the synchronization source.
HOSTNAME(S) are one or multiple SSH hostnames being the synchronization destination.
EOF
    exit 1
fi

if [[ ! -d "$1" ]]; then
    log_error "$1 is not a valid directory!"
    exit 1
fi

trap "exit" INT

source="$1"
shift
log_info "Source: $source"
log_info "Destination(s): "
for remote in $*; do
    log_info "-> $remote "
done

while inotifywait -r -e modify,create,delete,move "$source"; do
    for remote in $*; do
        log_info $(date --rfc-3339=seconds)
        rsync -avz --progress "$source" $remote:
    done
done
