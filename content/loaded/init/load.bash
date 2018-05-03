#!/bin/bash
clear
level="$1"
cecho "Loading Level..." red
echo "OK"
clear

# Load Item API
# shellcheck source=engine/rrpg_item.bash
source "$ENGINE_DIR/rrpg_item.bash"

# Build the UI.
draw_main && prompt "$1"
