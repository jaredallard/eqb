#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_dos2unix
# MOD_AUTHOR: RainbowDashDC
# MOD_VERSION: 1.0.1-final
# MOD_DESC: Attempts to convert dos line-endings to unix on all modules except itself.
# MOD_OS: win32

for files in $basedir/mod/mod_**.bash
do
	dos2unix $files 2>$basedir/tmp/d2u 1>$basedir/tmp/d2u.2
done

echo "OK"