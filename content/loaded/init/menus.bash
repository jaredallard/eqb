#!/bin/bash
function content_pack_menu {
	clear
	rrpg_main
	echo ""
	cecho "Content Pack Information" cyan
	cecho "========================" cyan
	cecho "Name: $name" green
	cecho "Author: $author" green
	cecho "Version: $version" green
	cecho "Homepage: $homepage" green
	cecho "========================" cyan
	if [ -e "$basedir/content/loaded/init/cust.bash" ]; then
		source "$basedir/content/loaded/init/cust.bash"
	fi
	echo ""
	cecho "Press any key to return to menu.\c" magenta
	read tmp_var_nobody_cares_about
	
	return
}

function new_game {
	# NOTE: Want to use color'd prompts?
	# Use this format:
	# cecho "whatever?\c" [color]
	# read [variables]
	clear
	if [ -e "$basedir/db/rrpg_main.rdb" ]; then
		cecho "ARE YOU SURE YOU WANT TO START A NEW GAME? [Y/n]: \c" red
		read chc
		if [ ! "$chc" == "Y" ]; then
			if [ ! "$chc" == "y" ]; then
				slow_return_menu --no-init-sleep
			fi
		fi
		clear
	fi
	rrpg_main
	cecho "= New Game =" magenta
	cecho "============" magenta
	cecho "Username: \c" green
	read username
	cecho "Password: \c" green
	read -s pass
	echo ""
	cecho "Confirm Password: \c" green
	read -s passconf
	echo ""
	cecho "Class [Pegasus/Unicorn/Earth]: \c" green
	read class
	cecho "Gender [Male/Female]: \c" green
	read gender
	cecho "Difficulty [1/2/3/4]: \c" green
	read difficulty
	cecho "Species: Pony" green
	echo ""

	cecho "Checking Input...\c" cyan
	if [ ! "$pass" == "$passconf" ]; then
		cecho "FAIL" red && cecho "ERR: Password Doesn't Match Confirm Password." red && slow_return_menu
	elif [ ! "$gender" == "Male" ]; then
		if [ ! "$gender" == "Female" ]; then
			if [ "$gender" == "male" ]; then
				export gender="Male"
			elif [ "$gender" == "female" ]; then
				export gender="Female"
			else
				cecho "FAIL" red && cecho "ERR: Gender Input Invalid." red && slow_return_menu
			fi
		fi
	elif [ ! "$class" == "Pegasus" ]; then
		if [ ! "$class" == "Unicorn" ]; then
			if [ ! "$class" == "Earth" ]; then
				if [ ! "$class" == "pegasus" ]; then
					if [ ! "$class" == "unicorn" ]; then
						if [ ! "$class" == "earth" ]; then
							cecho "FAIL" red && cecho "ERR: Class Input Invalid." red && slow_return_menu
						else
							class="Earth"
						fi
					else
						class="Unicorn"
					fi
				else
					class="Pegasus"
				fi
			fi
		fi
	elif [ "$difficulty" -gt 0 ]; then
		if [ ! "$difficulty" -lt 5 ]; then
			cecho "FAIL" red && cecho "ERR: Difficulty Input Invaild." red && slow_return_menu
		fi
	elif [ "$difficulty" -lt 5 ]; then
		if [ ! "$difficulty" -gt 0 ]; then
			cecho "FAIL" red && cecho "ERR: Difficulty Input Invaild." red && slow_return_menu
		fi
	fi
	cecho "OK" green
	
	cecho "Checking Database state...\c" cyan
	if [ ! -e "$basedir/db/rrpg_main.rdb" ]; then
		# INIT database and write info.	
		_init rrpg_main 1>/dev/null
		_clean 1>/dev/null
	else
		cat $basedir/db/rrpg_main.rdb | grep "$username" 1>/dev/null && cecho "FAIL\nERR: User already exists. [$username]" red && slow_return_menu
	fi
	cecho "OK" green

	cecho "Creating Home Directory of user...\c" cyan
	if [ ! -e "$basedir/home/$username" ]; then
		mkdir $basedir/home/$username
		cecho "OK" green
	else
		cecho "FAIL-EXISTS" red
	fi
	
	cecho "Hashing Password...\c" cyan
	echo "$passconf" > "$basedir/db/temp_password.txt"
	export passhash="$(md5sum $basedir/db/temp_password.txt | awk '{print $1 }')"
	if [ ! "$passhash" == "$(md5sum $basedir/db/temp_password.txt | awk '{print $1 }')" ]; then
		cecho "FAIL" red && cecho "ERR: Generated Password didn't match Password gen in variable. WTF Moment. Rerun." red && slow_return_menu
	else
		echo "$passhash" > "$basedir/home/$username/password.pwd"
	fi
	rm -rf "$basedir/db/temp_password.txt"
	cecho "OK" green

	cecho "Generating Health...\c" cyan
	rm -rf $basedir/db/health.pwd $basedir/home/$username/hp.pwd $basedir/db/hp.pwd
	echo "100" > "$basedir/home/$username/hp.pwd"
	cecho "OK" green

	cecho "Generating Difficulty...\c" cyan
	rm -rf $basedir/home/$username/diff.pwd
	echo "$difficulty" > "$basedir/home/$username/diff.pwd"
	cecho "OK" green

	cecho "Generating Default Settings...\c" cyan
	echo "1" > "$basedir/home/$username/text_speed.txt"
	cecho "OK" green

	echo ""
	cecho "Creating Database, and writing information." cyan
	sleep 1
	cecho "-------------------[ Database Dialog ]-------------------" magenta
	# INIT has been moved to allow multi-user support.
	#               USERNAME LVL XP SP CLASS GENDER IL DATABASE
	_init_new_user $username 1_1 0 0 $class $gender 0 rrpg_main
	_read rrpg_main $username
	cecho "-------------------[    End Dialog   ]-------------------" magenta

	cecho "Generating Skills (This May Take Awhile)...\c" cyan
	bash $basedir/content/rrpg_skill.bash --generate
	cecho "OK" green

	sleep 1
	echo ""
	cecho "Finished [@$(date | awk '{ print $4 }')]" cyan
	sleep 1
	enter_content "bash $basedir/content/rrpg_content.bash $(cat $basedir/db/level.txt)"
}

