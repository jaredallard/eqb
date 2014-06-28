#!/usr/bin/env bash
#
# (c) 2014 RDashINC
#
# Why does bash use function x { } and x() { } syntax

is_vowel() {
	l=$1
	[ "$l" == "a" -o "$l" == "e" -o "$l" == "i" -o "$l" == "o" -o "$l" == "u" ] && echo true || echo false
}

get_item_amount() {
	if [ "$1" == "" ]; then
		error "missing item"
		return
	fi

	local item=$1
	local item=$(cat $basedir/home/$username/items.lst | grep -n "$item=" || echo err)
	local item_number=${item##*=}

	if [ "$item_number" == "err" ]; then
		echo not_exist
	else
		echo $item_number
	fi
}

has_item() {
	if [ "$1" == "" ]; then
		error "missing item"
		return
	fi

	local item=$1
	local call=$(get_item_amount $item)
	
	if [ "$call" == "0" ]; then
		echo false
	elif [ "$call" == "not_exist" ]; then
		error "item not found"
		return
	else
		echo true
	fi
}

add_item() {
	open
	local item=$1
	local amount=$2

	if [ "$1" == "" ]; then
		error "Needs an item param"
		return
	elif [ "$2" == "" ]; then
		error "Needs an amount param"
		return
	fi

	## Get Skill Line Number
	cat $basedir/home/$username/items.lst | grep -n "$item=" | awk -F ":" '{ print $1 }' > $basedir/tmp/lnum
	local lnum="$(cat $basedir/tmp/lnum)"

	if [ "$lnum" == "" ]; then
		error "Item not found, try regenerating the item list."
		return
	fi

	parse_cfg $basedir/home/$username/items.lst $item

	if [ "${!item}" == "" ]; then
		error "WTF Moment, item not defined, but was found."
		return
	fi

	local amount_orig=$amount
	local amount=$((${!item}+$amount))


	## Replace Line Number with skill name: new value.
	perl -pe "s/.*/$item=$amount/ if $. == $lnum " > $basedir/tmp/items.tmp < $basedir/home/$username/items.lst && ## Can't write to file being read.
	mv $basedir/home/$username/items.lst $basedir/tmp/items.lst.bk ## Preserve File in TMP.
	mv $basedir/tmp/items.tmp $basedir/home/$username/items.lst

	if [ ! "$amount_orig" -gt "1" ]; then 
		echo -e "${White}** ${Green}`an_or_a ${item::1}`${White} '${Cyan}$item${White}' ${Green} was added to your inventory!${NC}"
	else
		echo -e "${White}** ${Purple}$amount_orig${White} '${Cyan}${item}s${White}' ${Green} were added to your inventory! You Have: ${Purple}$amount${White}.${NC}"
	fi
}

an_or_a() {
	local is=$(is_vowel $1)
	if [ "$is" == "true" ]; then
		echo An
	else
		echo A
	fi
}

remove_item() {
	open
	local item=$1
	local amount=$2

	if [ "$1" == "" ]; then
		error "Needs an item param"
		return
	elif [ "$2" == "" ]; then
		error "Needs an amount param"
		return
	fi

	## Get Skill Line Number
	cat $basedir/home/$username/items.lst | grep -n "$item=" | awk -F ":" '{ print $1 }' > $basedir/tmp/lnum
	local lnum="$(cat $basedir/tmp/lnum)"

	if [ "$lnum" == "" ]; then
		error "Item not found, try regenerating the item list."
		return
	fi

	parse_cfg $basedir/home/$username/items.lst $item

	if [ "${!item}" == "" ]; then
		error "WTF Moment, item not defined, but was found."
		return
	elif [ "${!item}" -lt "$amount" ]; then
		error "User doesn't have enough to remove."
		return 1
	fi

	local amount_orig=$amount
	local amount=$((${!item}-$amount))

	## Replace Line Number with skill name: new value.
	perl -pe "s/.*/$item=$amount/ if $. == $lnum " > $basedir/tmp/items.tmp < $basedir/home/$username/items.lst && ## Can't write to file being read.
	mv $basedir/home/$username/items.lst $basedir/tmp/items.lst.bk ## Preserve File in TMP.
	mv $basedir/tmp/items.tmp $basedir/home/$username/items.lst
	if [ ! "$amount_orig" -gt "1" ]; then
		echo -e "${White}** ${Red}`an_or_a ${item::1}`${White} '${Cyan}${item}${White}' ${Red} was removed from your inventory! ${Purple}$amount${White} ${Red}left!${NC}"
	else 
		echo -e "${White}** ${Purple}$amount_orig${White} '${Cyan}${item}s${White}' ${Red} were removed from your inventory! ${Purple}$amount${White} ${Red}left!${NC}${NC}"
	fi
}

gen_attribs() {
	open
	# base
	local attack_final=0
	local defense_final=0
	local speed_final=0
	local mana_final=0

	# scan items
	echo "generating atrributes..."
	for item in $(cat $basedir/home/$username/items.lst | tail -n+3 )
	do
		local item_name=${item%%=*}
		local item_number=${item##*=}
		local item_path=$basedir/content/loaded/items/$item_name.itm
		echo -n " - $item_name=$item_number"

		if [ ! -e "$item_path" ]; then
			echo ""
			echo "Err: $item_name isn't a real item"
			exit
		elif [ $item_number == 0 ]; then
			echo ""
		else
			parse_cfg $item_path weildable
			if [ $weildable == 1 ]; then
				if [ $(is_equipped ${item_name}) == "true" ]; then
					echo -n " \ equipped"
					local n=0
					until [ $n == $item_number ]
					do
						local n=$(($n+1))
						parse_cfg $item_path attack
						parse_cfg $item_path defense

						echo " +${attack}A +${defense}D"

						# Remove me
						local attack_final=$((${attack}+$attack_final))
						local defense_final=$((${defense}+$defense_final))
					done
				else
					echo " \ not equipped"
				fi
			else
				echo ""
			fi
		fi
	done

	echo " You have $attack_final attack, and $defense_final defense."
	echo $attack_final > $basedir/home/$username/attack.txt
	echo $defense_final > $basedir/home/$username/defense.txt
	echo done
}

equip_item() {
	open
	if [ ! -e "$basedir/home/$username/equip.cfg" ]; then
		gen_equip
	fi

	if [ "$1" == "" ]; then
		error "position not given"
		return
	elif [ "$2" == "" ]; then
		error "item not given"
		return
	fi

	local position=$1
	local item=$2
	local item_path=$basedir/content/loaded/items/$item.itm

	local item_lst=$(cat $basedir/home/$username/items.lst | grep "$item=")
	local item_number=${item_lst##*=}

	if [ ! -e "$item_path" ]; then
		echo "Err: $item_name isn't a real item"
		return
	fi

	parse_cfg $item_path weildable
	parse_cfg $item_path equip

	if [ $weildable == 0 ]; then
		error "Cannot be equipped!"
		return
	elif [[ "$equip" == "weapon" ]]; then
		if [[ ! "$position" == "main_weapon" || ! "$position" == "second_weapon" ]]; then
			error "Cannot be equipped here!"
			return
		fi
	elif [[ ! "$equip" == "$position" ]]; then
		error "Cannot be equipped here!"
		return
	fi

	## Get Skill Line Number
	cat $basedir/home/$username/equip.cfg | grep -n "$position=" | awk -F ":" '{ print $1 }' > $basedir/tmp/lnum
	local lnum="$(cat $basedir/tmp/lnum)"

	if [ "$lnum" == "" ]; then
		error "Item not found, try regenerating the item list."
		return
	fi

	## Replace Line Number with skill name: new value.
	perl -pe "s/.*/${position}=${item}/ if $. == $lnum " > $basedir/tmp/equip.tmp < $basedir/home/$username/equip.cfg && ## Can't write to file being read.
	mv $basedir/home/$username/equip.cfg $basedir/tmp/equip.cfg.bk ## Preserve File in TMP.
	mv $basedir/tmp/equip.tmp $basedir/home/$username/equip.cfg

	echo -e "** ${Purple}${item}${Cyan} has been equiped to ${Purple}${position}${NC}"

}

unequip_item() {
	open
	if [ ! -e "$basedir/home/$username/equip.cfg" ]; then
		gen_equip
	fi

	if [ "$1" == "" ]; then
		error "position not given"
		return
	fi

	local position=$1
	local item=$2

	if [ ! "$item" == "" ]; then
		cat $basedir/home/$username/equip.cfg | grep -n "$position=$item" | awk -F ":" '{ print $1 }' > $basedir/tmp/lnum
		local lnum="$(cat $basedir/tmp/lnum)"
	else
		local pt=$(cat $basedir/home/$username/equip.cfg | grep -n "$position=")
		local pv=$(cat $basedir/home/$username/equip.cfg | grep -n "$position=" | awk -F ':' '{ print $2 }' | awk -F '=' '{ print $2 }')
		local item=$pv
		if [ "$item" == "none" ]; then
			error "Nothing equipped!"
			return
		fi
		echo $pt | awk -F ':' '{ print $1 }' > $basedir/tmp/lnum
		local lnum="$(cat $basedir/tmp/lnum)"
	fi


	if [ "$lnum" == "" ]; then
		error "Is not equipped on $position, or $position not found."
		return
	fi

	perl -pe "s/.*/${position}=none/ if $. == $lnum " > $basedir/tmp/equip.tmp < $basedir/home/$username/equip.cfg && ## Can't write to file being read.
	mv $basedir/home/$username/equip.cfg $basedir/tmp/equip.cfg.bk ## Preserve File in TMP.
	mv $basedir/tmp/equip.tmp $basedir/home/$username/equip.cfg

	echo -e "** ${Purple}${item}${Cyan} has been unequipped from ${Purple}${position}${NC}"

}

equipped_item() {
	open
	if [ "$1" == "" ]; then
		error "position not given"
		return
	fi

	for item in $(cat $basedir/home/$username/equip.cfg | tail -n+3 )
	do
		local position=${item%%=*}
		local item_equipped=${item##*=}

		if [ "$position" == "$1" ]; then
			echo $item_equipped
		elif [ "$1" == "all" ]; then
			echo $position = $item_equipped
		fi
	done
}

is_equipped() {
	open
	if [ "$1" == "" ]; then
		error "item not given"
		return
	fi

	local item=$1

	cat $basedir/home/$username/equip.cfg | grep "=${item}$" 1>/dev/null
	if [ $? == 1 ]; then
		echo false
	else
		echo true
	fi
}

get_equipped_item() {
	open
	if [ "$1" == "" ]; then
		error "position not given"
		return
	fi

	local position=$1

	parse_cfg "$basedir/home/$username/equip.cfg" ${position} || return 1

	echo ${!position}
}

gen_equip() {
	open
	echo -n "generating equipables..."
	echo "#RRPG_MANIFEST" > $basedir/home/$username/equip.cfg
	echo "# Created [$(date +%T)]" >> $basedir/home/$username/equip.cfg
	echo "main_weapon=none" >> $basedir/home/$username/equip.cfg
	echo "second_weapon=none" >> $basedir/home/$username/equip.cfg
	echo "side=none" >> $basedir/home/$username/equip.cfg
	echo "head=none" >> $basedir/home/$username/equip.cfg
	echo "chest=none" >> $basedir/home/$username/equip.cfg
	echo "back=none" >> $basedir/home/$username/equip.cfg
	echo "hooves=none" >> $basedir/home/$username/equip.cfg
	echo done
}

gen_items() {
	open
	echo "Generating items for '$username'..."
	echo "#RRPG_MANIFEST" > $basedir/home/$username/items.lst
	echo "# Created [$(date +%T)]" >> $basedir/home/$username/items.lst
	for item in $( ls $basedir/content/loaded/items/*.itm )
	do
		parse_cfg $item start_amt
		item="$(echo ${item##*/} | awk -F "." '{ print $1 }')"

		echo "- adding $item \ $start_amt"
		echo "$item=$start_amt" >> $basedir/home/$username/items.lst
	done
	echo done
}