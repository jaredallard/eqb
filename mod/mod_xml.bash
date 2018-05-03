#!/bin/bash
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_xparse
# MOD_AUTHOR: Jared Allard <jaredallard@outlook.com>
# DATE: Late 2014
# MOD_VERSION: 1.0.2
# MOD_CHANGELOG:
# 	V1.0.1 Initial Release.
#	  V1.0.2 Fixed issues with spaces in values for <head>value</footer>. Same-line for <head blah=""> is working, but spaces in val break it.
# MOD_DESC: XParse, a bash based XML parser.
# MOD_UPDATE_TYPE: MANUAL
##########################
export enabled="yes"    #
##########################
if [ ! "$enabled" == "yes" ]; then
	echo "ERR:DISABLED"
	return
fi

function parse_xml { ## XML Parser.
	## (C) 2013-Present RDashINC.
	## GNUGPLV3
	## Wrap in functions for locals. -- Was original reason, now for module-based packing.

	## Make Values Numeric.
	## Why did I resolve to numeric values? Init'in them is hell.
	
	debug "Started Parsing."
	debug "NOTE: Debug output shouldn't be used for parsing. It breaks values."
	local ot=$2
	local start=0
	local value=0
	local sxml=0
	local ver_def=0
	local value=0
	local val=0
	local wtf_moment=0
	if [ ! -e "$1.xml" ]; then ## File doesn't exist, send error.
		echo "ERR: XML File not found."
		return
	fi
	head -n 1 $1.xml | grep "<?xml" 1>/dev/null || echo "ERR: No <?xml def found. Expecting since line 1. $(return 1)" ## Check for mandatory <?xml def.
	for xml in $(cat $1.xml && echo "EOF")
	do
		local val=0
		if [ $wtf_moment == 1 ]; then
			if [ "$ot" == "--force-he" ]; then
				local start=2
			fi
		fi
		if [ "$xml" == "?>" ]; then ## Fix for displaying accidently ?> as an xml value.
			debug "Found incorrect <?xml closer, using anyways."
			local ver_def=0
			local sxml=0
		elif [ "$(echo "$xml" | awk -F '?' '{ print $2 }')" == ">" ]; then ## Incorrect <?xml closer, but accept anyways.
			debug "Using, correct, <?xml closer '?>'."
			local sxml=2
			echo "?xml_$(echo "$xml" | awk -F '?' '{ print $1 }')?"
			local ver_def=0
		elif [ "$(echo "$xml" | awk -F '?' '{ print $2 }' | awk -F '<' '{ print $1}')" == ">" ]; then
			debug "Using, correct, <?xml closer '?>'."
			echo "$xml" | grep "<" 1>/dev/null && local val=1 && debug "Found a same-line head, after special xml-closer." ## Check if next to xml value.
			local sxml=0
			echo "?xml_$(echo "$xml" | awk -F '?' '{ print $1 }')?"
			local ver_def=0
			if [ "$ot" == "--force-he" ]; then
				debug "Forced too use <header></header>."
				local start=2
			fi
		fi
		if [ $val == 1 ]; then
			local pxml="$xml"
			if [ "$(echo $xml | awk -F '>' '{ print $3 }')" == "" ]; then
				local xml="$(echo $xml | awk -F '>' '{ print $2 }')"
			else
				local xml="$(echo "$(echo $xml | awk -F '>' '{ print $2 }')>$(echo $xml | awk -F '>' '{ print $3 }')")"
			fi
			debug "XML reset too \"$xml\" from \"$pxml\"."
		fi
		if [ $ver_def == 1 ]; then ## it must be a <?xml ... ?> decleration. Declare it specially with 'xml_' header.
			local sxml=1
			debug  "Special XML value/condition found."
			echo "?xml_$xml?"
		fi
		if [ "$xml" == "<?xml" ]; then ## It's a special_start tag.
			debug "Found a special_xml decleration."
			local sxml=1
			local ver_def=1
		fi
		if [ ! $sxml == 1 ]; then ## This detects type, is broken for spaced lines.
			if [ $start == 0 ]; then
				local tmp1=0
				echo "$xml" | grep "</" 1>/dev/null && local tmp1=1
				if [ $tmp1 == 1 ]; then
					local pxml="$(echo "$(echo $xml | awk -F '>' '{ print $1 }')>")"
					echo "$xml" | grep "/>" 1>/dev/null && local xml="$(echo $xml | awk -F '>' '{ print $2 }')>"
					echo "$xml" | grep -w "</*" 1>/dev/null && local start=0 || local start=2
					if [ $start == 0 ]; then ## Don't even send it.
						local xml="$pxml"
					fi
				else
					echo "$xml" | grep -w "</*" 1>/dev/null && local start=2 || local start=0
				fi
			fi
		fi
		if [ $start == 0 ]; then
			if [ $sxml == 0 ]; then
				if [ $value == 1 ]; then
					local tmp2=0
					echo "$xml" | grep -w "</*" 1>/dev/null && local tmp2=1
					if [ $tmp2 == 1 ]; then
						debug "Found a closing tag (presumeably) for a skipped start tag. Tag: \"$xml\""
						local value=6 ## Fix for a end-of-file after closing tag.
					else
						echo $xml | grep "=" 1>/dev/null && local value=2 && debug "Got a correct formated value." || local value=3
					fi
				fi
				if [ $value == 2 ]; then
					if [ ! "$xml" == "/>" ]; then
						echo "$xml" | grep "<" 1>/dev/null && local value=5
						echo "$xml" | grep "<" 1>/dev/null && debug "Recived a />< based tag. (On Same Line.)"
						if [ ! $value == 5 ]; then ## Check if tag collides w/ another, if not then use 'space' assumed parse.
							echo $xml | grep "/>" 1>/dev/null || local value=4
							echo $xml | grep "/>" 1>/dev/null || debug "Set to assume another value after this one."
							echo -e "$(echo -e "$var_name\c")_$(echo $xml | awk -F '=' '{ print $1 }')=\c"
						else ## Must use the value 5.
							echo -e "$(echo -e "$var_name\c")_$(echo $xml | awk -F '=' '{ print $1 }')=\c"
							echo $xml | awk -F '=' '{ print $2 }' | awk -F '/' '{ print $1 }'
							local var_name="$(echo $xml | awk -F '<' '{ print $2 }')"
						fi
						if [ $value == 4 ]; then
							echo $xml | awk -F '=' '{ print $2 }'
						elif [ $value == 2 ]; then
							echo $xml | awk -F '/' '{ print $1 }' | awk -F '=' '{ print $2 }'
						elif [ $value == 5 ]; then
							debug "Same-line based var, skipping normal print."
						else
							echo "ERR: Expected another value, or a closing tag but got \"$xml\" instead.$(return 1)"
						fi
					else
						debug "Got a, random, placed \"/>\" after a value. Using anyway."
					fi
				fi
				if [ $value == 3 ]; then
					echo "ERR: Was expecting a value, but got \"$xml\".$(return 1)"
					return
				fi
				if [ $value == 0 ]; then
					if [ "$xml" == "EOF" ]; then
						debug "End of XML File. Done parsing."
						return
					fi
					local ns=0
					echo "$xml" | grep "<" 1>/dev/null && local ns=1 || local ns=0
					echo "$xml" | grep ">" 1>/dev/null || local ns=0
					echo "$xml" | grep "/>" 1>/dev/null && local ns=0
					if [ $ns == 1 ]; then
						debug "Found a <head> or </head>, not using. (XML=$xml)"
						if [ "$(echo $xml | awk -F '>' '{ print $2 }')" == "" ]; then
							local value=0
						else
							local xml="$(echo $xml | awk -F '>' '{ print $2 }')"
							echo $xml | grep "<" 1>/dev/null && local var_name="$(echo $xml | grep "<" | awk -F '<' '{ print $2 }')" && local value=0 && debug "Found a head - $var_name." || debug "Bug #1" && local value=1
							echo $xml | grep "<" 1>/dev/null || debug "\"$xml\" wasn't a head. Value set to 1."
						fi
					else
							echo $xml | grep "<" 1>/dev/null && local var_name="$(echo $xml | grep "<" | awk -F '<' '{ print $2 }')" && local value=0 && debug "Found a head - $var_name." || debug "Bug #1" && local value=1
							echo $xml | grep "<" 1>/dev/null || debug "\"$xml\" wasn't a head. Value set to 1."
					fi
				elif [ $value == 2 ]; then
					debug "Value was 2, resetting to 0 for next loopover."
					local value=0
				elif [ $value == 4 ]; then
					debug "Value was 4, resetting to 1 for next loopover."
					local value=1
				elif [ $value == 5 ]; then
					debug "Value was 5, resetting to 1 for next loopover."
					local value=1
				elif [ $value == 6 ]; then ## Escape value, set to escape loop.
					debug "Value was 6, resetting to 0 for next loopover."
					local value=0
				fi
			fi
		elif [ $start == 2 ]; then ## Must be <head>value</foot> -- this section controls that output then.
			debug "Is a <head>value</foot> based xml line."
			local ver_tmp=0
			if [ ! "$sstart" == "0" ]; then
				if [ "$xml" == "EOF" ]; then
					debug "Found EOF."
				else
					local sstart="0"
					echo "$xml" | grep "<" 1>/dev/null && local ver_tmp=1 || echo "ERR: Expected a <name>value</name> system, got \"$xml\".$(return 1)"
					echo "$xml" | grep ">" 1>/dev/null && local ver_tmp=2 || echo "ERR: Expected a <name>value</name> system, got \"$xml\".$(return 1)"
					local head="$(echo "$xml" | awk -F '>' '{ print $1 }' | awk -F '<' '{ print $2 }')"
					echo $xml | grep '</' 1>/dev/null && local foot="$(echo "$xml" | awk -F '</' '{ print $2 }' | awk -F '>' '{ print $1 }')"
					echo $xml | grep '</' 1>/dev/null || local foot="0"
					local val="$(echo "$xml" | awk -F '>' '{ print $2 }' | awk -F '<' '{ print $1 }')"
					if [ "$foot" == "0" ]; then
						echo -n "$(echo -n "$head")_val='$val "
					else
						local sstart="1"
						echo "$(echo -n "$head")_val='$val'" 
					fi
				fi
			else
				if [ "$foot" == "0" ]; then
					debug "Found space."
					echo $xml | grep '</' 1>/dev/null && local foot="$(echo "$xml" | awk -F '</' '{ print $2 }' | awk -F '>' '{ print $1 }')" || local foot="0"
					echo $xml | grep '</' 1>/dev/null && local foot="$(echo "$xml" | awk -F '</' '{ print $2 }' | awk -F '>' '{ print $1 }')" || echo -n "$xml "
					if [ ! "$foot" == "0" ]; then
						debug "Footer found. (XML=$xml)"
						if [ ! "$head" == "$foot" ]; then
							echo "ERR: Start not equal foot on sameline. $head =! $foot."
							return 1
						fi
						local val="$(echo "$xml" | awk -F '<' '{ print $1 }')"
						echo "$val'"
						local sstart="1"
					fi
				else
					if [ "$xml" == "EOF" ]; then
						debug "Found EOF."
					fi
				fi
			fi
		fi
		if [ "$xml" == "?>" ]; then ## End of special_start tag.
			local sxml=0
			local ver_def=0
		fi
		if [ $sxml == 2 ]; then
			debug "Forced to use <header></header>."
			local wtf_moment=1
		fi
		local sxml=0
	done
}

function debug { ## Disabled in module form.
	#export debug
	#if [ $debug == 1 ]; then
	#	echo "[DEBUG] ($(date +%M:%S:%N)): $1"
	#fi
	echo "" >/dev/null
}

if [ "$1" == "mod_loader" ]; then
	echo "OK"
fi