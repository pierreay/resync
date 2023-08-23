#!/bin/bash

# * log_color.sh
# Cloned from:
# https://github.com/pierreay/examples/blob/main/bash/log_color.sh

# Colors definition.
black="\e[30;1m"
red="\e[31;1m"
green="\e[32;1m"
yellow="\e[33;1m"
blue="\e[34;1m"
magenta="\e[35;1m"
cyan="\e[36;1m"
white="\e[37;1m"

# Reset text attributes to normal without clearing screen.
function creset() {
    tput sgr0
}

# Color-echo.
# Argument $1 = message
# Argument $2 = color
function cecho() {
    message="$1"          # Defaults to default message.
    color="${2:-$green}"  # Defaults to green, if not specified.
    echo -n -e "$color"
    echo -n "$message"
    creset
}

function log_error() {
    cecho "[ERROR] " $red
    echo $1
}

function log_warn() {
    cecho "[WARN]  " $yellow
    echo $1
}

function log_debug() {
    cecho "[DEBUG] " $white
    echo $1
}

function log_info() {
    cecho "[INFO]  " $green
    echo $1
}

# * resync.sh

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

source="${1%/}"
shift
log_info "Source: $source"
log_info "Destination(s): "
for remote in $*; do
    log_info "-> $remote "
done

while inotifywait -r -e modify,create,delete,move --exclude="index.lock|.#" "$source"; do
    for remote in $*; do
        log_info "$remote ; $(date --rfc-3339=seconds)"
        rsync -avz --progress --exclude=".#*" "$source" $remote:git/
    done
done
