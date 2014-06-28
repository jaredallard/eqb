#!/bin/bash
# AUTHOR: RAINBOWDASHDC (@RAINDASHDC) (@2ROOT4YOU)
# COPYRIGHT: RDASHINC (RDCoding) http://rdashinc.tk/
# DESC: RRPG MAN-DB THING + HEALTH BAR/XP
# DATE: SUNDAY, JULY 6 2013.
##########################################
#           VARIABLES                    #
##########################################
export ver="1.1-dev"                         #
export date="[28/08/13-BTF]"             #
##########################################

function welcome {
	cecho "================================================" cyan
	cecho "=                RRPG MAN-DB                   =" cyan
	cecho "================================================" cyan
	cecho "Version: $1 - $2" green
	cecho "================================================" cyan
	cecho "Do 'help' if you need help." magenta
	echo ""
}

function help-rrpg {
	echo "Avaiable Commands [General]:"
	echo "	classes, pegasus unicorn earth"
	echo "	clear"
	echo "	exit"
	prompt-call
}

function exit-rrpg {
	echo "See you Soon!"
	exit
}

function prompt {
	export ver
	export date
	export choice=""
	cecho "rrpg_man> \c" magenta
	read choice
	export a1="$( echo "$choice" | awk '{ print $1 }' )"
	export a2="$( echo "$choice" | awk '{ print $2 }' )"
	export a3="$( echo "$choice" | awk '{ print $3 }' )"
	if [ "$a1" == "classes" ]; then
		classes "$a2" "$a3"
	elif [ "$a1" == "help" ]; then
		help-rrpg
	elif [ "$choice" == "clear" ]; then
		clear
		welcome $ver $date
		prompt
	elif [ "$a1" == "exit" ]; then
		exit-rrpg
	else
		echo "Command Not Found. [$choice]"
		prompt-call
	fi
}

function prompt-call {
	echo "" && prompt
}

function class-pegasus {
	echo "Pegasus:"
	echo " The pegasus, or more 'Pegasi' are known for their speed and agility"
	echo " in the sky. Throught the game you'll have chances to bypass certain"
	echo " Places/Things. However, flying consumes alot of stamina and can result"
	echo " In a loss of energy in a battle, resulting in less damage inflicted on"
	echo " your oppenent. Also, allows access to the 'Flight' skill."
	prompt-call
}

function class-unicorn {
	echo "Unicorn:"
	echo " Unicorns. Unicorns are most likely one of the most important classes in"
	echo " the game. Why? They have the ability to use magic. Magic is another form"
	echo " of offense, defense, and of doing things. Being a Unicorn allows access to"
	echo " the 'Magic' skill."
	prompt-call
}

function class-earth {
	echo "Earth: "
	echo " Earth Ponies, or sometimes known as 'Terra Ponies'. Lack a Horn and wings;"
	echo " However, they make up for this loss, in their strength and quick thinking."
	echo " Being a Earth Pony allows access to the Strength Category of skills."
	prompt-call
}


function classes {
	if [ ! "$1" == "Pegasus" ]; then
		if [ "$1" == "pegasus" ]; then
			class-pegasus
		fi
	else
		class-pegasus
	fi
	if [ ! "$1" == "Unicorn" ]; then
		if [ "$1" == "unicorn" ]; then
			class-unicorn
		fi
	else
		class-unicorn
	fi
	if [ ! "$1" == "Earth" ]; then
		if [ "$1" == "earth" ]; then
			class-earth
		fi
	else
		class-earth
	fi
	echo "Avaiable Classes:"
	echo "	Pegasus -- A Pony with wings, allows access to the air."
	echo "	Unicorn -- A Pony with a Horn ontop of center head mark."
	echo "	Earth -- A Pony without any special traits."
	echo ""
	echo "Do classes [class] for more information on each class."
	prompt-call
}

welcome "$ver" "$date"
prompt
