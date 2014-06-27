#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_cfg
# MOD_AUTHOR: RainbowDashDC
# MOD_VERSION: 1.0-dev
# MOD_DESC: Uses classic cfg system "name=value". Redesigned from (unpublished) BTP.
# MOD_UPDATE_LINK: http://rainbowdashdc.github.io/rrpg/mod_cfg.txt
# MOD_UPDATE_TYPE: TXT
##########################
export enabled="yes"    #
##########################
if [ ! "$enabled" == "yes" ]; then
	echo "ERR:DISABLED"
	return
fi

function parse_cfg {
	## $1 = Config File.
	## $2 = Regex. (Is set as regex name.)
	if [ "$1" == "" ]; then
		error "no config file specified."
		return
	elif [ ! -e "$1" ]; then
		error "config file not found."
		return
	fi
	if [ "$2" == "" ]; then
		error "no regex value specified."
		return
	fi
	if [ ! "$3" == "--no-manifest" ]; then
		if [ ! "$(head $1 -n 1)" == "#RRPG_MANIFEST" ]; then
			error "expecting 'RRPG_MANIFEST' since line #1"
			return
		fi
	fi

	if [ -e "$basedir/tmp/parse" ]; then
			rm -rf "$basedor/tmp/parse"
	fi
	cat $1 | grep -E "^$2=" | awk -F "=" '{ print $2 }' > $basedir/tmp/parse
	if [ "$(cat $basedir/tmp/parse)" == "" ]; then
			error "value not found"
	fi
	export $2=$(cat $basedir/tmp/parse)
	echo "[parse_cfg] $2 was set from $1" 1>>$basedir/tmp/mods.log
}

if [ "$1" == "mod_loader" ]; then
	echo "OK"
fi
