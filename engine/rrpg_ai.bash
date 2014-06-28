#!/usr/bin/env bash
#
# (c) 2014 RDashINC
#
# BUGS:
#   - None
#
# Changelog:
# 	- v1.0 Initial.

function get_random_number {
	grep -m1 -ao "[$1-$2]" /dev/urandom | sed s/0/10/ | head -n1
}

function choose_option {
	local tn=0
	for option in $@
	do
		local tn=$(($tn+1))
	done

	local rn=$(get_random_number 1 $tn)
	echo ${!rn}
}