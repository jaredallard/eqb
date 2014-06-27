#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_pyloader
# MOD_AUTHOR: RainbowDashDC
# MOD_VERSION: 1.1-dev
# MOD_DESC: Loads Python Modules.
# MOD_UPDATE_LINK: http://rainbowdashdc.github.io/rrpg/mod_py.txt
# MOD_UPDATE_TYPE: TXT
##########################
export enabled="yes"    #
##########################
if [ ! "$enabled" == "yes" ]; then
	echo "ERR:DISABLED"
	return
fi

if [ "$1" == "mod_loader" ]; then
	echo "OK"
fi

write_output py_modloader "Started $(date +%T)"
for mod2 in $basedir/mod/mod_**.py
do
	if [ ! "$mod2" == "$basedir/mod/mod_**.py" ]; then
		write_output py_modloader "Loading $mod2...\c"
		python $mod2 2>>/dev/null
		write_output sl "OK"
	else
		write_output py_modloader "No Python Modules Found."
	fi
done
write_output py_modloader "Finished $(date +%T)"
