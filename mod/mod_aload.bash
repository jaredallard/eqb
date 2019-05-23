#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_functions
# MOD_AUTHOR: Jared Allard <jaredallard@outlook.com>
# MOD_DESC: Provides useful functions for mods. (GLOBALLY) (Loaded at begining.)
# MOD_VERSION: 1.2-dev
# MOD_UPDATE_TYPE: MANUAL
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
	source "$basedir/mod/mod_$1.bash"
}

function error {
	if [ "$1" == "" ]; then
		echo "[func_error] ERROR: No Input provided." >>"$basedir/tmp/mods.log"
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
			echo -e "[$1] $2" >">$basedir/tmp/mods.log"
		else
			echo -e "$2" >>"$basedir/tmp/mods.log"
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

	if [[ ! -z "$2" ]]; then
		local function="$2"
	fi

	# Check to make sure the function we're trying to unload exists first.
	if [[ ! -e "$basedir/mods/mod_$function_to_reset.bash" ]]; then
		error "$function_to_reset module not found."
		return
	fi

	echo '#!/usr/bin/env bash' >tmp/func_reset.bash

	for mod in $(cat "$basedir/mods/mod_$function_to_reset.bash"); do
		if [ "$tmp" == "1" ]; then
			if [ ! "$mod" == "|" ]; then
			
				# Skip it if it's not a function we're looking for.
				if [[ "$mod" != "$function_to_reset" ]] && [[ "$mod" != "$function" ]]; then
					echo "[unload_mod] $mod not equal to $function_to_reset or $function." >> "$basedir/tmp/mods.log"
					continue
				fi

				{
					echo "$mod() {"
					echo "	echo 'Vinyl is best Pony.' 1>/dev/null"
					echo "}" 
				} >> "$basedir/tmp/func_reset.bash"

				source "$basedir/tmp/func_reset.bash"
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
	if [[ ! -e "$basedir/mod/$1.bash" ]]; then
		echo "[depends] Dependency not met: $mod_depended. Check modules." >> "$basedir/tmp/mods.log"
		echo "ERR: Dependency not met: $mod_depended. Check modules."
		return 1
	else
		local tmp=$(grep "\\[depends\\] Dependency $mod_depended was met." "$basedir/tmp/mods.log")
		if [[ -z "$tmp" ]]; then
			echo "[depends] Dependency $mod_depended was met." >> "$basedir/tmp/mods.log"
		fi
	fi
}

function change_ansi {
	local choice=$(tr '[:upper:]' '[:lower:]' <<<"$1")

	if [ "$choice" == "on" ]; then
		echo "on" > "$basedir/config/ansi.txt"
	elif [ "$choice" == "off" ]; then
		echo "off" > "$basedir/config/ansi.txt"
	else
		cecho "Input Not Recognized." red && slow_return_menu
	fi

	cecho "ANSI is now: $choice" cyan
}



## GAME RELATED FUNCTIONS
function cecho {
	## ANSI SUPPORT.
	local tmp="$(cat "$basedir/config/ansi.txt")"
	if [ "$tmp" == "on" ]; then
		cecho_src "$1" "$2"
	else
		echo -e "$1"
	fi
}

