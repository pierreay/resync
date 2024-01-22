#!/bin/bash

# * Global configuration

# We want to exclude files changing while we are typing:
# 1. Git index and locking files.
# 2. Emacs temporary files.
# 3. Syncthing temporary files.
# XXX: .git/index are still transferred by Rsync. Useful to exclude them? I'm
# not sure, until they are not watched by inotify.
RSYNC_EXCLUDE="*.git/index,*.git/index.lock,.#*,.syncthing*"
INOTIFY_EXCLUDE=".git/index|.git/index.lock|.#|.syncthing"

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

function rsync_wrapper() {
    log_info "$remote ; $(date --rfc-3339=seconds)"
    rsync -avz --progress --exclude={"$RSYNC_EXCLUDE"} "$source" $remote:git/
}

# Exit on a CTRL-C.
trap "exit" INT

# Handle arguments.
FORCE=0
# Consume the first argument if it is a -f switch.
if [[ "$1" == "-f" ]]; then
    FORCE=1
    shift
fi

# Print help if number of argument is less than 2.
if [[ $# < 2 ]]; then
    cat << EOF
Usage: resync [-f] PATH HOSTNAME [HOSTNAMES...]

PATH is a git repository path being the synchronization source.
HOSTNAME(S) are one or multiple SSH hostnames being the synchronization destination.

If -f is specified, force a synchronization at initialization time.
EOF
    exit 1
fi

# Safety-check for first argument.
if [[ ! -d "$1" ]]; then
    log_error "$1 is not a valid directory!"
    exit 1
fi

# Use the first argument as the source (PATH).
source="${1%/}"
shift
log_info "Source: $source"
log_info "Destination(s): "
for remote in $*; do
    log_info "-> $remote "
done

# Force first sync if FORCE is 1 based on command-line switches.
if [[ $FORCE == 1 ]]; then
    rsync_wrapper "$source" "$remote"
fi

while inotifywait -r -e modify,create,delete,move --exclude="$INOTIFY_EXCLUDE" "$source"; do
    for remote in $*; do
        rsync_wrapper "$source" "$remote"
    done
done
