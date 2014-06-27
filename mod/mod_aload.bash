#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_functions
# MOD_AUTHOR: RainbowDashDC
# MOD_DESC: Provides useful functions for mods. (GLOBALLY) (Loaded at begining.)
# MOD_VERSION: 1.2-dev
# MOD_UPDATE_LINK: http://rainbowdashdc.github.io/rrpg/mod_aload.xml
# MOD_UPDATE_TYPE: XML
# MOD_NOTE: Since this loaded at the begining of the mod_loader, (always) you can
#           theoretiocally replace any of these functions with another mod. Thus allowing
#           custom prompts, ansi echoing, and more.
##########################
export enabled="yes"    #
##########################
if [ ! "$enabled" == "yes" ]; then
	echo "ERR:DISABLED"
	return
fi


## MOD RELATED FUNCTIONS
function load_mod {
	if [ ! -e "$basedir/mod/mod_$1.bash" ]; then
		write_output load_mod "MOD_NOT_FOUND EXCEPTION."
		return 1
	fi
	source $basedir/mod/mod_$1.bash
}

function error {
	if [ "$1" == "" ]; then
		echo "[func_error] ERROR: No Input provided." 1>>$basedir/tmp/mods.log
		return 1
	fi
	depends mod_cecho
	# Error wrapper. mod_cecho is provided with afunc.
	cecho "ERR: $1" red
}

function write_output {
	## Intended for Module Reporting.
	# $1 = Module Name "$2"= Information
	if [ "$verbose" == "" ]; then
		if [ ! "$1" == "sl" ]; then
			echo -e "[$1] $2" 1>>$basedir/tmp/mods.log
		else
			echo -e "$2" 1>>$basedir/tmp/mods.log
		fi
	else
		if [ ! "$1" == "sl" ]; then
			echo -e "[$1] $2"
		else
			echo -e "$2"
		fi
	fi
}

function unload_mod {
	local function_to_reset="$1"
	if [ ! -z "$2" ]; then
		local function="$2"
	fi
	echo '#!/bin/bash' 1>tmp/func_reset.bash
	if [ ! -e "$basedir/mods/mod_$function_to_reset.bash" ]; then
		error "$function_to_reset module not found."
		return
	fi
	for mod in $(cat $basedir/mods/mod_$function_to_reset.bash)
	do
		if [ "$tmp" == "1" ]; then
			if [ ! "$mod" == "|" ]; then
				if [ "$mod" == "$function_to_reset" ]; then
					echo "function $mod {" 1>>$basedir/tmp/func_reset.bash
					echo "	echo 'DERP' 1>/dev/null" 1>>$basedir/tmp/func_reset.bash
					echo "}" 1>>tmp/func_reset.bash
					source tmp/func_reset.bash
				elif [ "$mod" == "$function" ]; then
					echo "function $mod {" 1>>$basedir/tmp/func_reset.bash
					echo "	echo 'Vinyl is best Pony.' 1>/dev/null" 1>>$basedir/tmp/func_reset.bash
					echo "}" 1>>$basedir/tmp/func_reset.bash
					source $basedir/tmp/func_reset.bash
				else
					echo "[unload_mod] $mod not equal to $function_to_reset or $function." 1>>$basedir/tmp/mods.log
				fi
			fi
		fi
		if [ "$mod" == "function" ]; then
			export tmp=1
		else
			export tmp=0
		fi
	done
}

function depends {
	local mod_depended="$1"
	if [ ! -e "$basedir/mod/$1.bash" ]; then
		echo "[depends] Dependency not met: $mod_depended. Check modules." 1>>$basedir/tmp/mods.log
		echo "ERR: Dependency not met: $mod_depended. Check modules."
		return 1
	else
		local tmp=$(cat $basedir/tmp/mods.log | grep "\[depends\] Dependency $mod_depended was met.")
		if [ ! "$tmp" == "[depends] Dependency $mod_depended was met." ]; then
			echo "[depends] Dependency $mod_depended was met." 1>>$basedir/tmp/mods.log
		fi
	fi
}

