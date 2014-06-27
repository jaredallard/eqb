#!/bin/bash
#
# AUTHOR: RAINBOWDASHDC
# DATE: SEPTEMBER, 01 2013
# VERSION: 1.2.4-dev
# COPYRIGHT: GNUGPLV3 RDCoding. (RDashINC)
# DESC: Simple Module Loader (SML) for RRPG.
## Check all module permissions.

for files in $basedir/mod/mod_**.bash
do
	if [ -x "$files" ]; then
		echo "OK" >/dev/null
	else
		echo -e "Found a non-777 module, attempting to chmod...\c"
		sudo chmod 777 $files
		echo "OK"
	fi
done
## Clear screen for mods.
clear

if [ ! "$1" == "--verbose" ]; then
	echo -n "LOADING MODULES..."
fi

## LOAD mod_functions first (allows mods to call other mods upon execution.)
if [ "$1" == "--verbose" ]; then
	echo "[modloader] Using STDOUT. Not logged." 1>$basedir/tmp/mods.log
	echo -e "[modloader] Preloading Functions (mod_aload.bash)...\c" && source $basedir/mod/mod_aload.bash mod_loader
else
	echo "[modloader] Silenced, using logging." 1>$basedir/tmp/mods.log
	echo -e "[modloader] Preloading Functions (mod_aload.bash)...\c" 1>>$basedir/tmp/mods.log 2>>$basedir/tmp/mods.log
	source $basedir/mod/mod_aload.bash mod_loader 1>>$basedir/tmp/mods.log 2>>$basedir/tmp/mods.log
fi

echo "[modloader] Started $( date +%T)." 1>>$basedir/tmp/mods.log
for mod in $basedir/mod/mod_**.bash
do
	## $MOD is full path base_dir not needed.
	if [ ! "$mod" == "$basedir/mod/mod_aload.bash" ]; then
		export os_mod=$(cat $mod | grep -m 1 '# MOD_OS:' | awk '{ print $3 }')
		if [ "$os_mod" == "" ]; then
			export os_mod="all"
		fi
		if [ "$1" == "--verbose" ]; then
			echo -e "Loading $(cat $mod | grep -m 1 '# MOD_NAME:' | awk '{ print $3 }')...\c"
			if [ "$os_mod" == "$os" ]; then
				source $mod mod_loader
			elif [ "$os_mod" == "all" ]; then
				source $mod mod_loader
			else
				echo "ERR:WRONG_OS"
			fi
		else
			echo -e "[modloader] Loading $(cat $mod | grep -m 1 '# MOD_NAME:' | awk '{ print $3 }')...\c" 1>>$basedir/tmp/mods.log 2>>$basedir/tmp/mods_error.log
			if [ "$os_mod" == "$os" ]; then
				source $mod mod_loader 1>>$basedir/tmp/mods.log 2>>$basedir/tmp/mods_error.log
			elif [ "$os_mod" == "all" ]; then
				source $mod mod_loader 1>>$basedir/tmp/mods.log 2>>$basedir/tmp/mods_error.log
			else
				echo "ERR:WRONG_OS" 1>>$basedir/tmp/mods.log
			fi
		fi
	
	fi
done

echo "[modloader] Finished $( date +%T)." 1>>$basedir/tmp/mods.log

echo "OK"
