#!/bin/bash
# AUTHOR: Jared Allard <jaredallard@outlook.com>
# COPYRIGHT: None
# DESC: RRPG Content Loading Script.
# DATE: SUNDAY, 6 JULY 2013.
# NOTE: I code too much...

## VARIABLES
export content_ver="1.3.2-release"
export content_date="24/10/13-BTF"

## CHECK CMDLINE.
if [ "$1" == "" ]; then
	echo "USAGE: rrpg_content.bash [level]"
	exit
fi

## Load Modules
# shellcheck source=engine/rrpg_modloader.bash
source "$basedir/engine/rrpg_modloader.bash" 1>/dev/null

function init_cp {
	# Handles anything level based.

	# shellcheck source=content/loaded/init/load.bash
	source "$basedir/content/loaded/init/load.bash"
}




###################################################################
## INIT & Message to Users                                        #
###################################################################
## Yes, I know it's possible to simply "cmd-line" to a level.     #
## It's generally presumed that one would simply, play the game.  #
## So, don't cheat. Play the game. I spent alot of time on this.  #
###################################################################
init_cp "$1"
