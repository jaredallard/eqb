#!/bin/bash
#
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_cecho
# MOD_AUTHOR: RainbowDashDC
# MOD_DESC: MOD-PACKED version of RRPG_COLOR. Taken from BTP.
# MOD_VERSION: 1.2-dev
# MOD_UPDATE_TYPE: MANUAL
function cecho_src {
	depends mod_aload
	# TAKES $1 as MSG and $2 as COLOR.
	export black='\033[30m'   #COLOR
	export red='\033[31m'     #COLOR
	export green='\033[32m'   #COLOR
	export yellow='\033[33m'  #COLOR
	export blue='\033[34m'    #COLOR
	export magenta='\033[35m' #COLOR
	export cyan='\033[36m'    #COLOR
	export white='\033[37m'   #COLOR

	# CMDLINE ARGUMENTS
	if [ "$1" == "--list-colors" ]; then
		cat $basedir/mod/mod_cecho.bash | grep -m 8 "#COLOR" | awk -F "=" '{ print $1 }' | awk '{ print $2 }' ### Don't wanna accidently show this... Heh.
		exit
	fi


	# VARIABLES
	export color=$2                   # Set Value of color. ($2)
	echo -e "${!color}\c"             # Get value of the argument that color was.
	export message="$1"               # Set MSG

	echo -e "$message"                # Echo Message.
	tput sgr0                         # Reset to normal.
	return
}

if [ "$1" == "mod_loader" ]; then
	echo "OK"
fi