function change_ansi {
	if [ "$1" == "on" ]; then
		echo "on" > $basedir/config/ansi.txt
	elif [ "$1" == "off" ]; then
		echo "off" > $basedir/config/ansi.txt
	else
		cecho "Input Not Recognized. (Case Sensitive)" red && slow_return_menu
	fi

	cecho "ANSI is now: $ansi_on_or_off" cyan
}



## GAME RELATED FUNCTIONS
function cecho {
	## ANSI SUPPORT.
	local tmp="$(cat $basedir/config/ansi.txt)"
	if [ "$tmp" == "on" ]; then
		cecho_src "$1" "$2"
	else
		echo -e "$1" 
	fi
}

function prompt {
	local username="$(cat $basedir/db/username.txt)"
	export choice=""
	export choice_l=""
	### My Amazing Prompt System. Great, right?
	### NTS. Create AWK system to automate set/get system.
	if [ ! "$1" == "" ]; then
		if [ ! "$3" == "" ]; then
			if [ ! "$5" == "" ]; then
				if [ ! "$7" == "" ]; then
					if [ ! "$9" == "" ]; then
						echo "Options: $1, $3, $5, $7, $9."
					else
						echo "Options: $1, $3, $5, $7."
					fi
				else
					echo "Options: $1, $3, $5."
				fi
			else
				echo "Options: $1, $3."
			fi
		else
			echo "Options: $1."
		fi
	fi

	cecho "$(cat $basedir/home/$username/hp.pwd)\c" red
	echo -e "|\c"
	cecho "$(cat $basedir/db/sp.txt)\c" blue
	echo -e "|\c"
	cecho "$(cat $basedir/db/xp.txt)\c" cyan
	cecho "> \c" magenta
	read choice
	export choice_l="$(echo $choice)"
	if [ ! "$choice_l" == "" ]; then
		echo "" ## This controls wether to add a new-line between command-dialog or not. Remove " > /dev/null" to add one.
	else
		echo "$choice" ## Simple new-line addition for Dialog. Add " > /dev/null" if you want to remove it.
	fi
	export a1="$(echo $choice | awk '{ print $1 }')"
	export a2="$(echo $choice | awk '{ print $2 }')"
	export a3="$(echo $choice | awk '{ print $3 }')"
	if [ "$a1" == "exit" ]; then
		echo "Until Next Time..."
		exit
	elif [ "$choice" == "save" ]; then
		echo "E: Save is deprecated."
		echo "	- See Github ISSUE #2"
	elif [ "$a1" == "?" ]; then
		if [ "$a2" == "sp" ]; then
			echo "Skill Points."
			echo "	Skill Points determine your ability to do certain functions,"
			echo "	Throught the game. They are obtained by 'leveling up'."
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		elif [ "$a2" == "xp" ]; then
			echo "eXPerience Points."
			echo "	Expirence Points dictate when you level-up. They are gained by;"
			echo "	Quests, Battles, and other miscilanious tasks."
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		elif [ "$a2" == "hp" ]; then
			echo "Health Points."
			echo "	Health Points determine the amount of damage you can take before"
			echo "	'death'. They can be increased by potions, magic, and certain skills."
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		elif [ "$a2" == "" ]; then
			echo "USAGE: ? [sp, xp, hp]"
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		fi
	elif [ "$a1" == "set" ]; then
		if [ "$a2" == "text-speed" ]; then
			if [ "$a3" == "" ]; then
				echo "USAGE: set text-speed [seconds]"
				prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
			else
				echo "$a3" > "$basedir/config/text_speed.txt"
				prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
			fi
		elif [ "$a2" == "" ]; then
			echo "USAGE: set [SETTING] [VALUE]"
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		elif [ "$a2" == "ansi" ]; then
			if [ "$a3" == "" ]; then
				echo "USAGE: set ansi [on/off]"
				prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
			elif [ "$a3" == "on" ]; then
				echo "on" > $basedir/config/ansi.txt
				prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
			elif [ "$a3" == "off" ]; then
				echo "off" > $basedir/config/ansi.txt
				prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
			else
				echo "USAGE: set ansi [on/off]"
				echo "E: Input was invaild."
				prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
			fi
		else
			echo "USAGE: set [SETTING] [VALUE]"
			echo "E: Setting Not Found."
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		fi
	elif [ "$a1" == "get" ]; then
		if [ "$a2" == "hp" ]; then
			local username="$(cat $basedir/db/username.txt)"
			cat $basedir/home/$username/hp.pwd
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		elif [ "$a2" == "xp" ]; then
			## TEMP
			echo "$xp"
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		elif [ "$a2" == "sp" ]; then
			echo "$sp"
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		elif [ "$a2" == "" ]; then
			echo "USAGE: get [value]"
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		else
			echo "USAGE: get [value]"
			echo "E: Value not Found."
			prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
		fi
	elif [ "$choice" == "$1" ]; then
		$2
	elif [ "$choice" == "$3" ]; then
		$4
	elif [ "$choice" == "help" ]; then
		echo "Avaiable Commands [General]:"
		echo "	exit, no-save"
		echo "	?, sp xp hp"
		echo "	get, hp sp xp quest"
		echo "	set, text-speed ansi"
		echo "- Scene Specific -"
		if [ ! "$1" == "" ]; then 
			echo "	$1"
		fi
		if [ ! "$3" == "" ]; then 
			echo "	$3"
		fi
		prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
	elif [ "$choice" == "" ]; then
		echo ""
	else
		echo "Command Not Found."
		prompt "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
	fi
}

