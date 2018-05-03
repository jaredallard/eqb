#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_cfg
# MOD_AUTHOR: Jared Allard <jaredallard@outlook.com>
# MOD_VERSION: 1.0-dev
# MOD_DESC: Uses classic cfg system "name=value". Redesigned from (unpublished) BTP.
# MOD_UPDATE_LINK: http://rainbowdashdc.github.io/rrpg/mod_cfg.txt
# MOD_UPDATE_TYPE: MANUAL
##########################
export enabled="yes"    #
##########################
if [ ! "$enabled" == "yes" ]; then
	echo "ERR:DISABLED"
	return
fi

function parse_cfg {
	local file="$1"
	local name="$2"

	if [[ ! -e "$file" ]]; then
		error "File not found. ($file)"
		return
	fi

	if [[ -z "$name" ]]; then 
		error "Missing param name."
		return;
	fi

	local value=$(grep -E "^$2=" "$1" | sed "s/^$2=//")

	if [[ -z "${value}" ]]; then
		error "value not found"
		return
	fi

	echo "[parse_cfg] $2 was set from $1" >> "$basedir/tmp/mods.log"
	declare -x "$name"="$value"
	echo "[parse_cfg] ${!name}" >> "$basedir/tmp/mods.log"
}

if [ "$1" == "mod_loader" ]; then
	echo "OK"
fi
