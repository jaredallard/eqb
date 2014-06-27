#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_mainupdater
# MOD_AUTHOR: RainbowDashDC
# MOD_VERSION: 1.0
# MOD_DESC: Updater Module for RRPG. (Using to show how to use a module.)
# MOD_UPDATE_LINK: http://rainbowdashdc.github.io/rrpg/mod_mainupdater.xml
# MOD_UPDATE_TYPE: XML
#
##########################
export enabled="no"    #
##########################
if [ ! "$enabled" == "yes" ]; then
	echo "ERR:DISABLED"
	return
fi

## USE FUNCTIONS IN MODULES. ALLOWS CALLING MOD LATER.
## YOU DON'T HAVE TO THOUGH, i.e Updater or replacing content, etc.
## ALTHOUGH, IF YOU NEED GLOBAL FUNCTIONS, USE FUNCTIONS HERE.
## LOCATION IS RELATIVE TO BASE FOLDER ALWAYS.

function check_ver {
	if [ ! "$1" == "$2" ]; then
		clear
		echo "Please note that you are running an outdated version."
		echo "Current Version: $2"
		echo "Your Version: $1"
		echo ""
		read -p "Press any key to go continue."
	else
		echo "OK"
	fi
}

function get_server_ver {
	wget -q -O tmp/ver.tmp http://rainbowdashdc.github.io/rrpg/ver.txt
	export server_ver="$(cat tmp/ver.tmp)"
	check_ver $1 $server_ver
}

function get_ver {
	export curr_ver="$(cat rrpg.sh | grep '## VERSION-SEARCH' | awk -F '=' '{ print $2}' | awk '{ print $1 }')"
	get_server_ver $curr_ver
}



get_ver
