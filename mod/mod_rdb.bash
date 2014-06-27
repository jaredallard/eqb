#!/bin/bash
#
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_rdb
# MOD_AUTHOR: RainbowDashDC
# MOD_VERSION: 1.3.4-dev
# MOD_DESC: Text-Based database system for RRPG.
# MOD_UPDATE_LINK: http://rainbowdashdc.github.io/rrpg/mod_rdb.txt
# MOD_UPDATE_TYPE: MANUAL
##########################
export enabled="yes"    #
##########################
if [ ! "$enabled" == "yes" ]; then
	echo "ERR:DISABLED"
	return
fi

function _init {
	if [ "$1" == "" ]; then
		echo USAGE: _init [db]
		return
	fi
	export db_version="1.4"
	rm "$basedir/db/$1.rdb" 2> /dev/null
	echo -n "Creating Database..."
	echo "# Version: $db_version" > "$basedir/db/$1.rdb"
	echo "## USERNAME    LEVEL    XP   SP  CLASS   GENDER  IG_LEVEL" >> "$basedir/db/$1.rdb"
	echo "..............................[ OK ]"
}

function _init_new_user {
	echo -n "Writing to Database..."
	echo "$1 $2 $3 $4 $5 $6 $7" >> $basedir/db/$8.rdb
	echo "............................[ OK ]"
}

function _clean {
	echo -n "Cleaning Database..."
	rm -rf $basedir/db/*.txt
	echo "..............................[ OK ]"
}
function _read {
	# $1 == Database. $2 == Username.
	if [ "$1" == "" ]; then
		echo USAGE: _read [db] [username]
		return
	elif [ "$2" == "" ]; then
		echo USAGE: _read [db] [username]
		return
	fi
	echo -n "Reading/Extracting Database..."
	rm $basedir/db/*.txt 2> /dev/null
	cat "$basedir/db/$1.rdb" | grep "$2" | awk '{ print $1 }' > "$basedir/db/username.txt"
	cat "$basedir/db/$1.rdb" | grep "$2" | awk '{ print $2 }' > "$basedir/db/level.txt"
	cat "$basedir/db/$1.rdb" | grep "$2" | awk '{ print $3 }' > "$basedir/db/xp.txt"
	cat "$basedir/db/$1.rdb" | grep "$2" | awk '{ print $4 }' > "$basedir/db/sp.txt"
	cat "$basedir/db/$1.rdb" | grep "$2" | awk '{ print $5 }' > "$basedir/db/class.txt"
	cat "$basedir/db/$1.rdb" | grep "$2" | awk '{ print $6 }' > "$basedir/db/gender.txt"
	cat "$basedir/db/$1.rdb" | grep "$2" | awk '{ print $7 }' > "$basedir/db/ig_level.txt"
	echo "....................[ OK ]"
}

function _write {
	if [ "$1" == "" ]; then
		echo "USAGE: _write [username] [level] [xp] [skill_points] [class] [gender] [diff] [db]"
		return
	elif [ "$2" == "" ]; then
		echo "USAGE: _write [username] [level] [xp] [skill_points] [class] [gender] [diff] [db]"
		return
	elif [ "$3" == "" ]; then
		echo "USAGE: _write [username] [level] [xp] [skill_points] [class] [gender] [diff] [db]"
		return
	elif [ "$4" == "" ]; then
		echo "USAGE: _write [username] [level] [xp] [skill_points] [class] [gender] [diff] [db]"
		return
	elif [ "$5" == "" ]; then
		echo "USAGE: _write [username] [level] [xp] [skill_points] [class] [gender] [diff] [db]"
		return
	elif [ "$6" == "" ]; then
		echo "USAGE: _write [username] [level] [xp] [skill_points] [class] [gender] [diff] [db]"
		return
	elif [ "$7" == "" ]; then
		echo "USAGE: _write [username] [level] [xp] [skill_points] [class] [gender] [diff] [db]"
		return
	fi
	echo -n "Writing to Database..."
	cat $basedir/db/$8.rdb | grep -n "$1" | awk -F ":" '{ print $1 }' > $basedir/tmp/ln
	export ln="$(cat $basedir/tmp/ln)"
	perl -pe "s/.*/$1 $2 $3 $4 $5 $6 $7/ if $. == $ln " > $basedir/tmp/$8.tmp < $basedir/db/$8.rdb
	mv $basedir/tmp/$8.tmp $basedir/db/$8.rdb
	echo "............................[ OK ]"
}

function _destroy {
	if [ "$1" == "" ]; then
		echo USAGE: _destroy [database_name]
		return
	fi
	echo -n "Removing Datbase..."
	rm "$basedir/db/$1.rdb"
	echo "...............................[ OK ]"
}

function _backup {
	if [ "$1" == "" ]; then
		echo USAGE: _backup [database_name]
		return
	fi
	echo -n "Backing up Database..."
	cp "$basedir/db/$1.rdb" "$basedir/db/$1.rdb.bk"
	echo "............................[ OK ]"
}

function _restore {
	if [ "$1" == "" ]; then
		echo USAGE: _restore [database_name]
		return
	fi
	echo -n "Restoring Database..."
	rm "db/$1.rdb"
	cp "$basedir/db/$1.rdb.bk" "$basedir/db/$1.rdb"
	echo ".............................[ OK ]"
}

function mod_rdb-help {
	echo "RDC (C) 2013 RRPG-RDB"
	echo ""
	echo "DESC: RDB, DATABASE."
	echo "USAGE: ./db/rdb.sh [function] [arguments]"
	echo ""
	echo "Functions:"
	echo "	--help                       Help Page."
	echo "	_read                        Read Database."
	echo "	_destroy                     Remove Database."
	echo "	_init                        Create Database."
	echo "	_write                       Write to Database."
	echo "	_backup                      Backup Database."
	echo "	_restore                     Restore Database."
	echo ""
	echo "Email Bug Reports to <allardj64@gmail.com>"
}

if [ "$1" == "mod_loader" ]; then
	echo "OK"
fi
