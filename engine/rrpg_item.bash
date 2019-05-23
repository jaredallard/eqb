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
	local item=$(grep -n "$item=" "$basedir/home/$username/items.lst" || echo err)
	local item_number=${item##*=}

	if [ "$item_number" == "err" ]; then
		echo not_exist
	else
		echo "$item_number"
	fi
}

has_item() {
	if [ "$1" == "" ]; then
		error "missing item"
		return
	fi

	local item=$1
	local call=$(get_item_amount "$item")

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
	grep -n "$item=" "$basedir/home/$username/items.lst" | awk -F ":" '{ print $1 }' > "$basedir/tmp/lnum"
	local lnum="$(cat "$basedir/tmp/lnum")"

	if [ "$lnum" == "" ]; then
		error "Item not found, try regenerating the item list."
		return
	fi

	parse_cfg "$basedir/home/$username/items.lst" "$item"

	if [ "${!item}" == "" ]; then
		error "WTF Moment, item not defined, but was found."
		return
	fi

	local amount_orig=$amount
	local amount=$((${!item}+amount))


	## Replace Line Number with skill name: new value.
	perl -pe "s/.*/$item=$amount/ if $. == $lnum " > "$basedir/tmp/items.tmp" < "$basedir/home/$username/items.lst"
	mv "$basedir/home/$username/items.lst" "$basedir/tmp/items.lst.bk" ## Preserve File in TMP.
	mv "$basedir/tmp/items.tmp" "$basedir/home/$username/items.lst"

	if [ ! "$amount_orig" -gt "1" ]; then
		send_output "${White}** ${Green}$(an_or_a "${item::1}")${White} '${Cyan}$item${White}' ${Green} was added to your inventory!${NC}"
	else
		send_output "${White}** ${Purple}$amount_orig${White} '${Cyan}${item}s${White}' ${Green} were added to your inventory! You Have: ${Purple}$amount${White}.${NC}"
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
	cat "$basedir/home/$username/items.lst" | grep -n "$item=" | awk -F ":" '{ print $1 }' > "$basedir/tmp/lnum"
	local lnum="$(cat "$basedir/tmp/lnum")"

	if [ "$lnum" == "" ]; then
		error "Item not found, try regenerating the item list."
		return
	fi

	parse_cfg "$basedir/home/$username/items.lst" "$item"

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
	perl -pe "s/.*/$item=$amount/ if $. == $lnum " > "$basedir/tmp/items.tmp" < "$basedir/home/$username/items.lst"
	mv "$basedir/home/$username/items.lst" "$basedir/tmp/items.lst.bk" ## Preserve File in TMP.
	mv "$basedir/tmp/items.tmp" "$basedir/home/$username/items.lst"
	if [ ! "$amount_orig" -gt "1" ]; then
		echo -e "${White}** ${Red}$(an_or_a "${item::1}")${White} '${Cyan}${item}${White}' ${Red} was removed from your inventory! ${Purple}$amount${White} ${Red}left!${NC}"
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
	echo -n "generating atrributes..."
	if [ "$1" == "--verbose" ]; then
		echo ""
	fi
	for item in $(tail -n+3 < "$basedir/home/$username/items.lst")
	do
		local item_name=${item%%=*}
		local item_number=${item##*=}
		local item_path=$basedir/content/loaded/items/$item_name.itm
		if [ "$1" == "--verbose" ]; then
			echo -n " - $item_name=$item_number"
		fi

		if [ ! -e "$item_path" ]; then
			echo ""
			echo "Err: $item_name isn't a real item"
			exit
		elif [[ $item_number == 0 ]]; then
			if [ "$1" == "--verbose" ]; then
				echo ""
			fi

		else
			parse_cfg $item_path weildable
			if [[ $weildable == 1 ]]; then
				if [ $(is_equipped ${item_name}) == "true" ]; then
					if [ "$1" == "--verbose" ]; then
						echo -n " \ equipped"
					fi
					local n=0
					until [ $n == $item_number ]
					do
						local n=$(($n+1))
						parse_cfg "$item_path" attack
						parse_cfg "$item_path" defense

						if [ "$1" == "--verbose" ]; then
							echo " +${attack}A +${defense}D"
						fi

						# Remove me
						local attack_final=$((${attack}+$attack_final))
						local defense_final=$((${defense}+$defense_final))
					done
				else
					if [ "$1" == "--verbose" ]; then
						echo " \ not equipped"
					fi
				fi
			else
				if [ "$1" == "--verbose" ]; then
					echo ""
				fi
			fi
		fi
	done
	if [ "$1" == "--verbose" ]; then
		echo " You have $attack_final attack, and $defense_final defense."
	fi
	echo $attack_final > "$basedir/home/$username/attack.txt"
	echo $defense_final > "$basedir/home/$username/defense.txt"
	echo "done"
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

	parse_cfg "$item_path" weildable
	parse_cfg "$item_path" equip

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
	perl -pe "s/.*/${position}=${item}/ if $. == $lnum " > "$basedir/tmp/equip.tmp" < "$basedir/home/$username/equip.cfg"
	mv "$basedir/home/$username/equip.cfg" "$basedir/tmp/equip.cfg.bk"
	mv "$basedir/tmp/equip.tmp" "$basedir/home/$username/equip.cfg"

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
		grep -n "$position=$item" < "$basedir/home/$username/equip.cfg" | awk -F ":" '{ print $1 }' > "$basedir/tmp/lnum"
		local lnum="$(cat $basedir/tmp/lnum)"
	else
		local pt=$(grep -n "$position=" < "$basedir/home/$username/equip.cfg")
		local pv=$(grep -n "$position=" < "$basedir/home/$username/equip.cfg" | awk -F ':' '{ print $2 }' | awk -F '=' '{ print $2 }')
		local item=$pv
		if [ "$item" == "none" ]; then
			error "Nothing equipped!"
			return
		fi
		echo "$pt" | awk -F ':' '{ print $1 }' > "$basedir/tmp/lnum"
		local lnum="$(cat "$basedir/tmp/lnum")"
	fi


	if [ "$lnum" == "" ]; then
		error "Is not equipped on $position, or $position not found."
		return
	fi

	# TODO: Stop repeating this same function like 200000 times
	perl -pe "s/.*/${position}=none/ if $. == $lnum " > "$basedir/tmp/equip.tmp" < "$basedir/home/$username/equip.cfg"
	mv "$basedir/home/$username/equip.cfg" "$basedir/tmp/equip.cfg.bk"
	mv "$basedir/tmp/equip.tmp" "$basedir/home/$username/equip.cfg"

	echo -e "** ${Purple}${item}${Cyan} has been unequipped from ${Purple}${position}${NC}"

}

equipped_item() {
	open
	if [ "$1" == "" ]; then
		error "position not given"
		return
	fi

	for item in $(tail -n+3 < "$basedir/home/$username/equip.cfg")
	do
		local position=${item%%=*}
		local item_equipped=${item##*=}

		if [ "$position" == "$1" ]; then
			echo "$item_equipped"
		elif [ "$1" == "all" ]; then
			echo "$position = $item_equipped"
		fi
	done
}

use_item() {
	open
	if [ "$1" == "" ]; then
		error "item not given"
		return
	fi

	local item=$1

	if [ "$(has_item "$item")" == "false" ]; then
		error "You don't have this item!"
		return
	fi

	parse_cfg "$basedir/content/loaded/items/${item}.itm" eatable
	if [ $eatable -eq 1 ]; then
		parse_cfg "$basedir/content/loaded/items/${item}.itm" health
		parse_cfg "$basedir/content/loaded/items/${item}.itm" XP
		parse_cfg "$basedir/content/loaded/items/${item}.itm" SP

		echo -ne "** ${Green}Used ${Purple}1 ${White}'${Cyan}${item}${White}'${Green}, You got; "
		if [ $health -ne 0 ]; then
			local hb=$(cat "$basedir/home/$username/hp.pwd")
			local hn=$((hb+health))
			echo $hn > $basedir/home/$username/hp.pwd
			echo -ne "${Purple}$health${Green} HP, "
		fi

		if [ $XP -ne 0 ]; then
			local xb=$(cat "$basedir/db/xp.txt")
			local xn=$((xb+XP))
			echo $xn > "$basedir/db/xp.txt"
			echo -ne "${Purple}$XP${Green} XP, "
		fi

		if [ $SP -ne 0 ]; then
			local sb=$(cat "$basedir/db/sp.txt")
			local sn=$((sb+SP))
			echo $sn > "$basedir/db/sp.txt"
			echo -ne "${Purple}$SP${Green} SP, "
		fi

		echo -e "\b\b.${NC}"

		# DB Variables
		local sp="$(cat "$basedir/db/sp.txt")"
		local level="$(cat "$basedir/db/level.txt")"
		local xp="$(cat "$basedir/db/xp.txt")"
		local un="$(cat "$basedir/db/username.txt")"
		local sex="$(cat "$basedir/db/gender.txt")"
		local class="$(cat "$basedir/db/class.txt")"
		local diff="$(cat "$basedir/home/$username/diff.pwd")"
		local igl="$(cat "$basedir/db/ig_level.txt")"

		# Call DB re-write.
		_write "$username" "$level" "$xp" "$sp" "$class" "$sex" "$igl" rrpg_main  > /dev/null

		remove_item "${item}" 1 > /dev/null
	else
		echo "cannot be used!"
	fi
}

is_equipped() {
	open
	if [ "$1" == "" ]; then
		error "item not given"
		return
	fi

	local item=$1

	grep "=${item}$" < "$basedir/home/$username/equip.cfg" 1>/dev/null
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

	parse_cfg "$basedir/home/$username/equip.cfg" "${position}" || return 1

	echo "${!position}"
}

gen_equip() {
	open
	echo -n "generating equipables..."
	{
		echo "#RRPG_MANIFEST"
		echo "# Created [$(date +%T)]"
		echo "main_weapon=none"
		echo "second_weapon=none"
		echo "side=none"
		echo "head=none"
		echo "chest=none"
		echo "back=none"
		echo "hooves=none"
	} > "$basedir/home/$username/equip.cfg"
	echo "done"
}

gen_items() {
	open
	echo -n "generating items list..."
	if [ "$1" == "--verbose" ]; then
		echo ""
	fi

	echo -e "#RRPG_MANIFEST\n# Created [$(date +%T)]" > "$basedir/home/$username/items.lst"
	for item in "$basedir/content/loaded/items/"*.itm 
	do
		parse_cfg "$item" start_amt
		item="$(echo "${item##*/}" | awk -F "." '{ print $1 }')"

		if [ "$1" == "--verbose" ]; then
			echo "- adding $item \ $start_amt"
		fi
		echo "$item=$start_amt" >> $basedir/home/$username/items.lst
	done
	echo "done"
}
