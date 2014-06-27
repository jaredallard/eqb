#!/bin/bash
# AUTHOR: RAINBOWDASHDC (@RAINDASHDC) (@2ROOT4YOU)
# COPYRIGHT: RDASHINC (RDCoding) http://rdashinc.tk/
# DESC: RRPG Content Loading Script.
# DATE: SUNDAY, 6 JULY 2013.
# NOTE: I code too much...

## VARIABLES
export content_ver="1.3.2-release"
export content_date="24/10/13-BTF"
export basedir=$(get_basedir.cmd)

## CHECK CMDLINE.
if [ "$1" == "" ]; then
	echo "USAGE: rrpg_content.bash [level]"
	exit
fi

## Load Modules
source $basedir/content/rrpg_modloader.bash 1>/dev/null

function init_cp {
	# Handles anything level based.
	source $basedir/content/loaded/init/load.bash
}




###################################################################
## INIT & Message to Users                                        #
###################################################################
## Yes, I know it's possible to simply "cmd-line" to a level.     #
## It's generally presumed that one would simply, play the game.  #
## So, don't cheat. Play the game. I spent alot of time on this.  #
###################################################################
init_cp "$1"