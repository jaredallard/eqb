#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_cp
# MOD_AUTHOR: Jared Allard <jaredallard@outlook.com>
# MOD_DESC: Parsers Content ZIPS, and setups env too use them.
# MOD_NOTES: Returns ERR-CODE 1 for any errors.
# MOD_VERSION: 1.0-dev
# MOD_UPDATE_TYPE: MANUAL

function check_integrity {
	if [ "$1" == "" ]; then
		cecho "USAGE: check_integrity /path/" red
		return  1
	elif [ "$1" == "--help" ]; then
		cecho "USAGE: check_integrity /path/" red
		return
	fi
	
	## Check DIR.
	if [ ! -e "$basedir/content/$1/" ]; then
		cecho "ERR: Directory not found. [$basedir/content/$1/]" redc
		return 1
	fi
	
	## Check Integ.
	if [ ! -e "$basedir/content/$1/info" ]; then
		cecho "ERR: Info Directory not found." red
		return 1
	fi
	if [ ! -e "$basedir/content/$1/init" ]; then
		cecho "ERR: Init directory not found." red
		return 1
	fi
	if [ ! -e "$basedir/content/$1/levels" ]; then
		cecho "ERR: Levels directory not found." red
		return 1
	fi
	if [ ! -e "$basedir/content/$1/includes" ]; then
		cecho "ERR: Includes directory not found." red
		return 1
	fi
	if [ ! -e "$basedir/content/$1/sounds" ]; then
		cecho "ERR: Sounds directory not found." red
		return 1
	fi
	
	## Check Manifest.
	if [ ! -e "$basedir/content/$1/info/manifest" ]; then
		cecho "ERR: Manifest file not found." red
		return 1
	fi
	# TODO: Put scan manifest here.
	if [ -e "$basedir/content/$1/info/info" ]; then
		depends mod_cfg 2>/dev/null || error_exit "ERR: CFG module not available? Reinstall."
		parse_cfg "$basedir/content/$1/info/info" "version"
		parse_cfg "$basedir/content/$1/info/info" "name"
		parse_cfg "$basedir/content/$1/info/info" "author"
		parse_cfg "$basedir/content/$1/info/info" "homepage"
	else
		cecho "ERR: No INFO file found." red
		return 1
	fi
	## Return.
	return
}

function load_cp {
	if [ "$1" == "" ]; then
		cecho "ERR: No CP specified. ERR_NO_INPUT_\$1" red
		return 1
	elif [ ! -e "$basedir/content/$1" ]; then
		cecho "ERR: Content Pack doesn't exist." red
		return 1
	fi
	cecho "Extracting Content Pack $1...\c" cyan
	if [ -e "$basedir/content/loaded" ]; then
		rm -rf "$basedir/content/loaded"
	fi
	mkdir "$basedir/content/loaded" 1>/dev/null || echo "ERR: Couldn't create loaded directory. No Perms?" 
	chmod 777 "$basedir/content/loaded"
	unzip "$basedir/content/$1" -d "$basedir/content/loaded" 1>/dev/null 2>/dev/null
	cecho "OK" green
	cecho "Checking Integrity of loaded content pack...\\c" cyan
	check_integrity "loaded" || return 1
	cecho "OK" green
}

if [ "$1" == "mod_loader" ]; then
	echo "OK"
fi
