#!/bin/bash
###################################################################
# Copyright (c) 2023 David L. Whitehurst
# License: https://github.com/dlwhitehurst/vytools/blob/main/LICENSE
#
# This script provides indication of environment health.
#
# Author: Chris Noe
# Edited: David L Whitehurst
#
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  envhealth.sh [<env-name>]
Examples:
  envhealth.sh
  envhealth.sh local

Perform a health check on each VirtualYou API.
For non-200 responses, report the http-code and show the response content.

ENDHELP
    exit
fi
################################################################################

# ignore command customizations, if any
unalias curl    2> /dev/null
unalias cat     2> /dev/null

# --------------------------------------------------
# parse command line args

env="${1:-local}"

shift 1

case "${env}" in
    local)  ENV_HOST=localhost ;;
    prod)   ENV_HOST=virtualyou.info ;;
      *)    echo "Unrecognized env: ${env}"; exit 1 ;;
esac

# --------------------------------------------------
# check each API family

CURL_ERROR_COUNT=0
HTTP_ERROR_COUNT=0

# retrieve content, and display it only if there was an error
_curl_GET() {
    local url=${1}
    shift 1
    local responseFile=/tmp/$(basename "${BASH_SOURCE[0]}").out
    httpCode=$(
        set -x
        curl -s -X GET "$url" "$@" -w '%{http_code}' -o ${responseFile}
    )
    local curlRC=$?
    if [[ ${curlRC} != 0 ]]; then
        ((CURL_ERROR_COUNT++))
        echo "curl error: ${curlRC}"
    elif [[ ${httpCode} != 200 ]]; then
        ((HTTP_ERROR_COUNT++))
        echo "HTTP status code: $httpCode"
        cat ${responseFile}
        echo
    else
      cat ${responseFile} | jq '.'
    fi
    rm -f ${responseFile}
}

echo "------------------------------------------------------------"
echo "Userauth API"
_curl_GET "http://${ENV_HOST}:3001/"

echo "------------------------------------------------------------"
echo "Personal API"
_curl_GET "http://${ENV_HOST}:3002/"

echo "------------------------------------------------------------"
echo "Medical API"
_curl_GET "http://${ENV_HOST}:3003/"

echo "------------------------------------------------------------"
echo "Financial API"
_curl_GET "http://${ENV_HOST}:3004/"

echo "------------------------------------------------------------"
echo "Administration API"
_curl_GET "http://${ENV_HOST}:3005/"

if [[ $((CURL_ERROR_COUNT + HTTP_ERROR_COUNT)) > 0 ]]; then
    echo
fi
if [[ ${CURL_ERROR_COUNT} > 0 ]]; then
    echo "See curl error code listing: https://man7.org/linux/man-pages/man1/curl.1.html#EXIT_CODES"
fi
if [[ ${HTTP_ERROR_COUNT} > 0 ]]; then
    echo "See HTTP code listing: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes"
fi
