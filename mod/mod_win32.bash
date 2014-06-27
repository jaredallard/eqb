#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_win32
# MOD_AUTHOR: RainbowDashDC
# MOD_VERSION: 1.0-dev
# MOD_DESC: Windows specific fixes can go here.
# MOD_OS: win32

if [ "$1" == "mod_loader" ]; then
	echo "OK"
fi

function change_ansi {
	if [ "$1" == "on" ]; then
		echo "Err: ANSI coloring isn't supported on Windows right now."
	elif [ "$1" == "off" ]; then
		echo "off" > $basedir/config/ansi.txt
	else
		cecho "Input Not Recognized. (Case Sensitive)" red && slow_return_menu
	fi
}

write_output win32 "Overwriting ANSI settings to off"
echo "off" > $basedir/config/ansi.txt