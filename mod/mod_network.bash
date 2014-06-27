#!/bin/bash
#####
# MOD_MANIFEST: rrpg_manifest
# MOD_NAME: mod_network
# MOD_AUTHOR: RainbowDashDC
# MOD_VERSION: 1.0-dev
# MOD_DESC: Implements a *pure* bash based downloader, with a wget or curl fallback, or error
# MOD_UPDATE_LINK: http://rainbowdashdc.github.io/rrpg/mod_network.txt
# MOD_UPDATE_TYPE: TXT
#
# @author: RainbowDashDC
# @desc: &MOD_DESC
# @version: &MOD_VERSION
# @license: GNUGPLv3
# @notice: All of the &amps; *must* be included with this.
# @created: $DATE by bBash
#####

function download {
	: ${DEBUG:=0}
    local URL=$1
    local tag="Connection: close"
    local mark=0

    if [ -z "${URL}" ]; then
        printf "Usage: %s \"URL\" [e.g.: %s http://www.google.com/]" \
               "${FUNCNAME[0]}" "${FUNCNAME[0]}"
        return 1;
    fi
    read proto server path <<<$(echo ${URL//// })
    DOC=/${path// //}
    HOST=${server//:*}
    PORT=${server//*:}
    [[ x"${HOST}" == x"${PORT}" ]] && PORT=80
    [[ $DEBUG -eq 1 ]] && echo "HOST=$HOST"
    [[ $DEBUG -eq 1 ]] && echo "PORT=$PORT"
    [[ $DEBUG -eq 1 ]] && echo "DOC =$DOC"

    exec 3<>/dev/tcp/${HOST}/$PORT
    echo -en "GET ${DOC} HTTP/1.1\r\nHost: ${HOST}\r\n${tag}\r\n\r\n" >&3
    while read line; do
        [[ $mark -eq 1 ]] && echo $line
        if [[ "${line}" =~ "${tag}" ]]; then
            mark=1
        fi
    done <&3
    exec 3>&-
}

if [ "$1" == "mod_loader" ]; then
    echo "OK"
fi