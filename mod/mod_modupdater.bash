#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_modupdater
# MOD_AUTHOR: RainbowDashDC
# MOD_DESC: Updates Modules.
# MOD_VERSION: 1.1-dev
# MOD_UPDATE_LINK: http://rainbowdashdc.github.io/rrpg/
# MOD_UPDATE_TYPE: MANUAL
##########################
export enabled="no"    #
##########################
if [ ! "$enabled" == "yes" ]; then
	echo "ERR:DISABLED"
	return
fi

load_mod xml
load_mod cfg

for mod in mod/mod_**.bash
do
	export updater_type="$(cat $mod | grep '# MOD_UPDATE_TYPE:' | awk '{ print $3 }')"
	export updater_link="$(cat $mod | grep '# MOD_UPDATE_LINK:' | awk '{ print $3 }')"
	export prog_ver="$(cat $mod | grep '# MOD_VERSION:' | awk '{ print $3 }')"
	export prog_name="$(cat $mod | grep '# MOD_NAME:' | awk '{ print $3 }')"

	if [ "$updater_type" == "XML" ]; then
		wget -q -O tmp/mod_modupdater.xml "$updater_link"

		parse_xml "mod_modupdater" version > tmp/parse.tmp

		export xml_res="$(cat tmp/parse.tmp)"
	
		if [ ! "$xml_res" == "$prog_ver" ]; then
			echo "$prog_name Outdated."
		fi
	elif [ "$updater_type" == "CFG" ]; then
		wget -q -O tmp/mod_modupdater.cfg "$updater_link"
		
		parse_cfg "mod_modupdater"
	elif [ "$updater_type" == "TXT" ]; then
		wget -q -O tmp/mod_modupdater.txt "$updater_link"
		
		export txt_res="$(cat tmp/mod_modupdater.txt)"
		
		if [ ! "$txt_res" == "$prog_ver" ]; then
			echo "$prog_name Outdated."
		fi
	fi
		
done

if [ "$1" == "mod_loader" ]; then
	echo "OK"
fi