# shellcheck disable=SC2120
function prompt {
	load_attributes

	export choice=""
	export choice_l=""

	# draw a non-interactive prompt.
	draw_prompt --no-read

	# load the level into the buffer.
	if [[ ! "$1" == "" ]] && [[ ! "$1" == "return" ]]; then
		# load a level
		source "$basedir/content/loaded/levels/$1" 1>/dev/null || error_exit "Err: Failed to load level: '$level'."
		$1
	fi;

	# This blocks, waiting for the user to answer, real prompt.
	draw_prompt


	export a1=$(awk '{ print $1 }' <<<"$choice")
	export a2=$(awk '{ print $2 }' <<<"$choice")
	export a3=$(awk '{ print $3 }' <<<"$choice")
	if [ "$a1" == "exit" ]; then
		# TODO: Clean exit
		exit
	elif [ "$a1" == "redraw" ]; then
		clear
		restore_term
	elif [ "$choice" == "clear" ]; then
		clear
		restore_term
	elif [ "$a1" == "?" ]; then
		if [ "$a2" == "sp" ]; then
			send_output "Skill Points."
			send_output "   Skill Points determine your ability to do certain functions,"
			send_output "   Throught the game. They are obtained by 'leveling up'."

		elif [ "$a2" == "xp" ]; then
			send_output "eXPerience Points."
			send_output "   Expirence Points dictate when you level-up. They are gained by;"
			send_output "   Quests, Battles, and other miscilanious tasks."

		elif [ "$a2" == "hp" ]; then
			send_output "Health Points."
			send_output "   Health Points determine the amount of damage you can take before"
			send_output "   'death'. They can be increased by potions, magic, and certain skills."

		elif [ "$a2" == "" ]; then
			send_output "USAGE: ? [sp, xp, hp]"

		fi
	elif [ "$a1" == "set" ]; then
		if [ "$a2" == "text-speed" ]; then
			if [ "$a3" == "" ]; then
				send_output "USAGE: set text-speed [seconds]"
			else
				send_output "$a3" > "$basedir/config/text_speed.txt"
			fi
		elif [ "$a2" == "" ]; then
			send_output "USAGE: set [SETTING] [VALUE]"
		elif [ "$a2" == "ansi" ]; then
			if [ "$a3" == "" ]; then
				send_output "USAGE: set ansi [on/off]"
			elif [ "$a3" == "on" ]; then
				send_output "Coloring is now ON"
				echo "on" > "$basedir/config/ansi.txt"
			elif [ "$a3" == "off" ]; then
				send_output "Coloring is now OFF"
				echo "off" > "$basedir/config/ansi.txt"
			else
				send_output "USAGE: set ansi [on/off]"
				send_output "E: Input was invaild."
			fi
		else
			send_output "USAGE: set [SETTING] [VALUE]"
			send_output "E: Setting Not Found."
		fi
	elif [ "$a1" == "get" ]; then
		if [ "$a2" == "hp" ]; then
			local username="$(cat "$basedir/db/username.txt")"
			send_output "$(cat "$basedir/home/$username/hp.pwd")"
		elif [ "$a2" == "xp" ]; then
			send_output "$xp"
		elif [ "$a2" == "sp" ]; then
			send_output "$sp"
		elif [ "$a2" == "" ]; then
			send_output "USAGE: get [value]"
		else
			send_output "USAGE: get [value]"
			send_output "E: Value not Found."
		fi
	elif [ "$choice" == "help" ]; then
		send_output "Avaiable Commands [General]:"
		send_output "   exit, no-save"
		send_output "   ?, sp xp hp"
		send_output "   get, hp sp xp quest"
		send_output "   set, text-speed ansi"
		send_output "   clear"
		send_output "   redraw"
	else
		# support user input capturing, when not a builtin
		if [[ ! "$(echo $choice | tr -d '\n')" == "" ]]; then
			send_output "> $choice"
		fi

		echo "$choice" >> "$basedir/home/$username/lastinput.txt"
		return
	fi

	prompt

	# So, we have to be able to handle random input. So, do we loop prompt?
	# i.e "prompt".
	# or do we just RETURN and have the levels handle this
	# We should return and allow the prompt to be looped someother way
}

# get the user's last input
function get_input {
	local input=$(cat "$basedir/home/$username/lastinput.txt")
	local lowercase_input="$(tr -d '\n' <<<"${input,,}")"

	echo "${lowercase_input/ /}"
	echo "" > "$basedir/home/$username/lastinput.txt"
}

## DIALOG MAPPING
function player_thinks {
	send_output "${Cyan}** $*${Reset}"
	tput sgr0
}

function player_says {
	send_output "You say: $*"
}

function description {
	send_output "\\033[3m$*\\033[0m"
	send_output ""
}

function error_exit {
	cecho "$*" red
	exit
}

function slow {
	## Makes text read-able. Can be Adjusted.
	export speed="$(cat "$basedir/config/text_speed.txt")"
	sleep "$speed"
}

function secho {
	## Makes it easier to use 'slow'.
	send_output "$1" && slow
}

# Load things like sp and etc
function load_attributes {
	for file in "$basedir/db/"*.txt; do
		real_name=$(basename "$file" ".txt")
		declare "$real_name"=$(cat "$basedir/db/$real_name.txt")
	done
}


# USAGE: level [level] [xp] [ig_level]
function level {
	clear

	cecho "Loading Level \\c" cyan && cecho "$1\\c" magenta && cecho "...\\c" cyan

	load_attributes
	_read rrpg_main "$username" > /dev/null
	load_attributes # They may have changed.

	export difficulty=$(cat "$basedir/home/$username/diff.pwd")

	if [ "$2" -gt "$xp" ]; then
		export xp="$2"
	elif [ "$3" -gt "$ig_level" ]; then
		export ig_level="$3"
	elif [ "$2" -lt "$xp" ]; then
		export xp="$2"
	elif [ "$3" -lt "$ig_level" ]; then
		### Just incase you lose a level somehow.
		export ig_level="$ig_level"
	fi
	## Check if able to level up.
	bash "$basedir/content/rrpg_level.bash" "$difficulty" "$level" "$xp" 2> "$basedir/tmp/errors"

	## REASSIGN SP, SINCE LEVEL COULD'VE MODFIYED IT.
	export sp=$(cat "$basedir/db/sp.txt")

	## Write Data.
	_write "$username" $1 $xp "$sp" "$class" "$gender" "$ig_level" rrpg_main  > /dev/null

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
	load_attributes
	export lvl="$level" #compat
	export hp=$(cat "$basedir/home/$username/hp.pwd")
}

# Called whenever we first enter the game.
function enter_content {
	# shellcheck source=engine/rrpg_skill.bash
	source "$ENGINE_DIR/rrpg_skill.bash" --generate
	
	# shellcheck source=engine/rrpg_item.bash
	source "$ENGINE_DIR/rrpg_item.bash"

	gen_items
	gen_equip
	gen_attribs

	echo "$1"

	$1
}

function rrpg_main {
	## GLOBAL LOGO CONTROL, and COLOR.
	cecho "============================================" cyan
	cecho "=                   eqb                    =" cyan
	cecho "============================================" cyan
}


echo "OK"
