#!/bin/bash
##
## (C) 2013 RDCoding (RDashINC)
## AUTHOR: RainbowDashDC
## DATE: 18/07/13
##
## PROJECT: rrpg
## ROLE: rrpg_skill function
##
##############################################
# VARIABLES                                  #
##############################################
export DATE="[18/07/13-BTF]"                 #
export VER="0.1"                             # 
export basedir=$(get_basedir.cmd)
##############################################

## FUNCTIONS

## Temporary mod sourceing till this is sourced.
source $basedir/content/rrpg_modloader.bash 1>/dev/null

function skill_prompt {
	get_class
	get_diff
	skills "$1" "$2" "$3"
}

function get_class {
	local class="$(cat $basedir/db/class.txt)"
	if [ "$class" == "Pegasus" ]; then
		export spkill="Agility"
	elif [ "$class" == "Unicorn" ]; then
		export spkill="Magic"
	elif [ "$class" == "Earth" ]; then
		export spkill="Strength"
	fi
}

function get_diff {
	## Assign to real-names soon.
	local diff="$(cat $basedir/home/$username/diff.pwd)"
	export difficulty="$diff"
}

function generate_skills {
	## localize file
	local basedir="$1"
	local username="$(cat $basedir/db/username.txt)"
	local file="$basedir/home/$username/skills.pwd"

	## Get Class & diff
	get_class
	get_diff

	## Below are skills and default starting values.
	## This will probably be a /very/ long function at final product.
	## These Values are currently place-holders and not rtv.

	## Controls Special Skills.
	echo "# Skills File. Using Control File Format." > $file
	if [ "$spkill" == "Agility" ]; then
		echo "Flight: 5" >> $file
	elif [ "$spkill" == "Magic" ]; then
		echo "Conjunction: 5" >> $file
		echo "Magic: 5" $file
	elif [ "$spkill" == "Strength" ]; then
		echo "Strength: 10" >> $file
		local ss="1"
	fi
	echo "Archery: 0" >> $file
	echo "Demolition: 0" >> $file
	if [ ! "$ss" == "1" ]; then
		echo "Strength: 5" >> $file
	fi

	return
}

function write_skill {
	local username="$(cat $basedir/db/username.txt)"
	if [ "$1" == "" ]; then
		echo "USAGE: rrpg_skill.bash [skill_to_write] [skill_value]"
		exit
	elif [ "$2" == "" ]; then
		echo "USAGE: rrpg_skill.bash [skill_to_write] [skill_value]"
		exit
	fi
	local skill_to_write="$1"
	local skill_value="$2"

	## Get Skill Line Number
	cat $basedir/home/$username/skills.pwd | grep -n "$skill_to_write" | awk -F ":" '{ print $1 }' > $basedir/tmp/lnum
	local lnum="$(cat ./tmp/lnum)"

	## Replace Line Number with skill name: new value.
	perl -pe "s/.*/$skill_to_write: $skill_value/ if $. == $lnum " > $basedir/tmp/skills.tmp < $basedir/home/$username/skills.pwd && ## Can't write to file being read.
	mv $basedir/home/$username/skills.pwd $basedir/tmp/skills.pwd.bk ## Preserve File in TMP.
	mv $basedir/tmp/skills.tmp $basedir/home/$username/skills.pwd ## Move New Skills File to DB.
}

function gen_menu {
	local username="$(cat $basedir/db/username.txt)"
	local SKILLS_FILE="$(cat $basedir/home/$username/skills.pwd | awk '{ print $1 }' )"
	local num=0

	## Generate Header.
	echo "-----------------------[SKILLS]----------------------"
	for skill in $SKILLS_FILE
	do
		if [ ! "$skill" == "#" ]; then
			## Print Out Skill Name with no new-line.
			echo -n "$skill "

			## Print out on new-line skill value.
			cat $basedir/home/$username/skills.pwd | grep "$skill" | awk '{ print $2 }'
		fi
	done
	echo "------------------------------------------------------"
}

function check_level {
	local username="$(cat $basedir/db/username.txt)"
	## Will Check Level and Add New Skills (Allows Level-Based Skills).
	if [ "$1" == "10" ]; then
		## PLACEHOLDER
		echo "Security: 0" >> $basedir/home/$username/skills.pwd
	fi
}

function write_sp {
	local username="$(cat $basedir/db/username.txt)"
	echo -n "Writing Skill Points..."
	_write  "$username" "$(cat $basedir/db/level.txt)" "$(cat $basedir/db/xp.txt)" "$1" "$(cat $basedir/db/class.txt)" "$(cat $basedir/db/gender.txt)" "$(cat $basedir/home/$username/diff.pwd)" "rrpg_main" > $basedir/tmp/_write_skill
	_read "rrpg_main" "$(cat $basedir/db/username.txt)" > $basedir/tmp/_read_skill
	echo "OK"
}

function skills {
	clear
	if [ ! "$1" == "--return" ]; then
		check_level "$1"

		local sp_supplied="$2"
		local sp_before="$(cat $basedir/db/sp.txt)"
		local sp_after="$(($sp_before+$sp_supplied))"
	else
		local sp_after="$2"
	fi

	## Allow Fast Read instead of echo upon for loop.
	gen_menu 
	echo "Skill Points Available: $sp_after."

	echo ""
	read -p "Use Skill Points? [Y/n]: " choice
	if [ ! "$choice" == "Y" ]; then
		if [ ! "$choice" == "y" ]; then
			echo "Not Using Skill Points!"
			write_sp "$sp_after"
			sleep 1
			return
		fi
	fi

	echo ""
	## Possible to just list value here.
	read -p "Skill: " skill

	read -p "Value: " value

	echo "Checking Input..."
	echo -n "	- Amount of Skill Points..." && echo "$sp_after"
	echo -n "	- Value Entered..." && echo "$value"
	echo -n "	- Input Vaild..."
	if [ "$value" -lt "$((sp_after+1))" ]; then
		if [ "$value" -gt "0" ]; then
			echo "OK"
		else
			echo "FAIL"
			echo "Input was invaild." && exit
			exit
		fi
	else
		echo "FAIL"
		echo "Input was invalid." && exit
	fi

	echo -n "Writing Skill Value..."
	local username="$(cat $basedir/db/username.txt)"
	cat $basedir/home/$username/skills.pwd | grep "$skill" | awk '{ print $2 }' > $basedir/tmp/v.tmp
	local valuepu="$(cat $basedir/tmp/v.tmp)"
	local valueplus="$(($valuepu+$value))"
	write_skill $skill $valueplus
	echo "OK"

	echo -n "Checking if any skill points remain..."
	local sp_total="$(($sp_after - $value))"
	if [ "$sp_total" -gt "0" ]; then
		echo "$sp_total"
		sleep 1
		skill_prompt "--return" "$sp_total"
	else
		echo "$sp_total"
		write_sp "0"
	fi
	exit
}

if [ "$1" == "--generate" ]; then
	generate_skills $basedir
	exit
fi

skill_prompt "$1" "$2" "$3"
