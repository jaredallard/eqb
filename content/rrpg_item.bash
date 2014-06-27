#!/usr/bin/env bash
#
# (c) 2014 RDashINC

add_item() {
	echo -e "${White}** '${Cyan}$1${White}' ${Green} was added to your inventory!${NC}"
}

remove_item() {
 echo -e "${White}** '${Cyan}$1${White}' ${Red} was removed from your inventory!${NC}"
}

gen_items() {
	open
	echo "#Created $(date +%T)" > $basedir/home/$username/items.lst
	for item in $basedir/content/loaded/items/*.itm
	do
		echo - adding $item
		echo "$item: 0" >> $basedir/home/$username/items.lst
	done
}