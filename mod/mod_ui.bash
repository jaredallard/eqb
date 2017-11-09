#!/usr/bin/env bash
# Handles UI.
# Sortof like a bash ncureses thing...
# (c) 2014 RDashINC

export HISTFILE_OLD=$HISTFILE
export HISTFILE=$basedir/home/$username/history
export LOGFILE=$basedir/tmp/output.txt
export RRPG_PROMPT="> "
export RRPG_HEADER="Equestria's Betrayal"
export RRPG_HEADER_2="v1.2"

echo "" > ${LOGFILE}

draw_header() {
	local rhn=${#RRPG_HEADER}
	local rhn2=${#RRPG_HEADER_2}
	local rhnf=$(($rhn+$rhn2))
	local NUM=$((`tput cols`-$rhnf))
	echo -e "$(echo -n $RRPG_HEADER; printf "%0.s " `seq 1 $NUM`; echo "$RRPG_HEADER_2")"
}

clean_exit() {
	export HISTFILE=$HISTFILE_OLD
	history -c
	history -n
	clear
}

clear_output() {
	local x=0
	until [ $x == $lines ]
	do
		let x=$x+1
		line[$x]="false"
	done
}

to_bottom() {
	local lines=`tput lines`
	tput cup $lines 0
}

clear_line() {
	clear_lines $*
}

print_chars() {
	if [ "$1" == "" ]; then
		echo "err: needs a char"
		return
	fi
	if [ "$2" == "" ]; then
		echo "err: needs a num"
		return
	fi

	for a in `seq $2`; do printf "$1"; done
}

draw_prompt() {
	local cols=`tput cols`
	local lines=`tput lines`
	to_bottom
	tput cuu 4
	print_chars " " $cols
	tput cup $(($lines-5)) 0
	history -n
	if [ ! "$1" == "--no-read" ]; then
		read -ep "${RRPG_PROMPT}" choice

		 # save the choice
		export choice=$choice
		echo "$choice" >> ${HISTFILE}
	else

		# we're just drawing the prompt, it's not an actual real one.
		echo -ne "${RRPG_PROMPT}"
	fi
}

draw_tip() {
	to_bottom
	tput cuu 3
	echo "$1"
}

to_top() {
	tput cup 0 0
	if [ ! "$1" == "" ]; then
		echo -e "$1"
	fi
}

clear_lines() {
	local line_number=$1
	local lines=`tput lines`
	local cols=`tput cols`

	local x=0
	until [ $x == $line_number ]
	do
		local n=0
		local y=0

		let x=$x+1

		# Move up a cert amount of lines, first save cursor pos (bottom)
		tput sc
		tput cuu $x


		while [ $n -lt $cols ]
		do
			echo -n ' '
			let n=$n+1
		done
		tput rc
	done

	echo
}

echo_to_end() {
	local lines=`tput lines`
	local n=0
	local v=""

	while [ $n -lt $cols ]
	do
		local v="$v$1"
		let n=$n+1
	done
	echo -n $v
}

echo_amount() {
	local number=$2
	local n=0
	local v=""
	while [ $n -lt $number ]
	do
		local v="$v$1"
		let n=$n+1
	done
	echo -n "$v"
}

send_output() {
	# Handles all output, as it should.

	local lines=`tput lines`
	local cols=`tput cols`
	local lines=$(($lines-8))
	local message=$1
	local message_chars=${#message}
	local n=1
	local num=0
	local final=""
	to_top
	for (( i=0; i<${message_chars}; i++ )); do
		if [[ $i -ge $cols ]]; then
			local crw=$cols
			until [ $i -lt $cols ]
			do
				local cols=$(($cols+$cols))
				let n=$n+1
				local final="${final}${message:$i:1}"
				line[$n]="true"
			done
		else
			local final="${final}${message:$i:1}"
		fi
	done
	local message=$final

	while :
	do
		let num=$num+1
		if [ "${num}" == "$(($lines))" ]; then
			local d=2
			line[$lines]="false"
			to_top
			tput cud $d
			export no_echo="false"
			local m=0
			if [ ! -e "$basedir/tmp/cls" ]; then
				echo -ne "" > $basedir/tmp/cls
				until [ $m == $(($lines)) ]
				do
					printf "%0.s " `seq 1 $(($cols))` >> $basedir/tmp/cls
					let m=$m+1
				done
			fi

			# Clear the text section
			cat $basedir/tmp/cls

			to_top
			tput cud $d
			tail -n $(($lines-1)) ${LOGFILE}
			break
		elif [ ! "${line[$num]}" == "true" ]; then
			to_top
			tput cud $(($num+1))
			break
		fi
	done

	if [ ! "$no_echo" == "true" ]; then
		line[$num]="true"
		echo "$message" | tee -a ${LOGFILE}
	else
		export no_echo="false"
	fi
}

draw_box() {
	local lines=`tput lines`
	local cols=`tput cols`

	to_bottom
	tput cuu 2
	echo_to_end "="

	# Section 2
	tput cup $(($lines-2)) 0 && echo -n "="
	tput cup $(($lines-2)) 2
	echo -ne "Health: ${Green}$(cat $basedir/home/$username/hp.pwd)${NC} / XP: ${Cyan}$(cat $basedir/db/xp.txt)${NC}"
	tput cup $(($lines-2)) $cols && echo -n "="

	# Section 1
	tput cup $(($lines-1)) 0 && echo -n "="
	tput cup $(($lines-1)) 2
	echo -ne "A: ${Red}$(cat $basedir/home/$username/attack.txt) ${NC}/ D: ${Blue}$(cat $basedir/home/$username/defense.txt)${NC}"
	tput cup $(($lines-1)) $cols && echo -n "="

	to_bottom

	# Draw the prompt
	draw_prompt --no-read
}

draw_main() {
	trap "clear; draw_main; draw_prompt --no-read" SIGWINCH

	# RM cls file
	rm -rf $basedir/tmp/cls

	# Load User history file.
	if [[ ! -e $HISTFILE ]]; then
		touch "$HISTFILE"
	fi

	# Clear old history.
	history -c

	# "Initialize" the display.
	# i.e draw_main && prompt
	clear
	local lines=`tput lines`
	local cols=`tput cols`

	clear_output
	to_top
	draw_header
	draw_box
	to_bottom
}
