#!/bin/bash
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  envhealth.sh [<env-name>]
Examples:
  envhealth.sh
  envhealth.sh local

Perform a health check on each CDX API.
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
  local) ENV_HOST=localhost:8443                 ;;
    dev) ENV_HOST=mule.dev.kube.navy.ms3-inc.com ;;
     qa) ENV_HOST=mule.qa.kube.navy.ms3-inc.com  ;;
    qa2) ENV_HOST=mule.qa2.kube.navy.ms3-inc.com ;;
      *) echo "Unrecognized env: ${env}"; exit 1 ;;
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
    fi
    rm -f ${responseFile}
}

echo "------------------------------------------------------------"
echo "OAuth Provider"
_curl_GET "https://${ENV_HOST}/oauth/health"

echo "------------------------------------------------------------"
echo "CDX Hello World & CDX Time"
_curl_GET "https://${ENV_HOST}/xapi/v1/hello/health"
_curl_GET "https://${ENV_HOST}/xapi/v1/time/health"

echo "------------------------------------------------------------"
echo "CDX Monitoring (db-sapi, Poller, Dashboard)"
_curl_GET "https://${ENV_HOST}/sapi/v1/cdxmon/health"
_curl_GET "https://${ENV_HOST}/cdxmon/poller/health"
_curl_GET "https://${ENV_HOST}/cdxmon/dashboard/health"

echo "------------------------------------------------------------"
echo "Advana (push, pull)"
_curl_GET "https://${ENV_HOST}/sapi/v1/audits/health"
_curl_GET "https://${ENV_HOST}/xapi/v1/dropbox/audits/health"
_curl_GET "https://${ENV_HOST}/xapi/v1/audits/health"

echo "------------------------------------------------------------"
echo "SABRS CB (Allo, Auth, Corr, Spen)"
_curl_GET "https://${ENV_HOST}/sapi/v1/allocations/health"
_curl_GET "https://${ENV_HOST}/sapi/v1/authorizations/health"
_curl_GET "https://${ENV_HOST}/sapi/v1/corrections/health"
_curl_GET "https://${ENV_HOST}/sapi/v1/spendings/health"

echo "------------------------------------------------------------"
echo "SABRS G/L (Cycles, Index, Cache)"
_curl_GET "https://${ENV_HOST}/xapi/v1/sabrsgl/cycles/health"
_curl_GET "https://${ENV_HOST}/xapi/v1/sabrsgl/index/health"
_curl_GET "https://${ENV_HOST}/xapi/v1/sabrsgl/cache/health"

echo "------------------------------------------------------------"
echo "SMARTS (Active, FCS, RBC, RON)"
_curl_GET "https://${ENV_HOST}/xapi/v2/smarts/active/health"
_curl_GET "https://${ENV_HOST}/xapi/v2/smarts/fund-ctl-spend/health"
_curl_GET "https://${ENV_HOST}/xapi/v2/smarts/reim-bill-code/health"
_curl_GET "https://${ENV_HOST}/xapi/v2/smarts/reim-order-nbr/health"

echo "------------------------------------------------------------"
echo "SMARTS Labor History"
_curl_GET "https://${ENV_HOST}/sapi/v1/smarts/laborhist-trans-org/health"
_curl_GET "https://${ENV_HOST}/xapi/v1/smarts/laborhist-trans/health"

if [[ $((CURL_ERROR_COUNT + HTTP_ERROR_COUNT)) > 0 ]]; then
    echo
fi
if [[ ${CURL_ERROR_COUNT} > 0 ]]; then
    echo "See curl error code listing: https://man7.org/linux/man-pages/man1/curl.1.html#EXIT_CODES"
fi
if [[ ${HTTP_ERROR_COUNT} > 0 ]]; then
    echo "See HTTP code listing: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes"
fi
