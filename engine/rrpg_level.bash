#!/bin/bash
### I really didn't wanna work on this, so I made this.
################################################################
#                         INFORMATION                          #
################################################################
##                                                             #
############################################                   #
## Level-Up Generator for RRPG.            #                   #
############################################                   #
## Developed by RainbowDashDC for RDashInc #                   #
## (C) 2013-Present RDashInc (RDCoding)    #                   #
## GNUGPLV3 (http://gnu.org/)              #                   #
############################################                   #
##                                                             #
############################################                   #
## VARIABLES                               #                   #
############################################                   #
export ver="1.2.5"                         #                   #
export date="[29/08/13-BTF]"               #                   #
export basedir=$(get_basedir)              #                   #
############################################                   #
##                                                             #
################################################################

## Temporary mod sourceing till this is sourced.
source "$basedir/content/rrpg_modloader.bash" 1>/dev/null

function assign_var {
	## Make sure that everything is assigned.
	### I need a better way of doing this.
	if  [ "$1" == "" ]; then
		echo "USAGE: rrpg_level.bash [difficulty] [level] [xp]"
		exit
	elif [ "$2" == "" ]; then
		echo "USAGE: rrpg_level.bash [difficulty] [level] [xp]"
		exit
	elif [ "$3" == "" ]; then
		echo "USAGE: rrpg_level.bash [difficulty] [level] [xp]"
		exit
	fi

	export difficulty="$1"
	export level="$1"
	export xp="$3"
}

function check_difficulty {
	## Function isn't actually needed, used just for simplicity of reading this.
	if [ "$1" == "1" ]; then
		export level_gov="easy"
	elif [ "$1" == "2" ]; then
		export level_gov="medium"
	elif [ "$1" == "3" ]; then
		export level_gov="hard"
	elif [ "$1" == "4" ]; then
		export level_gov="impossible"
	fi
}

# shellcheck disable=SC2120
function write_to_db {
	local sp="$(cat $basedir/db/sp.txt)"
	local l="$(cat $basedir/db/level.txt)"
	local xp="$(cat $basedir/db/xp.txt)"
	local username="$(cat $basedir/db/username.txt)"
	local gender="$(cat $basedir/db/gender.txt)"
	local class="$(cat $basedir/db/class.txt)"
	local difficulty="$(cat $basedir/home/$username/diff.pwd)"
	local ig_level="$(cat $basedir/db/ig_level.txt)"

	_write "$username" "$1" "$xp" "$sp" "$class" "$gender" "$ig_level" rrpg_main  > /dev/null
}

function check_xp {
	local level="$1"
	local xp="$2"
	local level_gov="$3"

	if [ "$level_gov" == "easy" ]; then
		export req_xp_div="$(($level / 4 ))"
		export req_xp="$(($level * $req_xp + 100))"

		if [ "$xp" -ge "$req_xp" ]; then
			## Too Prevent Possible Variable Corruption.
			local nxp="$(($xp - $req_xp))"
			export xp="$nxp"

			level_up "$level" "$(($level + 1))" "$level_gov" "$xp"
		else
			## Below Amount of XP, or error has occured.
			return
		fi

		## Must have leveled up, return.
		return
	fi
	if [ "$level_gov" == "medium" ]; then
		export req_xp_div="$(($level / 3 ))"
		export req_xp="$(($level * $req_xp + 100))"

		if [ "$xp" -ge "$req_xp" ]; then
			## Too Prevent Possible Variable Corruption.
			local nxp="$(($xp - $req_xp))"
			export xp="$nxp"

			level_up "$level" "$(($level + 1))" "$level_gov" "$xp"
		else
			## Below Amount of XP, or error has occured.
			return
		fi

		## Must have leveled up, return.
		return
	fi
	if [ "$level_gov" == "hard" ]; then
		export req_xp_div="$(($level / 2 ))"
		export req_xp="$(($level * $req_xp + 100))"

		if [ "$xp" -ge "$req_xp" ]; then
			## Too Prevent Possible Variable Corruption.
			local nxp="$(($xp - $req_xp))"
			export xp="$nxp"

			level_up "$level" "$(($level + 1))" "$level_gov" "$xp"
		else
			## Below Amount of XP, or error has occured.
			return
		fi

		## Must have leveled up, return.
		return
	fi
	if [ "$level_gov" == "impossible" ]; then
		export req_xp_div="$(($level / 1 ))"
		export req_xp="$(($level * $req_xp + 100))"

		if [ "$xp" -ge "$req_xp" ]; then
			## Too Prevent Possible Variable Corruption.
			local nxp="$(($xp - $req_xp))"
			export xp="$nxp"

			level_up "$level" "$(($level + 1))" "$level_gov" "$xp"
		else
			## Below Amount of XP, or error has occured.
			return
		fi

		## Must have leveled up, return.
		return
	fi
}

function level_up {
	local level="$1"
	local new_level="$2"
	local level_gov="$3"
	local xp="$4"
	## Display to User they've
	## level'd up.

	### LINKING TO RRPG_SKILL.bash
	echo "LEVEL UP [ $level ==> $new_level ]"
	echo ""
	if [ "$level_gov" == "easy" ]; then
		bash $basedir/content/rrpg_skill.bash $new_level 5
	elif [ "$level_gov" == "medium" ]; then
		bash $basedir/content/rrpg_skill.bash $new_level 4
	elif [ "$level_gov" == "hard" ]; then
		bash $basedir/content/rrpg_skill.bash $new_level 3
	elif [ "$level_gov" == "impossible" ]; then
		bash $basedir/content/rrpg_skill.bash $new_level 2
	fi
	echo ""
	read -sp "Press any Key to Continue." && echo ""

	## Write New Level to DB.
	echo "$new_level" > $basedir/db/ig_level.txt && ### It should be alright to write to extraction file? Could Be Overwritten.
	echo "$xp" > $basedir/db/xp.txt
	write_to_db

	## Check for Surplus XP resulting in New Level.
	check_xp "$new_level" "$xp" "$level_gov"
}

## Call Functions and check level.

assign_var "$1" "$2" "$3"
check_difficulty "$difficulty"
check_xp "$level" "$xp" "$level_gov"
