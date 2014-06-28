#!/bin/bash
clear
level="$1"
cecho "Loading Level..." red
echo "OK"
clear
source $basedir/content/loaded/levels/$1 !>/dev/null || erorr_exit "Err: Failed to load level: '$level'."
$1   