function save_exit {
	## Can't save in-between levels. (No Entry point.)
	echo "Returning to menu..." && sleep 1
	exit
}

function error_exit {
	cecho "$*" red
	exit
}

function slow {
	## Makes text read-able. Can be Adjusted.
	export speed="$(cat $basedir/config/text_speed.txt)"
	sleep $speed
}

function secho {
	## Makes it easier to use 'slow'.
	echo "$1" && slow
}

function level {
	clear
	########################################################
	## USAGE: level [level] [xp] [ig_level]
	##
	cecho "Loading Level \c" cyan && cecho "$1\c" magenta && cecho "...\c" cyan
	_read rrpg_main "$(cat $basedir/db/username.txt)" > /dev/null

	export sp="$(cat $basedir/db/sp.txt)"
	export l="$(cat $basedir/db/level.txt)"
	export xp="$(cat $basedir/db/xp.txt)"
	export username="$(cat $basedir/db/username.txt)"
	export gender="$(cat $basedir/db/gender.txt)"
	export class="$(cat $basedir/db/class.txt)"
	export difficulty="$(cat $basedir/home/$username/diff.pwd)"
	export ig_level="$(cat $basedir/db/ig_level.txt)"

	if [ "$2" -gt "$xp" ]; then
		export xp="$2"
	elif [ "$3" -gt "$ig_level" ]; then
		export ig_level="$3"
	elif [ "$2" -lt "$xp" ]; then
		export xp "$2"
	elif [ "$3" -lt "$ig_level" ]; then
		### Just incase you lose a level somehow.
		export ig_level="$ig_level"
	fi
	## Check if able to level up.
	bash $basedir/content/rrpg_level.bash "$difficulty" "$l" "$xp" 2> $basedir/tmp/errors

	## REASSIGN SP, SINCE LEVEL COULD'VE MODFIYED IT.
	export sp="$(cat $basedir/db/sp.txt)"

	## Write Data.
	_write $username $1 $xp $sp $class $gender $ig_level rrpg_main  > /dev/null

	cecho "OK" green
	sleep 1 ## Wait since it loads damn to fast.
	$1
}

function mask_input {
	local replace_string=$1
	printf "%0.s*" $(seq 1 ${#replace_string})
}

function open {
	## SETS GAME VARIABLES.
	export xp="$(cat $basedir/db/xp.txt)"
	export sp="$(cat $basedir/db/sp.txt)"
	export lvl="$(cat $basedir/db/level.txt)"
	export username="$(cat $basedir/db/username.txt)"
	export hp="$(cat $basedir/home/$username/hp.pwd)"
	export ig_level="$(cat $basedir/db/ig_level.txt)"
}

function enter_content {
	$1
}

function rrpg_main {
	## GLOBAL LOGO CONTROL, and COLOR.
	cecho "============================================" cyan
	cecho "=                   RRPG                   =" cyan
	cecho "============================================" cyan
}


echo "OK"