function debug_menu {
	clear
	rrpg_main
	cecho "                             = Debug Menu  =" magenta
	cecho "                             ===============" magenta
	echo ""
	cecho "1. Show Database" cyan
	cecho "2. Parse/Show Database." cyan
	cecho "3. Destory Database." cyan
	cecho "4. Show Modloader log." cyan
	cecho "5. Clean db/." cyan
	cecho "6. List Users" cyan
	cecho "7. Clean home/." cyan
	cecho "8. Return." cyan
	echo ""
	cecho "Selection [#]: \c" magenta
	read choice
	if [ "$choice" == "1" ]; then
		clear
		cecho "RRPG_MAIN.RDB" blue
		if [ ! -e "$basedir/db/rrpg_main.rdb" ]; then
			cecho "\nERR: Database wasn't found.\n" red && slow_return_menu
		else
			cat "$basedir/db/rrpg_main.rdb"
		fi
		echo ""
		cecho "EOF" blue
		echo ""
		cecho "Press any key to return.\c" magenta
		read tmp_var_nobody_cares_about
		debug_menu
	elif [ "$choice" == "2" ]; then
		clear
		read -p "Username: " username
		if [ ! -e "$basedir/home/$username" ]; then
			cecho "ERR:\nUSER Not Found." red && slow_return_menu
		else
			_read rrpg_main $username 1> /dev/null
			echo "PARSED RRPG_MAIN.RDB"
			echo -n "Username: " && cat $basedir/db/username.txt
			echo -n "Level: " && cat $basedir/db/level.txt
			echo -n "Gender: " && cat $basedir/db/gender.txt
			echo -n "Class: " && cat $basedir/db/class.txt
			echo -n "XP: " && cat $basedir/db/xp.txt
			echo -n "Skill Points: " && cat $basedir/db/sp.txt
			echo -n "Difficulty: " && cat "$basedir/home/$username/diff.pwd"
			echo -n "InGame Level: " && cat $basedir/db/ig_level.txt
			echo ""
			read -p "EOF"
		fi
		debug_menu
	elif [ "$choice" == "3" ]; then
		cecho "DATABASE DIALOG:" blue
		_destroy rrpg_main
		cecho "END" blue
		echo ""
		cecho "Press any key to return to the menu.\c" magenta
		read tmp_var_nobody_cares_about
		debug_menu
	elif [ "$choice" == "4" ]; then
		clear
		cecho "==============[MODLOADER LOG]===============" blue
		echo ""
		cat $basedir/tmp/mods.log
		cecho "===================[EOF]====================" blue
		echo ""
		cecho "Press any key to return.\c" magenta
		read tmp_var_nobody_cares_about
		debug_menu
	elif [ "$choice" == "5" ]; then
		cecho "Cleaning up db/...\c" cyan
		rm -rf $basedir/db/* 2>/dev/null
		cecho "OK" green
		sleep 1.5
		debug_menu
	elif [ "$choice" == "6" ]; then
		cecho "==================[USERS]===================" blue
		ls $basedir/home
		cecho "============================================" blue
		echo ""
		cecho "Press any key to continue\c" magenta
		read tmp_var_nobody_cares_about
		debug_menu
	elif [ "$choice" == "7" ]; then
		cecho "Cleaning up home/...\c" cyan
		rm -rf $basedir/home/* 2>/dev/null
		cecho "OK" green
		sleep 1.5
		debug_menu
	elif [ "$choice" == "8" ]; then
		return
	fi
	return
}

function slow_return_menu {
	if [ ! "$1" == "--no-init-sleep" ]; then
		read -t 2 tmp_var_nobody_cares_about
		cecho "Returning..." red
		read -t 2 tmp_var_nobody_cares_about
		menu
	else
		cecho "Returning..." red
		read -t 2 tmp_var_nobody_cares_about
		menu
	fi
}

function continue_game {
	clear
	rrpg_main
	cecho "           = Continue Game =" magenta
	cecho "           =================" magenta
	cecho "Username: \c" green
	pushd $basedir/home 1>/dev/null
	read -e username
	popd >/dev/null
	cecho "Password: \c" green
	read -s password
	echo ""

	# Remove Trailing Slash from "autocomplete"
	username=${username%/}

	cecho "Checking if User exists...\c" cyan
	if [ "$username" == "" ]; then
			cecho "FAIL\nERR: Username field blank." red && slow_return_menu
	elif [ ! -e "$basedir/home/$username" ]; then
		cecho "FAIL\nERR: User Not Found." red && slow_return_menu
	fi
	cecho "OK" green

	cecho "Checking Credentials...\c" cyan
	echo "$password" > "$basedir/tmp/temp_password.txt"
	export passhash="$(md5sum $basedir/tmp/temp_password.txt | awk '{print $1 }')"
	export passhash2="$(cat $basedir/home/$username/password.pwd)"
	if [ "$passhash" == "$passhash2" ]; then
		cecho "GOOD" green
		rm -rf "$basedir/tmp/temp_password.txt"
	else
		cecho "FAIL\nInvalid Password." red && slow_return_menu
	fi

	echo ""
	cecho "Checking Database, and restoring game state..." cyan
	sleep 1
	cecho "-------------------[ Database Dialog ]-------------------" blue
	_clean
	_read rrpg_main $username
	cecho "-------------------[    End Dialog   ]-------------------" blue
	echo ""
	sleep 1
	cecho "Finished [@$(date | awk '{ print $4 }')]" cyan
	sleep 1
	enter_content "bash $basedir/content/rrpg_content.bash $(cat $basedir/db/level.txt)"
}

function settings_menu {
	clear
	rrpg_main
	cecho "           = Settings =" magenta
	cecho "           ============" magenta
	echo ""
	cecho "1. Text Speed." cyan
	cecho "2. Change Password." cyan
	cecho "3. ANSI." cyan
	echo ""
	cecho "Selection [#]: \c" magenta
	read choice
	if [ "$choice" == "1" ]; then
		clear
		cecho "Speed [Seconds ($(cat $basedir/config/text_speed.txt))]: \c" cyan
		read speed_to_write
		echo "$speed_to_write" > $basedir/config/text_speed.txt
		cecho "Success!" green && sleep 1
		settings_menu
	elif [ "$choice" == "2" ]; then
		clear	
		cecho "Username: \c" cyan
		read username
		echo ""
		cecho "Checking if User exists...\c" cyan
		if [ "$username" == "" ]; then
			cecho "FAIL\nERR: Username field blank." red && slow_return_menu
		elif [ ! -e "$basedir/home/$username" ]; then
			cecho "FAIL\nERR: User Not Found." red && slow_return_menu
		fi
		cecho "OK" green
		sleep 1.5
		echo ""
		cecho "Current Password: \c" cyan
		read curr_pass
		cecho "New Password: \c" cyan
		read new_pass
		cecho "Confirm Password: \c" cyan
		read conf_pass

		cecho "Checking Credentials...\c" cyan
		echo "$curr_pass" > "$basedir/tmp/temp_password.txt"
		export passhash="$(md5sum $basedir/tmp/temp_password.txt | awk '{print $1 }')"
		export passhash2="$(cat $basedir/home/$username/password.pwd)"
		if [ "$passhash" == "$passhash2" ]; then
			rm -rf "db/temp_password.txt"
			cecho "GOOD" green
			cecho "Hashing New Password...\c" cyan
			echo "$conf_pass" > "$basedir/tmp/temp_password.txt"
			md5sum $basedir/tmp/temp_password.txt | awk '{print $1 }' > "$basedir/home/$username/password.pwd"
			rm -rf "$basedir/tmp/temp_password.txt"
			cecho "OK\n" green && sleep 1 && cecho "Finished [@$(date | awk '{ print $4 }')]" cyan && sleep 1.5 && menu
		else
			cecho "FAIL" red
			cecho "Invalid Password." red && slow_return_menu
		fi
	elif [ "$choice" == "3" ]; then
		clear
		cecho "ANSI [\c" cyan && cecho "on\c" green && cecho "/\c" cyan && cecho "off\c" red && cecho "]: \c" cyan
		read ansi_on_or_off
		change_ansi $ansi_on_or_off
		sleep 1
	fi
			
		
	menu
}