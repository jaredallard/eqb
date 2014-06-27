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
		if [ "$1" == "--verbose" ]; then
			echo -e "Loading $(cat $mod | grep -m 1 '# MOD_NAME:' | awk '{ print $3 }')...\c"
			source $mod mod_loader
		else
			echo -e "[modloader] Loading $(cat $mod | grep -m 1 '# MOD_NAME:' | awk '{ print $3 }')...\c" 1>>$basedir/tmp/mods.log 2>>$basedir/tmp/mods_error.log
			source $mod mod_loader 1>>$basedir/tmp/mods.log 2>>$basedir/tmp/mods_error.log
		fi
	
	fi
done
echo "[modloader] Finished $( date +%T)." 1>>$basedir/tmp/mods.log

echo "OK"
